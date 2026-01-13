#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: luismco
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/ThePhaseless/Byparr

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

fetch_and_deploy_gh_release "Krawl" "BlessedRebuS/Krawl" "v0.1.2-prerelease"

msg_info "Configuring Variables"
cat <<EOF >/opt/krawl/.env
# PORT=3500
# DELAY=100
# LINKS_MIN_LENGTH=5
# LINKS_MAX_LENGTH=15
# LINKS_MIN_PER_PAGE=10
# LINKS_MAX_PER_PAGE=15
# MAX_COUNTER=10
# CANARY_TOKEN_TRIES=10
# PROBABILITY_ERROR_CODES=0
# SERVER_HEADER=Apache/2.2.22 (Ubuntu)
## Optional: Set your canary token URL
# CANARY_TOKEN_URL=http://canarytokens.com/api/users/YOUR_TOKEN/passwords.txt
## Optional: Set custom dashboard path (auto-generated if not set)
# DASHBOARD_SECRET_PATH=/my-secret-dashboard
EOF
msg_ok "Configured Variables"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/krawl.service
[Unit]
Description=Krawl
After=network.target
Wants=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/krawl
ExecStart=/bin/bash -c 'set -a && source /opt/krawl/src/.env && set +a && exec /usr/bin/python3 /opt/krawl/src/server.py'
Restart=always
RestartSec=10
TimeoutStopSec=30
KillSignal=SIGTERM
SendSIGKILL=yes
StandardOutput=journal
StandardError=journal
SyslogIdentifier=krawl

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now krawl
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
