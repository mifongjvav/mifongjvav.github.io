#!/bin/bash

echo "欢迎使用How much the fuck did this mace hurt?"
# 询问用户输入下落高度 h
read -p "请输入下落高度 (h): " h

# 检查 h 是否大于 0
if (( $(echo "$h <= 0" | bc -l) )); then
    echo "错误：下落高度必须大于 0。"
    exit 1
fi

# 询问用户输入致密魔咒等级 p
read -p "请输入致密魔咒等级 (p): " p

# 检查 p 是否大于 0
if (( $(echo "$p <= 0" | bc -l) )); then
    echo "错误：致密魔咒等级必须大于 0。"
    exit 1
fi

# 计算 min{6, 2h}
min1=$(( 2 * h < 6 ? 2 * h : 6 ))

# 计算 min{8, h}
min2=$(( h < 8 ? h : 8 ))

# 计算 (1 + 0.5p) * h
term3=$(echo "scale=2; (1 + 0.5 * $p) * $h" | bc)

# 计算总伤害
damage=$(echo "scale=2; $min1 + $min2 + $term3" | bc)

# 输出结果
echo "计算的伤害为: $damage"