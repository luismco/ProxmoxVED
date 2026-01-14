#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/luismco/ProxmoxVED/refs/heads/krawl/misc/build.func)
# Copyright (c) 2021-2026 community-scripts ORG
# Author: luismco
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/BlessedRebuS/Krawl

APP="Krawl"
var_tags="${var_tags:-proxy}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -d /opt/Krawl ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  if check_for_gh_release "Krawl" "BlessedRebuS/Krawl"; then
    msg_info "Stopping Service"
    systemctl stop krawl
    msg_ok "Stopped Service"

    msg_info "Backing up Configuration and Logs"
    cp /opt/Krawl/.env /tmp/Krawl.env.bak
    cp -r /opt/Krawl/logs /tmp/Krawl/
    msg_ok "Backed up Configuration and Logs"

    fetch_and_deploy_gh_release "Krawl" "BlessedRebuS/Krawl"

    msg_info "Restoring Configuration and Logs"
    cp /tmp/Krawl.env.bak /opt/Krawl/.env
    cp -r /tmp/Krawl/logs /opt/Krawl
    rm -f /tmp/Krawl.env.bak
    rm -rf /tmp/Krawl/logs
    msg_ok "Restored Configuration and Logs"

    msg_info "Starting Service"
    systemctl start krawl
    msg_ok "Started Service"
    msg_ok "Updated successfully!"
  fi
  exit
}

start
build_container
description

msg_ok "Completed successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:5000${CL}"
