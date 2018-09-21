#!/bin/bash

# Script to configure grafana datasources and dashboards.
# https://github.com/grafana/grafana-docker/issues/74

[ ! -f /run/secrets/grafana-auth-user ] || GF_SECURITY_ADMIN_USER=$(cat /run/secrets/grafana-auth-user)
[ ! -f /run/secrets/grafana-auth-password ] || GF_SECURITY_ADMIN_PASSWORD=$(cat /run/secrets/grafana-auth-password)

GRAFANA_URL=http://${GF_SECURITY_ADMIN_USER}:${GF_SECURITY_ADMIN_PASSWORD}@${GF_SERVER_HTTP_ADDR:-localhost}:${GF_SERVER_HTTP_PORT:-3000}
DATASOURCES_PATH=${DATASOURCES_PATH:-/etc/grafana/datasources}
DASHBOARDS_PATH=${DASHBOARDS_PATH:-/etc/grafana/dashboards}
USERS_PATH=${USERS_PATH:-/etc/grafana/users}

# Generic function to call the Vault API
grafana_api() {
  local verb=$1
  local url=$2
  local params=$3
  local bodyfile=$4
  local response
  local cmd

  cmd="curl -L -s --fail -H \"Accept: application/json\" -H \"Content-Type: application/json\" -X ${verb} -k ${GRAFANA_URL}${url}"
  [[ -n "${params}" ]] && cmd="${cmd} -d \"${params}\""
  [[ -n "${bodyfile}" ]] && cmd="${cmd} --data @${bodyfile}"
  echo "Running ${cmd}"
  eval ${cmd} || return 1
  return 0
}

wait_for_api() {
  while ! grafana_api GET /api/user/preferences
  do
    sleep 5
  done
}

install_datasources() {
  local datasource

  for datasource in ${DATASOURCES_PATH}/*.json
  do
    if [[ -f "${datasource}" ]]; then
      echo "Installing datasource ${datasource}"
      if grafana_api POST /api/datasources "" "${datasource}"; then
        echo "installed ok"
      else
        echo "install failed"
      fi
    fi
  done
}

install_dashboards() {
  local dashboard

  for dashboard in ${DASHBOARDS_PATH}/*.json
  do
    if [[ -f "${dashboard}" ]]; then
      echo "Installing dashboard ${dashboard}"
      if grafana_api POST /api/dashboards/db "" "${dashboard}"; then
        echo "installed ok"
      else
        echo "install failed"
      fi
    fi
  done
}

install_users() {
  local user

  for user in ${USERS_PATH}/*.json
  do
    if [[ -f "${user}" ]]; then
      echo "Importing user ${user}"
      if grafana_api POST /api/admin/users "" "${user}"; then
        echo "imported ok"
      else
        echo "import failed"
      fi
    fi
  done
}

install_plugins() {
  echo raintank-worldping-app| xargs -n 1 grafana-cli plugins install
}

configure_grafana() {
  wait_for_api
  install_datasources
  install_dashboards
  install_users
}

install_plugins
echo "Running configure_grafana in the background..."
configure_grafana &
/run.sh
exit 0
