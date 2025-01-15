#!/bin/bash

echo "欢迎使用Uninstall ME!"

# 获取脚本所在的目录和文件名
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
SCRIPT_NAME=$(basename "$0")

# 询问目标目录
read -p "请输入目标目录: " target_dir

# 检查目录是否存在
if [ ! -d "$target_dir" ]; then
    echo "目录不存在，请重新运行脚本并输入有效的目录。"
    exit 1
fi

# 检查目标目录是否是脚本所在目录
if [ "$target_dir" == "$SCRIPT_DIR" ]; then
    echo "错误：不能删除脚本所在的目录。"
    exit 1
fi

# 询问文件扩展名
read -p "请输入要删除的文件扩展名（例如：txt）: " file_extension

# 确认操作
read -p "你确定要删除目录 $target_dir 及其子目录中所有 .$file_extension 文件吗？(1: 是, 0: 否): " confirm1
read -p "请再次确认 (1: 是, 0: 否): " confirm2

# 检查两次确认
if [ "$confirm1" == "1" ] && [ "$confirm2" == "1" ]; then
    # 查找并删除文件，排除脚本自身和其他 Bash 脚本
    find "$target_dir" -type f -name "*.$file_extension" ! -path "$SCRIPT_DIR/*" ! -name "$SCRIPT_NAME" ! -name "*.sh" -exec rm -v {} \;
    echo "文件删除完成。"
else
    echo "操作已取消。"
    exit 0
fi