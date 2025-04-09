#!/bin/bash
# MT_C11_library - 脚本基本支持库C11 API
# 版本: 4.2
# 许可证: Apache 2.0

#######################################
# 初始化配置
#######################################
declare -g SCRIPT_URL="https://mifongjvav.github.io/MT.sh"
declare -g LIBRARY_URL="https://mifongjvav.github.io/MT_C11_library.sh"
declare -g TOOLS_DIR="./tools"
declare -g UPDATE_TIMEOUT=15

#######################################
# 公告系统（已修复）
#######################################
declare -g NOTICE_FILE=".notice_cache"
declare -g NOTICE_URL="https://mifongjvav.github.io/公告.txt"
declare -g LAST_CHECK_FILE=".last_notice_check"

check_notice() {
    # 24小时内不重复检查
    local current_time=$(date +%s)
    local last_check=0
    [ -f "$LAST_CHECK_FILE" ] && last_check=$(cat "$LAST_CHECK_FILE")
    (( current_time - last_check < 86400 )) && return 1

    echo $current_time > "$LAST_CHECK_FILE"
    
    # 使用curl替代wget增强兼容性
    if curl -s --connect-timeout 5 "$NOTICE_URL" -o "$NOTICE_FILE.new"; then
        if [ -s "$NOTICE_FILE.new" ]; then
            # 比较新旧公告内容
            if [ ! -f "$NOTICE_FILE" ] || ! cmp -s "$NOTICE_FILE" "$NOTICE_FILE.new"; then
                mv "$NOTICE_FILE.new" "$NOTICE_FILE"
                return 0
            fi
        fi
    fi
    rm -f "$NOTICE_FILE.new"
    return 1
}

show_notice() {
    [ ! -f "$NOTICE_FILE" ] && return
    clear
    echo -e "\033[44m=== 系统公告 ===\033[0m"
    cat "$NOTICE_FILE"
    echo -e "\033[44m================\033[0m"
    read -p "按回车键继续..." dummy
    rm -f "$NOTICE_FILE"
}

#######################################
# 目录浏览功能（纯净版）
#######################################
declare -g CURRENT_BROWSE_PATH="$TOOLS_DIR"
declare -g -a CURRENT_ITEMS=()

generate_dir_list() {
    CURRENT_ITEMS=()
    local counter=1
    
    # 返回上级选项
    [ "$CURRENT_BROWSE_PATH" != "$TOOLS_DIR" ] && echo "0. ↩ 返回上级"

    # 先显示目录
    while IFS= read -r dir; do
        echo "$counter. 📁 $(basename "$dir")"
        CURRENT_ITEMS+=("$dir")
        ((counter++))
    done < <(find "$CURRENT_BROWSE_PATH" -maxdepth 1 -mindepth 1 -type d | sort)

    # 再显示脚本文件（排除!开头的系统脚本）
    while IFS= read -r file; do
        local name=$(basename "$file" .sh)
        echo "$counter. 📄 $name"
        CURRENT_ITEMS+=("$file")
        ((counter++))
    done < <(find "$CURRENT_BROWSE_PATH" -maxdepth 1 -mindepth 1 -type f -name "*.sh" ! -name "!*" | sort)
}

handle_selection() {
    local choice="$1"
    
    case $choice in
        0)
            [ ${#PATH_STACK[@]} -gt 0 ] && {
                CURRENT_BROWSE_PATH="${PATH_STACK[-1]}"
                unset 'PATH_STACK[${#PATH_STACK[@]}-1]'
            }
            ;;
        *)
            local index=$((choice-1))
            if (( index >= 0 && index < ${#CURRENT_ITEMS[@]} )); then
                if [ -d "${CURRENT_ITEMS[$index]}" ]; then
                    PATH_STACK+=("$CURRENT_BROWSE_PATH")
                    CURRENT_BROWSE_PATH="${CURRENT_ITEMS[$index]}"
                else
                    bash "${CURRENT_ITEMS[$index]}"
                    return 2
                fi
            else
                echo "无效选择！"
                return 1
            fi
            ;;
    esac
    return 0
}

#######################################
# 更新功能
#######################################
safe_download() {
    if ! curl -s --connect-timeout $UPDATE_TIMEOUT --retry 2 "$1" -o "$2"; then
        echo "下载失败: $1" >&2
        return 1
    fi
    return 0
}

check_update() {
    echo "正在检查更新..."
    safe_download "$SCRIPT_URL" "MT.sh.tmp" && {
        if [ -f "MT.sh" ] && ! cmp -s "MT.sh" "MT.sh.tmp"; then
            mv "MT.sh" "MT.sh.bak"
            mv "MT.sh.tmp" "MT.sh"
            chmod +x "MT.sh"
            echo "更新完成，请重新运行"
            exit 0
        fi
        rm -f "MT.sh.tmp"
        echo "当前已是最新版本"
    }
}

#######################################
# 库更新功能
#######################################
update_library() {
    echo "正在检查库更新..."
    
    # 下载新版库文件
    if ! curl -s --connect-timeout 10 "$LIBRARY_URL" -o "MT_C11_library.tmp"; then
        echo "错误：无法下载库文件"
        return 1
    fi

    # 检查版本号是否更新
    local current_ver=$(grep -m1 "^# 版本:" "MT_C11_library.sh" | awk '{print $3}')
    local new_ver=$(grep -m1 "^# 版本:" "MT_C11_library.tmp" | awk '{print $3}')
    
    if [[ "$current_ver" == "$new_ver" ]]; then
        echo "已是最新版本 (v$current_ver)"
        rm -f "MT_C11_library.tmp"
        return 0
    fi

    # 执行更新
    echo "发现新版本: v$current_ver -> v$new_ver"
    echo "正在更新库文件..."
    
    # 创建备份
    cp "MT_C11_library.sh" "MT_C11_library.sh.bak" && \
    mv "MT_C11_library.tmp" "MT_C11_library.sh" && \
    chmod +x "MT_C11_library.sh" || {
        echo "更新失败！已恢复备份"
        mv "MT_C11_library.sh.bak" "MT_C11_library.sh"
        return 1
    }

    echo "库更新成功！"
    echo "请重新运行主程序加载新版本"
    return 2  # 需要重启的特殊返回码
}

#######################################
# 初始化
#######################################
mkdir -p "$TOOLS_DIR"