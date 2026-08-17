#!/usr/bin/env bash
# Shared helpers for app-scale CLI and wrapper. Sourced, not executed.
# shellcheck disable=SC2034

app_scale_config_dir() {
  printf '%s' "${XDG_CONFIG_HOME:-${HOME}/.config}/linux-app-scale"
}

app_scale_global_config() {
  printf '%s' "$(app_scale_config_dir)/config"
}

app_scale_profiles_dir() {
  printf '%s' "$(app_scale_config_dir)/profiles"
}

app_scale_profile_path() {
  printf '%s/%s.conf' "$(app_scale_profiles_dir)" "$1"
}

app_scale_get_kv() {
  local file="$1" key="$2" default="${3:-}"
  local v=""
  if [[ -f "$file" ]]; then
    v="$( (grep -E "^[[:space:]]*${key}=" "$file" 2>/dev/null || true) | tail -n1 | sed -E \
      "s/^[[:space:]]*${key}=//;s/#.*\$//;s/[[:space:]]+\$//;s/^['\"]//;s/['\"]\$//")"
  fi
  if [[ -n "${v:-}" ]]; then
    printf '%s' "$v"
  else
    printf '%s' "$default"
  fi
}

app_scale_sanitize_id() {
  local raw="$1"
  raw="$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9._-]+/-/g;s/^-+//;s/-+$//')"
  if [[ ! "$raw" =~ ^[a-z0-9][a-z0-9._-]*$ ]]; then
    return 1
  fi
  printf '%s' "$raw"
}

app_scale_id_from_desktop() {
  local base
  base="$(basename "$1" .desktop)"
  if [[ "$base" == *_* ]]; then
    base="${base%%_*}"
  fi
  app_scale_sanitize_id "$base"
}

app_scale_applications_dir() {
  printf '%s' "${XDG_DATA_HOME:-${HOME}/.local/share}/applications"
}

app_scale_managed_path() {
  local cfg
  cfg="$(app_scale_global_config)"
  local p
  p="$(app_scale_get_kv "$cfg" APP_SCALE_MANAGED_PATH "")"
  if [[ -n "$p" ]]; then
    printf '%s' "$p"
    return 0
  fi
  printf '%s' "${HOME}/.local/bin/app-scale-managed"
}

app_scale_resolve_scale() {
  local profile="$1"
  local s
  s="$(app_scale_get_kv "$profile" SCALE "")"
  if [[ -n "$s" ]]; then
    printf '%s' "$s"
    return 0
  fi
  s="$(app_scale_get_kv "$(app_scale_global_config)" DEVICE_SCALE_FACTOR "")"
  printf '%s' "$s"
}
