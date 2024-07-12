#!/bin/bash

# 获取脚本工作目录绝对路径
export Server_Dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

set +m  # 关闭监视模式，不再报告后台作业状态

# 自定义action函数，实现通用action功能
success() {
  echo -en "\\033[60G[\\033[1;32m  OK  \\033[0;39m]\r"
  return 0
}

failure() {
  local rc=$?
  echo -en "\\033[60G[\\033[1;31mFAILED\\033[0;39m]\r"
  [ -x /bin/plymouth ] && /bin/plymouth --details
  return $rc
}

action() {
  local STRING rc

  STRING=$1
  echo -n "$STRING "
  shift
  "$@" && success $"$STRING" || failure $"$STRING"
  rc=$?
  echo
  return $rc
}

# 函数，判断命令是否正常执行
if_success() {
  local ReturnStatus=$3
  if [ "$ReturnStatus" -eq 0 ]; then
          action "$1" /bin/true
  else
          action "$2" /bin/false
          exit 1
  fi
}

# 函数：安全删除文件
safe_remove() {
    local file="$1"
    if [ -f "$file" ]; then
        rm "$file"
        echo "已删除文件: $file"
    else
        echo "文件不存在，跳过删除: $file"
    fi
}

## 关闭clash服务
Text1="clash进程关闭成功！"
Text2="clash进程关闭失败！"
# 查询并关闭程序进程
PID_NUM=$(ps -ef | grep [c]lash-linux | wc -l)
PID=$(ps -ef | grep [c]lash-linux | awk '{print $2}')
ReturnStatus=0
if [ "$PID_NUM" -ne 0 ]; then
  kill "$PID" &>/dev/null
  ReturnStatus=$?
  # ps -ef | grep [c]lash-linux-a | awk '{print $2}' | xargs kill -9
fi
if_success "$Text1" "$Text2" "$ReturnStatus"

# 定义路径变量
Server_Dir="$( cd "$( dirname "$(readlink -f "${BASH_SOURCE[0]}")" )" && pwd )"
Conf_Dir="$Server_Dir/conf"
Log_Dir="$Server_Dir/logs"

# 删除配置文件
safe_remove "$Conf_Dir/config.yaml"
# 删除缓存文件
safe_remove "$Conf_Dir/cache.db"
# 删除日志
rm -rf "$Log_Dir"

# 清除环境变量
unset http_proxy
unset https_proxy
unset no_proxy
unset HTTP_PROXY
unset HTTPS_PROXY
unset NO_PROXY

# 定义要删除的函数名
functions_to_remove=("proxy_on" "proxy_off" "shutdown_system")

# 遍历函数名数组
for func in "${functions_to_remove[@]}"; do
    # 使用sed命令删除函数定义及其结束
    sed -i -E "/^function[[:space:]]+${func}[[:space:]]*()/,/^}$/d" ~/.bashrc
done

sed -i "/^# 开启系统代理/d" ~/.bashrc
sed -i "/^# 关闭系统代理/d" ~/.bashrc
sed -i "/^# 新增关闭系统函数/d" ~/.bashrc
sed -i "/^# 检查clash进程是否正常启动/d" ~/.bashrc

# 删除自动执行 proxy_on 命令的行
sed -i "/proxy_on/d" ~/.bashrc

# 可能还需要删除与proxy_on相关的注释或空行，确保没有遗漏
sed -i "/^#.*proxy_on/d" ~/.bashrc  # 删除所有含 proxy_on 的注释行
sed -i '/^$/N;/^\n$/D' ~/.bashrc    # 删除连续的空行

# 重新加载.bashrc文件
source ~/.bashrc

echo -e "\033[32m \n[√]服务关闭成功\n \033[0m"

# 询问用户是否删除工作目录
read -p "是否删除工作目录 ${Server_Dir}? [y/n]: " answer
case $answer in
    [Yy]* )
        echo "正在删除工作目录 ${Server_Dir}..."
        rm -rf "$Server_Dir"
        echo "工作目录已删除。"
        ;;
    [Nn]* )
        echo "未删除工作目录。"
        ;;
    * )
        echo "请输入 'y' 或 'n'。"
        ;;
esac

set -m # 恢复监视模式