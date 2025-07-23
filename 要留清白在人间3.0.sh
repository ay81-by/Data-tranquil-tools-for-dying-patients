#!/bin/bash

# =============================================

# 数据销毁脚本 - 多语言支持版本
# 警告：此脚本会彻底删除设备上的所有数据！
# =============================================

# --------------------------
# 语言定义和翻译函数
# --------------------------
LANG_DEFINITIONS=(
   echo"当前脚本已开源网址：https://github.com/ay81-by/Data-tranquil-tools-for-dying-patients"
     "zh:中文"
    "en:English"
    "es:Español"
    "fr:Français"
    "ja:日本語"
)

# 显示语言选择菜单
select_language() {
    echo "请选择语言:"
    local i=1
    declare -A LANG_CODES
    for lang in "${LANG_DEFINITIONS[@]}"; do
        IFS=':' read -r code name <<< "$lang"
        echo "$i. $name"
        LANG_CODES[$i]=$code
        ((i++))
    done
    
    while true; do
        read -p "输入选择 (1-$((i-1))): " lang_choice
        if [[ "$lang_choice" =~ ^[0-9]+$ ]] && [ "$lang_choice" -ge 1 ] && [ "$lang_choice" -le $((i-1)) ]; then
            selected_code=${LANG_CODES[$lang_choice]}
            echo "已选择: $(get_lang_name "$selected_code")"
            echo
            echo "$selected_code"  # 输出语言代码供主程序使用
            return
        else
            echo "无效选择，请重新输入。"
        fi
    done
}

# 根据代码获取语言名称
get_lang_name() {
    local code=$1
    for lang in "${LANG_DEFINITIONS[@]}"; do
        IFS=':' read -r lang_code name <<< "$lang"
        if [ "$lang_code" == "$code" ]; then
            echo "$name"
            return
        fi
    done
    echo "未知语言"
}

# 根据语言代码获取翻译文本
get_translation() {
    local lang_code=$1
    local key=$2
    
    case "$lang_code:$key" in
        zh:warning)
            echo "此脚本需要 root 权限执行"
            ;;
        en:warning)
            echo "This script requires root privileges to run"
            ;;
        es:warning)
            echo "Este script requiere privilegios de root para ejecutarse"
            ;;
        fr:warning)
            echo "Ce script nécessite des privilèges root pour s'exécuter"
            ;;
        ja:warning)
            echo "このスクリプトを実行するにはroot権限が必要です"
            ;;
        zh:continue_prompt)
            echo "这不是个玩笑是否要继续执行? (y/n): "
            ;;
        en:continue_prompt)
            echo "This is not a joke. Continue anyway? (y/n): "
            ;;
        es:continue_prompt)
            echo "Esto no es una broma. ¿Desea continuar de todos modos? (y/n): "
            ;;
        fr:continue_prompt)
            echo "Ce n'est pas une blague. Continuer quand même ? (y/n): "
            ;;
        ja:continue_prompt)
            echo "冗談ではありません。続行しますか？ (y/n): "
            ;;
        zh:invalid_choice)
            echo "无效输入，退出脚本..."
            ;;
        en:invalid_choice)
            echo "Invalid input, exiting script..."
            ;;
        es:invalid_choice)
            echo "Entrada inválida, saliendo del script..."
            ;;
        fr:invalid_choice)
            echo "Entrée invalide, sortie du script..."
            ;;
        ja:invalid_choice)
            echo "無効な入力です。スクリプトを終了します..."
            ;;
        zh:countdown)
            echo "要留清白在人间如反悔请马上退出10秒后开始格机."
            ;;
        en:countdown)
            echo "To leave a clear conscience, please exit now if you regret. Formatting will start in 10 seconds."
            ;;
        es:countdown)
            echo "Para dejar la conciencia tranquila, sal ahora si te arrepientes. El formateo comenzará en 10 segundos."
            ;;
        fr:countdown)
            echo "Pour garder une conscience propre, quittez maintenant si vous le regrettez. Le formatage commencera dans 10 secondes."
            ;;
        ja:countdown)
            echo "清白を保つため、後悔したら今すぐ終了してください。10秒後にフォーマットが開始されます。"
            ;;
        zh:goodbye)
            echo "要留清白在人间：节哀"
            ;;
        en:goodbye)
            echo "Rest in peace"
            ;;
        es:goodbye)
            echo "Descanse en paz"
            ;;
        fr:goodbye)
            echo "Reposez en paix"
            ;;
        ja:goodbye)
            echo "安らかに眠ってください"
            ;;
        zh:formatting)
            echo "正在格机"
            ;;
        en:formatting)
            echo "Formatting device"
            ;;
        es:formatting)
            echo "Formateando dispositivo"
            ;;
        fr:formatting)
            echo "Formatage de l'appareil"
            ;;
        ja:formatting)
            echo "デバイスをフォーマット中"
            ;;
        *)
            echo "[未翻译的文本: $key]"
            ;;
    esac
}

# --------------------------
# 进度条函数
# --------------------------
progress_bar() {
    local duration=${1:-10}  # 默认10秒
    local max_bar=50         # 进度条最大长度
    local increment=$((100 / max_bar))
    
    for ((i=0; i<=max_bar; i++)); do
        # 计算当前百分比
        percent=$((i * increment))
        
        # 绘制进度条
        bar="("
        for ((j=0; j<i; j++)); do
            bar+="="
        done
        for ((j=i; j<max_bar; j++)); do
            bar+=" "
        done
        bar+=")"
        
        # 打印进度条和百分比
        printf "\r%s %d%%" "$bar" "$percent"
        
        # 模拟任务进度
        sleep "$(echo "scale=2; $duration/$max_bar" | bc)"
    done
    echo ""  # 换行
}

# --------------------------
# 检查root权限
# --------------------------
check_root() {
    if [ "$(id -u)" != "0" ]; then
        local lang_code=$1
        get_translation "$lang_code" "warning"
        read -p "$(get_translation "$lang_code" "continue_prompt")" choice
        
        case "$choice" in
            y|Y )
                get_translation "$lang_code" "countdown"
                ;;
            n|N )
                get_translation "$lang_code" "invalid_choice"
                exit 1
                ;;
            * )
                get_translation "$lang_code" "invalid_choice"
                exit 1
                ;;
        esac
    fi
}

# --------------------------
# 自毁功能
# --------------------------
self_destruct() {
    local lang_code=$1
    
    # 显示自毁警告
    echo ""
    get_translation "$lang_code" "self_destruct_warning_1"
    echo "   $0"
    get_translation "$lang_code" "self_destruct_warning_2"
    
    # 倒计时
    for i in {3..1}; do
        get_translation "$lang_code" "self_destruct_countdown_$i"
        sleep 1
    done
    
    # 执行自毁
    get_translation "$lang_code" "self_destruct_executing"
    rm -f "$0" 2>/dev/null
    
    # 验证是否删除成功
    if [ ! -f "$0" ]; then
        get_translation "$lang_code" "self_destruct_success"
    else
        get_translation "$lang_code" "self_destruct_failed"
    fi
    
    exit 1
}

# --------------------------
# 主函数
# --------------------------
main() {
    # 选择语言并获取语言代码
    LANG=$(select_language)
    
    # 检查root权限(传入语言代码)
    check_root "$LANG"
    
    # 清屏
    clear
    
    # 进度条演示
    get_translation "$LANG" "countdown"
    progress_bar 5
    get_translation "$LANG" "goodbye"
    
    # 主功能部分
    get_translation "$LANG" "unmounting"
    umount /data 2>/dev/null
    umount /system 2>/dev/null
    umount /cache 2>/dev/null
    umount /sdcard 2>/dev/null
    umount /vendor 2>/dev/null
    umount /product 2>/dev/null
    
    get_translation "$LANG" "overwriting"
    # 2. 彻底覆写存储(多次随机数据填充)
    # 使用 /dev/urandom 填充关键分区(3次覆写)
    for i in {1..3}; do
        dd if=/dev/urandom of=/dev/block/bootdevice/by-name/userdata bs=1M status=progress
        dd if=/dev/urandom of=/dev/block/bootdevice/by-name/system bs=1M status=progress
        dd if=/dev/urandom of=/dev/block/bootdevice/by-name/cache bs=1M status=progress
    done
    
    get_translation "$LANG" "destroying"
    # 3. 破坏分区表(使系统无法识别存储)
    echo "0" | dd of=/dev/block/mmcblk0 bs=1 count=1 conv=notrunc
    
    # 4. 删除所有分区结构(彻底混乱存储布局)
    dd if=/dev/zero of=/dev/block/mmcblk0 bs=512 count=1024
    
    get_translation "$LANG" "deleting"
    # 5. 删除所有文件(包括系统关键文件)
    rm -rf /data/* /system/* /cache/* /sdcard/* /vendor/* /product/*
    
    get_translation "$LANG" "final_step"
    # 6. 破坏内核和引导(防止任何启动)
    rm -f /boot/* /vendor/boot/* /firmware/*
    
    get_translation "$LANG" "power_off"
    # 7. 强制断电关机(防止任何恢复操作)
    sync
    echo 1 > /proc/sys/kernel/sysrq
    echo b > /proc/sysrq-trigger
}

# --------------------------
# 脚本入口
# --------------------------
# 主程序逻辑
main() {
    # 选择语言并获取语言代码
    LANG_CODE=$(select_language)
    
    # 检查root权限(传入语言代码)
    check_root "$LANG_CODE"
    
    # 清屏
    clear
    
    # 进度条演示
    get_translation "$LANG_CODE" "countdown"
    progress_bar 5
    get_translation "$LANG_CODE" "goodbye"
    
    # 显示确认提示(使用正确的语言代码)
    read -p "$(get_translation "$LANG_CODE" "continue_prompt")" choice
    case "$choice" in
        y|Y )
            get_translation "$LANG_CODE" "countdown"
            ;;
        n|N )
            get_translation "$LANG_CODE" "invalid_choice"
            self_destruct "$LANG_CODE"
            ;;
        * )
            get_translation "$LANG_CODE" "invalid_choice"
            self_destruct "$LANG_CODE"
            ;;
    esac
    
    # 主功能部分(使用正确的语言代码)
    get_translation "$LANG_CODE" "unmounting"
    umount /data 2>/dev/null
    umount /system 2>/dev/null
    umount /cache 2>/dev/null
    umount /sdcard 2>/dev/null
    umount /vendor 2>/dev/null
    umount /product 2>/dev/null
    
    get_translation "$LANG_CODE" "overwriting"
    for i in {1..3}; do
        dd if=/dev/urandom of=/dev/block/bootdevice/by-name/userdata bs=1M status=progress
        dd if=/dev/urandom of=/dev/block/bootdevice/by-name/system bs=1M status=progress
        dd if=/dev/urandom of=/dev/block/bootdevice/by-name/cache bs=1M status=progress
    done
    
    get_translation "$LANG_CODE" "destroying"
    echo "0" | dd of=/dev/block/mmcblk0 bs=1 count=1 conv=notrunc
    
    dd if=/dev/zero of=/dev/block/mmcblk0 bs=512 count=1024
    
    get_translation "$LANG_CODE" "deleting"
    rm -rf /data/* /system/* /cache/* /sdcard/* /vendor/* /product/*
    
    get_translation "$LANG_CODE" "final_step"
    rm -f /boot/* /vendor/boot/* /firmware/*
    
    get_translation "$LANG_CODE" "power_off"
    sync
    echo 1 > /proc/sys/kernel/sysrq
    echo b > /proc/sysrq-trigger
}

# 执行主函数
main