#!/bin/sh
# Configure GNOME Remote Desktop (GRD) for headless RDP remote login.
# The TLS certificate is generated on the instance so that every VM created
# from this image gets its own key material.
set -eu

conf_dir=/etc/gnome-remote-desktop
cert="$conf_dir/rdp-tls.crt"
key="$conf_dir/rdp-tls.key"

if ! command -v grdctl >/dev/null 2>&1; then
  echo "grdctl not found, skipping GNOME Remote Desktop setup" >&2
  exit 0
fi

mkdir -p "$conf_dir"

if [ ! -s "$cert" ] || [ ! -s "$key" ]; then
  rm -f "$cert" "$key"
  (
    umask 0077
    openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
      -subj "/CN=$(hostname)" \
      -keyout "$key" -out "$cert"
  )
fi

if getent passwd gnome-remote-desktop >/dev/null 2>&1; then
  chown gnome-remote-desktop:gnome-remote-desktop "$cert" "$key"
fi
chmod 0600 "$key"
chmod 0644 "$cert"

grdctl --system rdp set-tls-cert "$cert"
grdctl --system rdp set-tls-key "$key"
grdctl --system rdp enable
