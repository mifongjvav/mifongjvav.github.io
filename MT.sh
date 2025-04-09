#!/bin/bash
# MT.sh - 主程序入口
# 版本: 4.2

source MT_C11_library.sh || {
    echo "错误：无法加载基础库" >&2
    exit 1
}

# 检查并显示公告（修复版）
if check_notice; then
    show_notice
fi

run_tool_mode() {
    local ret=0
    while true; do
        clear
        echo "=== 浏览目录: ${CURRENT_BROWSE_PATH/$TOOLS_DIR\//} ==="
        
        generate_dir_list
        echo "----------------------"
        echo "x. 返回主菜单"
        
        read -p "请选择: " choice
        
        case "$choice" in
            x) 
                CURRENT_BROWSE_PATH="$TOOLS_DIR"
                PATH_STACK=()
                return
                ;;
            *)
                if [[ "$choice" =~ ^[0-9]+$ ]]; then
                    handle_selection "$choice"
                    ret=$?
                    [ $ret -eq 2 ] && read -p "按回车键返回..."
                else
                    echo "无效输入"
                    sleep 1
                fi
                ;;
        esac
    done
}

main_menu() {
    while true; do
        clear
        echo "=== Mine Tools 4.2 ==="
        echo "1. 运行工具"
        echo "2. 运行DFW下载器"
        echo "3. 检查主程序更新"
        echo "4. 检查C11 API "
        echo "5. 退出"
        
        read -p "请选择: " choice
        case "$choice" in
            1) run_tool_mode ;;
            2) bash "$TOOLS_DIR/!DFW.sh" ;;
            3) check_update ;;
            4)
                update_library
                case $? in
                    2) 
                        read -p "库已更新，按回车键退出程序..."
                        exit 0
                        ;;
                    1)
                        read -p "更新失败，按回车键返回..."
                        ;;
                esac
                ;;
            5) 
                echo "See ya next time!"
                exit 0
                ;;
            *) 
                echo "无效选择"
                sleep 1
                ;;
        esac
    done
}

main_menu