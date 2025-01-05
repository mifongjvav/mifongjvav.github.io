#!/bin/bash

echo "欢迎使用Minecraft Super Underworld teleportation calculator"

# 询问用户输入始发地x, z坐标以及传送次数
read -p "输入始发地x坐标: " X
read -p "输入始发地z坐标: " Z
read -p "输入传送次数: " T

# 计算X2和Z2（T乘以8后再乘以X或Z）
X2=$((X * (T * 8)))
Z2=$((Z * (T * 8)))

# 计算X和Z的差值
X=$((X2 - X))
Z=$((Z2 - Z))

# 检查目标距离是否超出限制
if [ $X2 -ge 3749984 ] || [ $X2 -le -3749984 ] || [ $Z2 -ge 3749984 ] || [ $Z2 -le -3749984 ]; then
    echo "目标距离超出29999872，传送时无法达到指定坐标"
else
    echo "目标地点为：$X2 $Z2"
    echo "本次超传传送距离为：$X $Z"
fi