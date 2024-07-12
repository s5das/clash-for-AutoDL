#!/bin/bash

# 定义颜色和样式
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 自定义action函数，实现通用action功能
success() {
  echo -e "${GREEN}[  OK  ]${NC}"
  return 0
}

failure() {
  local rc=$?
  echo -e "${RED}[FAILED]${NC}"
  [ -x /bin/plymouth ] && /bin/plymouth --details
  return $rc
}

action() {
  local STRING=$1
  echo -n "$STRING "
  shift
  "$@" && success || failure
  local rc=$?
  echo
  return $rc
}

# 函数，判断命令是否正常执行
if_success() {
  local message_success=$1
  local message_failure=$2
  local return_status=${3:-0}  # 如果 \$3 未设置或为空，则默认为 0
  
  if [ "$return_status" -eq 0 ]; then
    action "$message_success" /bin/true
  else
    action "$message_failure" /bin/false
    exit 1
  fi
}

# 定义路径变量
Server_Dir="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
Conf_Dir="$Server_Dir/conf"
Log_Dir="$Server_Dir/logs"

# 关闭clash服务
close_clash_service() {
  local pid_num=$(pgrep -c clash-linux)
  local pid=$(pgrep clash-linux)
  local return_status=0
  
  if [ "$pid_num" -ne 0 ]; then
    kill "$pid" &>/dev/null
    return_status=$?
  fi
  
  if_success "服务关闭成功！" "服务关闭失败！" "$return_status"
}

# 获取CPU架构
get_cpu_arch() {
  if /bin/arch &>/dev/null; then
    echo $(/bin/arch)
  elif /usr/bin/arch &>/dev/null; then
    echo $(/usr/bin/arch)
  elif /bin/uname -m &>/dev/null; then
    echo $(/bin/uname -m)
  else
    echo -e "${RED}[ERROR] Failed to obtain CPU architecture!${NC}"
    exit 1
  fi
}

# 启动clash服务
start_clash_service() {
  local cpu_arch=$(get_cpu_arch)
  local clash_binary
  
  case $cpu_arch in
    x86_64)
      clash_binary="clash-linux-amd64"
      ;;
    aarch64|arm64)
      clash_binary="clash-linux-arm64"
      ;;
    armv7)
      clash_binary="clash-linux-armv7"
      ;;
    *)
      echo -e "${RED}[ERROR] Unsupported CPU Architecture!${NC}"
      exit 1
      ;;
  esac
  
  nohup "$Server_Dir/bin/$clash_binary" -d "$Conf_Dir" &> "$Log_Dir/clash.log" &
  local return_status=$?
  
  if_success "服务启动成功！" "服务启动失败！" "$return_status"
}

# 主程序
main() {
  close_clash_service
  sleep 3
  start_clash_service
}

main