#!/usr/bin/env bash
# dota2-sync.sh  –  copy/inspect Dota-2 configs on macOS
#
# Usage:
#   dota2-sync.sh [--local|--remote|--both]              # interactive picker
#   dota2-sync.sh [--local|--remote|--both] <id|idx>     # show info
#   dota2-sync.sh [--local|--remote|--both] <from> <to>  # copy (asks confirmation)
#
# Flags (optional, default = --both):
#   --local   sync only local/ cfg
#   --remote  sync only remote/ cfg
#   --both    sync both local/ and remote/ cfg           (default)
#
# Nickname & Login detection:
#   • PersonaName from loginusers.vdf
#   • Fallback nickname: "name" in user_convars.vcfg
#   • Fallback login:   "AccountName" in userdata/<id>/config/localconfig.vdf
###############################################################################

STEAM_USERDATA="$HOME/Library/Application Support/Steam/userdata"
LOGIN_VDF="$HOME/Library/Application Support/Steam/config/loginusers.vdf"
APP_ID=570
COPY_MODE=both                            # default, may be overridden by flag
###############################################################################

set -euo pipefail
STEAM64_OFFSET=76561197960265728          # accountID ↔ SteamID64

# ── helpers ────────────────────────────────────────────────────────────────
is_idx()     { [[ $1 =~ ^[0-9]+$ && $1 -le ${#IDS[@]} && $1 -ge 1 ]]; }
is_steam64() { [[ $1 =~ ^7656[0-9]{13}$ ]]; }

to_account() {
  local x=$1
  if is_idx "$x"; then echo "${IDS[$((x-1))]}"; return; fi
  if is_steam64 "$x"; then echo $((x - STEAM64_OFFSET)); return; fi
  echo "$x"
}

to_steam64() { printf %d $(( $1 + STEAM64_OFFSET )); }

# --- login & nickname lookup ----------------------------------------------
local_login() {           # account-ID → AccountName (empty if none)
  local cfg="$STEAM_USERDATA/$1/config/localconfig.vdf"
  [[ -f $cfg ]] || return 1
  grep -m1 -E '"AccountName"[[:space:]]+"[^"]+"' "$cfg" \
    | sed -E 's/.*"AccountName"[[:space:]]+"([^"]+)".*/\1/'
}

vcfg_name() {             # account-ID → "name" from user_convars.vcfg
  local base="$STEAM_USERDATA/$1/$APP_ID"
  local try=(
    "$base/remote/user_convars.vcfg"
    "$base/local/user_convars.vcfg"
    "$base/remote/cfg/user_convars.vcfg"
    "$base/local/cfg/user_convars.vcfg"
  )
  for cfg in "${try[@]}"; do
    [[ -f $cfg ]] || continue
    grep -m1 -E '"name"[[:space:]]+"[^"]+"' "$cfg" \
      | sed -E 's/.*"name"[[:space:]]+"([^"]+)".*/\1/' && return 0
  done
}

login_name() {            # account-ID → AccountName (with fallback)
  local id64 name
  id64=$(to_steam64 "$1")

  name=$(awk -v id="$id64" '
    $0 ~ "\""id"\"" {f=1}
    f && /"AccountName"/ {
      sub(/^[^"]*"AccountName"[[:space:]]*"/,"")
      sub(/"$/,"")
      print; exit
    }' "$LOGIN_VDF" 2>/dev/null || true)

  [[ -z $name ]] && name=$(local_login "$1" || true)
  echo "${name:-?}"
}

nick_name() {             # account-ID → PersonaName (with fallback)
  local id64 nick
  id64=$(to_steam64 "$1")

  nick=$(awk -v id="$id64" '
    $0 ~ "\""id"\"" {f=1}
    f && /"PersonaName"/ {
      sub(/^[^"]*"PersonaName"[[:space:]]*"/,"")
      sub(/"$/,"")
      print; exit
    }' "$LOGIN_VDF" 2>/dev/null || true)

  [[ -z $nick ]] && nick=$(vcfg_name "$1" || true)
  echo "${nick:-?}"
}

account_line() {          # $1 = label  $2 = account-ID
  printf "%-3s %-11s | %-18s | %s\n" "$1" "$2" "$(login_name "$2")" "$(nick_name "$2")"
}

steamids() {
  find "$STEAM_USERDATA" -mindepth 1 -maxdepth 1 -type d -print |
    awk -F/ '{print $NF}' | grep -E '^[0-9]+$' | sort -n
}

copy_parts() {
  case "$COPY_MODE" in
    remote) echo remote ;;
    local)  echo local  ;;
    both)   echo remote local ;;
    *)      echo "Invalid COPY_MODE ($COPY_MODE)" >&2; exit 1 ;;
  esac
}

sync_part() {             # $1=from  $2=to  $3=remote|local
  local SRC="$STEAM_USERDATA/$1/$APP_ID/$3/cfg"
  local DST="$STEAM_USERDATA/$2/$APP_ID/$3/cfg"
  [[ -d $SRC ]] || { echo "⚠️  $3/cfg missing in source – skipped"; return; }

  mkdir -p "$DST"
  if [ "$(ls -A "$DST" 2>/dev/null)" ]; then
    local BAK="$DST.bak.$(date +%Y%m%d_%H%M%S)"
    echo "🔄  backup $3 → $BAK"; cp -a "$DST" "$BAK"
  fi
  echo "➡️   syncing $3 …"; rsync -a --delete "$SRC/" "$DST/"
}

do_copy() {               # $1=from  $2=to
  for part in $(copy_parts); do sync_part "$1" "$2" "$part"; done
  echo "✅  copy done (mode: $COPY_MODE)"
}

steam_running() { pgrep -qx steam_osx || pgrep -qx Steam; }
confirm()       { read -rp "$1 (y/N): " r; [[ $r =~ ^[yY]$ ]]; }

usage() {
  grep -E '^# (Usage|Flags)' -A3 "$0" | sed 's/^# \{0,1\}//'
  exit 0
}

###############################################################################
# FLAG PARSING
###############################################################################
while [[ $# -gt 0 ]]; do
  case "$1" in
    --local)  COPY_MODE=local;  shift ;;
    --remote) COPY_MODE=remote; shift ;;
    --both)   COPY_MODE=both;   shift ;;
    -h|--help) usage ;;
    --) shift; break ;;
    *) break ;;
  esac
done

###############################################################################
# MAIN
###############################################################################
mapfile -t IDS < <(steamids)
[[ ${#IDS[@]} -gt 0 ]] || { echo "No Steam userdata found"; exit 1; }

case $# in
0)
  echo "📋  Accounts:"
  echo "Idx SteamID     | Login             | Nickname"
  echo "─── ----------- + ----------------- + ---------------------------"
  for i in "${!IDS[@]}"; do account_line "$((i+1))" "${IDS[$i]}"; done; echo

  read -rp "Copy FROM (idx/ID): " in_from
  read -rp "Copy   TO (idx/ID): " in_to
  FROM=$(to_account "$in_from"); TO=$(to_account "$in_to")
  [[ $FROM != "$TO" && -d $STEAM_USERDATA/$FROM && -d $STEAM_USERDATA/$TO ]] || { echo "Invalid selection"; exit 1; }

  echo; account_line "Src" "$FROM"; account_line "Dst" "$TO"; echo "Mode: $COPY_MODE"
  steam_running && echo "⚠️  Steam is running – close it first." && exit 1
  confirm "Proceed?" && do_copy "$FROM" "$TO"
  ;;
1)
  ACC=$(to_account "$1"); account_line "" "$ACC"
  ;;
2)
  FROM=$(to_account "$1"); TO=$(to_account "$2")
  [[ $FROM != "$TO" && -d $STEAM_USERDATA/$FROM && -d $STEAM_USERDATA/$TO ]] || { echo "Need two different valid IDs"; exit 1; }
  echo "Source:"; account_line "" "$FROM"
  echo "Target:"; account_line "" "$TO"
  echo "Mode: $COPY_MODE"
  steam_running && echo "⚠️  Steam is running – close it first." && exit 1
  confirm "Copy now?" && do_copy "$FROM" "$TO"
  ;;
*)
  usage ;;
esac
