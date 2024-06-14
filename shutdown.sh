#!/bin/bash

# 关闭clash服务
PID_NUM=`ps -ef | grep [c]lash-linux-a | wc -l`
PID=`ps -ef | grep [c]lash-linux-a | awk '{print $2}'`
if [ $PID_NUM -ne 0 ]; then
	kill -9 $PID
	# ps -ef | grep [c]lash-linux-a | awk '{print $2}' | xargs kill -9
fi

# 清除环境变量

# 定义要删除的函数名
functions_to_remove=("proxy_on" "proxy_off")

# 遍历函数名数组
for func in "${functions_to_remove[@]}"; do
    # 使用sed命令删除函数定义及其结束
    sed -i -E "/^function[[:space:]]+${func}[[:space:]]*()/,/^}$/d" ~/.bashrc
done

sed -i "/^# 开启系统代理/d" ~/.bashrc
sed -i "/^# 关闭系统代理/d" ~/.bashrc

# 重新加载.bashrc文件
source ~/.bashrc

echo "已重新加载.bashrc文件。"


echo -e "\n服务关闭成功，请执行以下命令关闭系统代理：proxy_off\n"
