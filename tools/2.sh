#!/bin/bash

# 输出欢迎信息
echo "欢迎使用What Minecraft time is it"

# 询问用户输入类型
echo "请输入类型（GT为1，RT为2，D为3）"
read type

# 根据用户输入的类型进行不同的计算
if [ "$type" -eq 1 ]; then
    echo "请输入GT"
    read GT
    RT=$(echo "scale=2; $GT / 2" | bc)  # 使用 bc 进行浮点数运算
    D=$(echo "scale=2; $GT / 24000" | bc)
    echo "GT:$GT RT:$RT D:$D"

elif [ "$type" -eq 2 ]; then
    echo "请输入RT"
    read RT
    GT=$(echo "scale=2; $RT * 2" | bc)
    D=$(echo "scale=2; $RT / 12000" | bc)
    echo "GT:$GT RT:$RT D:$D"

elif [ "$type" -eq 3 ]; then
    echo "请输入D"
    read D
    GT=$(echo "scale=2; $D * 24000" | bc)
    RT=$(echo "scale=2; $D * 12000" | bc)
    echo "GT:$GT RT:$RT D:$D"

else
    echo "无效的输入类型"
fi