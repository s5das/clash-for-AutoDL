#!/bin/bash

# 获取脚本工作目录绝对路径
export Server_Dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

set +m  # 关闭监视模式，不再报告后台作业状态

# 关闭clash服务
PID_NUM=`ps -ef | grep [c]lash-linux-a | wc -l`
PID=`ps -ef | grep [c]lash-linux-a | awk '{print $2}'`
if [ $PID_NUM -ne 0 ]; then
	kill -9 $PID
	# ps -ef | grep [c]lash-linux-a | awk '{print $2}' | xargs kill -9
fi
# 杀死遗留clash进程
lsof -i :7890 -i :7891 -i :7892 -i :6006 | awk 'NR!=1 {print $2}' | xargs -r kill

# 清除环境变量
unset http_proxy
unset https_proxy
unset no_proxy
unset HTTP_PROXY
unset HTTPS_PROXY
unset NO_PROXY

# 定义要删除的函数名
functions_to_remove=("proxy_on" "proxy_off")

# 遍历函数名数组
for func in "${functions_to_remove[@]}"; do
    # 使用sed命令删除函数定义及其结束
    sed -i -E "/^function[[:space:]]+${func}[[:space:]]*()/,/^}$/d" ~/.bashrc
done

sed -i "/^# 开启系统代理/d" ~/.bashrc
sed -i "/^# 关闭系统代理/d" ~/.bashrc

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