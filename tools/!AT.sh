#!/bin/bash

# 询问用户输入文件名（不需要扩展名）
read -p "输入文件名（不需要扩展名）: " name

# 将文件名与 .sh 扩展名合并，并读取该文件的第三行
file="tools/${name}.sh"
if [ -f "$file" ]; then
    addname=$(sed -n '3p' "$file")  # 获取文件的第三行
    addname=$(echo "$addname" | sed 's/^#//')  # 将开头的 # 替换为空格
else
    echo "错误: 文件 $file 未找到。"
    exit 1
fi

# 将 "变量name. addname" 写入 !tools.txt 的最后一行
if [ -f "tools/!tools.txt" ]; then
    echo "$name. $addname" >> "tools/!tools.txt"
    echo "已将 '$name. $addname' 写入 !tools.txt 的最后一行。"
else
    echo "错误: !tools.txt 文件未找到。"
fi