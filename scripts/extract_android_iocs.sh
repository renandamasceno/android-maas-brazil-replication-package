#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash scripts/extract_android_iocs.sh SAMPLE.apk [OUTPUT_ROOT]

Perform static extraction and IOC triage on an APK already obtained through
authorized means. The script does not download, install, execute, or contact
the APK. OUTPUT_ROOT defaults to analysis-output.

Run only in an isolated analysis environment. Generated files may contain
sensitive or operational indicators and must be reviewed before publication.
EOF
}

if [[ ${1:-} == "--help" || ${1:-} == "-h" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage >&2
  exit 2
fi

APK=$1
BASE_OUT=${2:-analysis-output}

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "error: missing required dependency: $1" >&2
    exit 1
  }
}

have() {
  command -v "$1" >/dev/null 2>&1
}

sanitize_name() {
  basename "$1" .apk | tr ' /:' '___'
}

sha256_file() {
  if have sha256sum; then
    sha256sum "$1"
  elif have shasum; then
    shasum -a 256 "$1"
  else
    echo "error: sha256sum or shasum is required" >&2
    return 1
  fi
}

md5_file() {
  if have md5sum; then
    md5sum "$1"
  elif have md5; then
    md5 -q "$1"
  else
    echo "error: md5sum or md5 is required" >&2
    return 1
  fi
}

infer_main_package() {
  local badging_file=$1
  local manifest_file=$2
  local package_name=""

  if [[ -s $badging_file ]]; then
    package_name=$(sed -n "s/^package: name='\([^']*\)'.*/\1/p" "$badging_file" | head -n1 || true)
  fi
  if [[ -z $package_name && -s $manifest_file ]]; then
    package_name=$(sed -n 's/.*package="\([^"]*\)".*/\1/p' "$manifest_file" | head -n1 || true)
  fi
  printf '%s' "$package_name"
}

clean_urls() {
  grep -viE \
    'android\.com|google\.com|googleapis\.com|gstatic\.com|schema\.org|w3\.org|apache\.org|kotlinlang\.org|jetbrains|github\.com|okhttp|firebase|crashlytics|adjust\.com|appsflyer|facebook\.com|mozilla\.org' \
    "$1" > "$2" || true
}

run_jadx() {
  local output_dir=$1
  shift
  if have timeout; then
    timeout 20m jadx --no-imports --no-debug-info -d "$output_dir" "$@"
  elif have gtimeout; then
    gtimeout 20m jadx --no-imports --no-debug-info -d "$output_dir" "$@"
  else
    echo "warning: timeout unavailable; running JADX without a time limit" >&2
    jadx --no-imports --no-debug-info -d "$output_dir" "$@"
  fi
}

run_apktool() {
  local output_dir=$1
  local apk_path=$2
  if have timeout; then
    timeout 20m apktool d -f -o "$output_dir" "$apk_path"
  elif have gtimeout; then
    gtimeout 20m apktool d -f -o "$output_dir" "$apk_path"
  else
    echo "warning: timeout unavailable; running APKTool without a time limit" >&2
    apktool d -f -o "$output_dir" "$apk_path"
  fi
}

need unzip
need zipinfo
need strings
need grep
need sed
need awk
need sort
need head
need basename
need tr
need wc
need cp

if [[ ! -f $APK ]]; then
  echo "error: APK not found: $APK" >&2
  exit 1
fi

NAME=$(sanitize_name "$APK")
OUT=$BASE_OUT/$NAME
DEX_DIR=$OUT/dex
RAW_DIR=$OUT/raw
JADX_DIR=$OUT/jadx
SRC_DIR=$JADX_DIR/sources
APKTOOL_DIR=$OUT/apktool

if [[ -e $OUT ]]; then
  echo "error: output already exists; choose a new output root: $OUT" >&2
  exit 1
fi

mkdir -p "$DEX_DIR" "$RAW_DIR" "$JADX_DIR"
echo "Processing $APK"

sha256_file "$APK" > "$OUT/hash_sha256.txt"
md5_file "$APK" > "$OUT/hash_md5.txt"
zipinfo "$APK" > "$OUT/zipinfo.txt" || true
zipinfo "$APK" | grep -Ei 'AndroidManifest.xml|classes[0-9]*\.dex|assets/|lib/' > "$OUT/inventario.txt" || true

if have aapt; then
  aapt dump badging "$APK" > "$OUT/badging.txt" 2>&1 || true
  aapt dump permissions "$APK" > "$OUT/permissions.txt" 2>&1 || true
  aapt dump xmltree "$APK" AndroidManifest.xml > "$OUT/manifest_xmltree.txt" 2>&1 || true
elif have apkanalyzer; then
  apkanalyzer manifest print "$APK" > "$OUT/AndroidManifest.xml" 2>&1 || true
  apkanalyzer apk summary "$APK" > "$OUT/apk_summary.txt" 2>&1 || true
  apkanalyzer manifest permissions "$APK" > "$OUT/permissions.txt" 2>&1 || true
else
  echo "AAPT and APK Analyzer unavailable; detailed manifest extraction skipped." > "$OUT/tool_warning.txt"
fi

unzip -o "$APK" 'classes*.dex' -d "$DEX_DIR" > "$OUT/unzip_dex.log" 2>&1 || true

if have apktool; then
  run_apktool "$APKTOOL_DIR" "$APK" > "$OUT/apktool.log" 2>&1 || true
else
  echo "APKTool unavailable; manifest, resource, and Smali decoding skipped." > "$OUT/apktool.log"
fi

if compgen -G "$DEX_DIR/classes*.dex" >/dev/null; then
  for dex_file in "$DEX_DIR"/classes*.dex; do
    strings -a "$dex_file"
  done > "$RAW_DIR/strings_dex_all.txt" || true
else
  : > "$RAW_DIR/strings_dex_all.txt"
fi

if have jadx && compgen -G "$DEX_DIR/classes*.dex" >/dev/null; then
  run_jadx "$JADX_DIR" "$DEX_DIR"/classes*.dex > "$OUT/jadx.log" 2>&1 || true
else
  echo "JADX unavailable or no DEX extracted." > "$OUT/jadx.log"
fi

MAIN_PACKAGE=$(infer_main_package "$OUT/badging.txt" "$OUT/AndroidManifest.xml")
printf '%s\n' "$MAIN_PACKAGE" > "$OUT/main_package.txt"

if [[ -n $MAIN_PACKAGE ]]; then
  PACKAGE_PATH="$SRC_DIR/${MAIN_PACKAGE//./\/}"
else
  PACKAGE_PATH=""
fi

grep -Eio 'https?://[^"[:space:]<>)]+' "$RAW_DIR/strings_dex_all.txt" | sort -u > "$OUT/iocs_urls_raw.txt" || true
grep -Eo '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' "$RAW_DIR/strings_dex_all.txt" | sort -u > "$OUT/iocs_ips_raw.txt" || true
grep -Eai 'ws://|wss://|websocket|socket|mqtt|ftp|api|backend|panel|gate|command|server|upload|download' "$RAW_DIR/strings_dex_all.txt" | sort -u > "$OUT/iocs_infra_raw.txt" || true
grep -Eai 'telegram|api\.telegram|bot[0-9]+|chat_id|discord|slack|webhook' "$RAW_DIR/strings_dex_all.txt" | sort -u > "$OUT/iocs_exfiltration_raw.txt" || true
grep -Eai 'token|bearer|jwt|authorization|apikey|api_key|secret|secretkey|key=' "$RAW_DIR/strings_dex_all.txt" | sort -u > "$OUT/iocs_auth_raw.txt" || true
grep -Eai 'READ_SMS|RECEIVE_SMS|SEND_SMS|BIND_ACCESSIBILITY_SERVICE|SYSTEM_ALERT_WINDOW|QUERY_ALL_PACKAGES|READ_CONTACTS|READ_PHONE_STATE|RECORD_AUDIO|MEDIA_PROJECTION|MANAGE_EXTERNAL_STORAGE|RECEIVE_BOOT_COMPLETED' "$RAW_DIR/strings_dex_all.txt" | sort -u > "$OUT/iocs_behavior_strings.txt" || true
clean_urls "$OUT/iocs_urls_raw.txt" "$OUT/iocs_urls_clean.txt"

if [[ -d $SRC_DIR ]]; then
  grep -RInE 'http://|https://|ws://|wss://|HttpURLConnection|Socket|InetSocketAddress|WebSocket|URLConnection|openConnection|getResponseCode|setRequestMethod' "$SRC_DIR" > "$OUT/iocs_network.txt" || true
  grep -RInE 'c2|panel|gate|command|server|backend|upload|download|reconstructFile|filedata|filehash|Conf:|CO:' "$SRC_DIR" > "$OUT/iocs_c2.txt" || true
  grep -RInE 'telegram|api\.telegram|bot[0-9]+|chat_id|discord|slack|webhook' "$SRC_DIR" > "$OUT/iocs_exfiltration_code.txt" || true
  grep -RInE 'token|bearer|jwt|authorization|apikey|api_key|secret|SecretKeySpec|Cipher|MessageDigest' "$SRC_DIR" > "$OUT/iocs_auth_code.txt" || true
  grep -RInE 'AccessibilityService|BIND_ACCESSIBILITY_SERVICE|takeScreenshot|MediaProjection|SYSTEM_ALERT_WINDOW|BOOT_COMPLETED|RECORD_AUDIO|CAMERA|READ_SMS|SEND_SMS|READ_CONTACTS|READ_PHONE_STATE|MANAGE_EXTERNAL_STORAGE|REQUEST_DELETE_PACKAGES|startForeground' "$SRC_DIR" > "$OUT/iocs_behavior.txt" || true
  grep -RInE 'WebView|addJavascriptInterface|loadUrl|evaluateJavascript|WebViewClient|shouldOverrideUrlLoading|onPageFinished' "$SRC_DIR" > "$OUT/iocs_webview.txt" || true
else
  : > "$OUT/iocs_network.txt"
  : > "$OUT/iocs_c2.txt"
  : > "$OUT/iocs_exfiltration_code.txt"
  : > "$OUT/iocs_auth_code.txt"
  : > "$OUT/iocs_behavior.txt"
  : > "$OUT/iocs_webview.txt"
fi

if [[ -n $PACKAGE_PATH && -d $PACKAGE_PATH ]]; then
  grep -F "$PACKAGE_PATH/" "$OUT/iocs_network.txt" > "$OUT/iocs_network_clean.txt" || true
  grep -F "$PACKAGE_PATH/" "$OUT/iocs_c2.txt" > "$OUT/iocs_c2_clean.txt" || true
  grep -F "$PACKAGE_PATH/" "$OUT/iocs_behavior.txt" > "$OUT/iocs_behavior_clean.txt" || true
  grep -F "$PACKAGE_PATH/" "$OUT/iocs_webview.txt" > "$OUT/iocs_webview_clean.txt" || true
else
  cp "$OUT/iocs_network.txt" "$OUT/iocs_network_clean.txt"
  cp "$OUT/iocs_c2.txt" "$OUT/iocs_c2_clean.txt"
  cp "$OUT/iocs_behavior.txt" "$OUT/iocs_behavior_clean.txt"
  cp "$OUT/iocs_webview.txt" "$OUT/iocs_webview_clean.txt"
fi

{
  echo "apk=$APK"
  echo "output=$OUT"
  echo "main_package=$MAIN_PACKAGE"
  echo
  wc -l "$OUT"/*.txt 2>/dev/null || true
} > "$OUT/stats.txt"

echo "Done: $OUT"
echo "Review and sanitize every generated file before publication."
