#!/bin/bash

# 检查设置文件中是否存在 NTFT 字段
check_ntft() {
    if [ -f "!SET.txt" ]; then
        if grep -q '^NTFT:' "!SET.txt"; then
            return 0  # NTFT 字段存在
        fi
    fi
    return 1  # NTFT 字段不存在
}

# 询问用户是否同意协议
ask_eula() {
    # 显示 EULA 内容
    if [ -f "EULA.MD" ]; then
        cat EULA.MD
    else
        echo "错误：未找到用户协议文件。"
        exit 1
    fi

    # 提示用户输入
    while true; do
        read -p "如果您同意以上条款，请输入“Y”继续；否则请输入“N”退出: " eula_input
        case $eula_input in
            [Yy]* )
                echo "EULA:Y" >> !SET.txt
                echo "感谢您同意用户协议，程序将继续运行。"
                break
                ;;
            [Nn]* )
                echo "EULA:N" >> !SET.txt
                echo "您已拒绝用户协议，程序退出。"
                exit 1
                ;;
            * )
                echo "请输入 Y 或 N。"
                ;;
        esac
    done
}

# 定义需要下载的文件列表
declare -A FILES_TO_DOWNLOAD=(
    ["lang/zh_cn.lang"]="https://mifongjvav.github.io/lang/zh_cn.lang"  # 语言文件
    ["lang/zh_tw.lang"]="https://mifongjvav.github.io/lang/zh_tw.lang"  # 语言文件
    ["lang/zh_hk.lang"]="https://mifongjvav.github.io/lang/zh_hk.lang"  # 语言文件
    ["lang/en_us.lang"]="https://mifongjvav.github.io/lang/en_us.lang"  # 语言文件
    ["lang/ja_jp.lang"]="https://mifongjvav.github.io/lang/ja_jp.lang"  # 语言文件
    ["tools/1.sh"]="https://mifongjvav.github.io/tools/1.sh"           # 工具脚本
    ["tools/2.sh"]="https://mifongjvav.github.io/tools/2.sh"           # 工具脚本
    ["tools/3.sh"]="https://mifongjvav.github.io/tools/3.sh"           # 工具脚本
    ["tools/UME.sh"]="https://mifongjvav.github.io/tools/UME.sh"           # 工具脚本
    ["tools/!AT.sh"]="https://mifongjvav.github.io/tools/!AT.sh"       # AT 工具脚本
    ["tools/!DFW.sh"]="https://mifongjvav.github.io/tools/!DFW.sh"     # DFW 工具脚本
    ["tools/!tools.txt"]="https://mifongjvav.github.io/tools/!tools.txt" # 工具列表文件
)

# 首次启动时下载文件
initialize_files() {
    echo "首次启动，正在下载必要文件..."
    mkdir -p lang tools  # 创建 lang 和 tools 文件夹（如果不存在）

    for file_path in "${!FILES_TO_DOWNLOAD[@]}"; do
        url="${FILES_TO_DOWNLOAD[$file_path]}"
        echo "正在下载 $file_path..."
        wget -q "$url" -O "$file_path"
        if [ $? -eq 0 ]; then
            echo "下载成功: $file_path"
        else
            echo "下载失败: $file_path"
            exit 1
        fi
    done

    echo "NTFT:Y" >> !SET.txt  # 标记文件已初始化
    echo "所有文件下载完成。"
}

# 检查并创建 lang.txt 文件，并确保所有 lang 文件夹中的语言文件都有对应的条目
initialize_lang_file() {
    if [ ! -f "lang.txt" ]; then  # 如果 lang.txt 文件不存在
        echo "en_us=English (United States)" > lang.txt
        echo "ja_jp=日本語" >> lang.txt
        echo "zh_cn=简体中文" >> lang.txt
        echo "zh_tw=繁体中文（台湾）" >> lang.txt
        echo "zh_hk=繁体中文（香港）" >> lang.txt
        echo "已创建 lang.txt 文件并写入默认内容。"
    fi

    # 检查 lang 文件夹中的语言文件，确保每个文件都在 lang.txt 中有对应的条目
    for lang_file in lang/*.lang; do
        if [ -f "$lang_file" ]; then
            lang_name=$(basename "$lang_file" .lang)  # 去掉扩展名
            if ! grep -q "^$lang_name=" lang.txt; then  # 检查是否已存在
                echo "$lang_name=$lang_name" >> lang.txt  # 添加默认条目
                echo "已添加 $lang_name 到 lang.txt 文件。"
            fi
        fi
    done
}

# 加载语言文件
# 参数：$1 语言文件名（不需要扩展名）
load_language_file() {
    local lang_file="lang/$1.lang"  # 语言文件路径
    if [ -f "$lang_file" ]; then  # 检查语言文件是否存在
        # 逐行读取语言文件
        while IFS='=' read -r key value; do
            # 忽略空行和注释行（以 # 开头的行）
            if [[ ! -z "$key" && ! "$key" =~ ^"#" ]]; then
                # 去掉 value 中的注释部分（# 及其后面的内容）
                value=$(echo "$value" | cut -d'#' -f1 | xargs)
                # 将键值对赋值给变量
                eval "$key=\"$value\""
            fi
        done < "$lang_file"
    else
        echo "错误: 语言文件 $lang_file 未找到。"
        return 1  # 返回错误状态
    fi
}

# 获取语言文件名
# 参数：$1 用户输入的内容（可以是语言文件名或显示名称）
get_language_code() {
    local user_input="$1"
    local lang_code

    # 检查用户输入是否是语言文件名
    if grep -q "^$user_input=" lang.txt; then
        lang_code="$user_input"
    else
        # 检查用户输入是否是显示名称
        lang_code=$(grep "=$user_input$" lang.txt | cut -d'=' -f1)
        if [ -z "$lang_code" ]; then
            echo "未找到匹配的语言文件或显示名称。"
            return 1
        fi
    fi

    echo "$lang_code"
}

# 初始化默认语言
initialize_language() {
    if ! grep -q '^language:' "!SET.txt"; then  # 检查 language 字段是否存在
        echo "首次运行，请输入语言文件名或显示名称（例如 zh_cn 或 简体中文）："
        read -p "请输入语言文件名或显示名称: " lang_input  # 提示用户输入语言文件名或显示名称
        lang_code=$(get_language_code "$lang_input")
        if [ -z "$lang_code" ]; then
            echo "无法识别输入，默认使用 zh_cn。"
            language="zh_cn"
        else
            language="$lang_code"
        fi
        if load_language_file "$language"; then  # 尝试加载语言文件
            echo "language:$language" >> !SET.txt  # 将语言设置保存到 !SET.txt
            echo "语言设置已保存。"
        else
            echo "无法加载语言文件，默认使用 zh_cn。"
            language="zh_cn"  # 如果加载失败，默认使用 zh_cn
            load_language_file "$language"  # 加载默认语言文件
        fi
    else
        # 从 !SET.txt 中读取语言设置，忽略以 # 开头的行
        language=$(grep -v '^#' !SET.txt | grep 'language:' | cut -d':' -f2)
        if [ -z "$language" ] || ! load_language_file "$language"; then  # 检查语言设置是否有效
            echo "未找到有效的语言设置，默认使用 zh_cn。"
            language="zh_cn"  # 如果无效，默认使用 zh_cn
            load_language_file "$language"  # 加载默认语言文件
        fi
    fi
}

# 显示可用的语言列表
show_language_list() {
    echo "可用的语言列表："
    while IFS='=' read -r lang_code lang_name; do
        echo "$lang_code: $lang_name"
    done < lang.txt
}

# 主逻辑
if ! check_ntft; then
    ask_eula  # 询问用户是否同意协议
    initialize_files  # 下载支持库文件
fi

# 初始化 lang.txt 文件
initialize_lang_file

# 初始化语言
initialize_language

# 输出欢迎信息
echo "$welcome_message"

# 输出脚本启动的时间
echo "$script_start_time $(date)"

# 显示分隔线
echo "$separator"

# 提示用户输入运行模式
echo "$mode_selection_prompt"
echo "$mode_option_1"
echo "$mode_option_2"
echo "$mode_option_3"
echo "$mode_option_4"
echo "$exit"
read -p "$enter_tool_number_prompt" mode  # 读取用户输入的模式

# 根据用户输入执行相应操作
if [ "$mode" == "1" ]; then  # 模式 1：列出并运行工具
    echo "$tool_list_prompt"

    if [ -f "tools/!tools.txt" ]; then  # 检查工具列表文件是否存在
        grep -o '^[^#]*' "tools/!tools.txt"  # 列出可用的工具（忽略注释行）
    else
        echo "$file_not_found_error"  # 如果文件不存在，显示错误信息
    fi

    read -p "$enter_tool_name_prompt" tool_name  # 提示用户输入工具名称

    # 解析用户输入的路径
    file="tools/${tool_name}.sh"
    if [ -f "$file" ]; then  # 检查工具脚本是否存在
        bash "$file"  # 执行工具脚本
    else
        echo "$tool_not_found_error"  # 如果工具不存在，显示错误信息
    fi
elif [ "$mode" == "2" ]; then  # 模式 2：运行 AT 工具
    if [ -f "tools/!AT.sh" ]; then  # 检查 AT 工具脚本是否存在
        bash tools/!AT.sh  # 执行 AT 工具脚本
    else
        echo "$failed_to_start_error"  # 如果脚本不存在，显示错误信息
        exit  # 退出脚本
    fi
elif [ "$mode" == "3" ]; then  # 模式 3：运行 DFW 工具
    if [ -f "tools/!DFW.sh" ]; then  # 检查 DFW 工具脚本是否存在
        bash tools/!DFW.sh  # 执行 DFW 工具脚本
    else
        echo "$failed_to_start_error"  # 如果脚本不存在，显示错误信息
        exit  # 退出脚本
    fi
elif [ "$mode" == "4" ]; then  # 模式 4：更改语言
    show_language_list  # 显示可用的语言列表
    read -p "$change_language_prompt" lang_input  # 提示用户输入语言文件名或显示名称
    lang_code=$(get_language_code "$lang_input")
    if [ -z "$lang_code" ]; then
        echo "无法识别输入，语言设置保持不变。"
    else
        if load_language_file "$lang_code"; then  # 尝试加载新的语言文件
            language="$lang_code"  # 更新当前语言

            # 删除旧的 language: 行
            sed -i '/^language:/d' !SET.txt

            # 将新的语言设置保存到 !SET.txt
            echo "language:$language" >> !SET.txt

            echo "$language_set_saved"  # 提示语言设置已保存
        else
            echo "无法加载语言文件，当前语言保持不变。"  # 如果加载失败，提示用户
        fi
    fi
elif [ "$mode" == "5" ]; then  # 模式 5：退出脚本
    echo "$exit_yes"  # 提示用户正在退出
    exit  # 退出脚本
else
    echo "$invalid_input_prompt"  # 如果输入无效，提示用户
fi
