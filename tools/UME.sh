#!/bin/bash

echo "欢迎使用Uninstall ME!"
# 询问目标目录
read -p "请输入目标目录（输入/0表示当前目录）: " target_dir

# 如果输入为/0，则设置为当前目录
if [ "$target_dir" == "/0" ]; then
    target_dir=$(pwd)
fi

# 检查目录是否存在
if [ ! -d "$target_dir" ]; then
    echo "目录不存在，请重新运行脚本并输入有效的目录。"
    exit 1
fi

# 询问文件扩展名
read -p "请输入要删除的文件扩展名（例如：txt）: " file_extension

# 确认操作
read -p "你确定要删除目录 $target_dir 及其子目录中所有 .$file_extension 文件吗？(1: 是, 0: 否): " confirm1
read -p "请再次确认 (1: 是, 0: 否): " confirm2

# 检查两次确认
if [ "$confirm1" == "1" ] && [ "$confirm2" == "1" ]; then
    # 查找并删除文件
    find "$target_dir" -type f -name "*.$file_extension" -exec rm -v {} \;
    echo "文件删除完成。"
else
    echo "操作已取消。"
    exit 0
fi