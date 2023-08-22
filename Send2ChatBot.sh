#!/bin/bash

DEFAULT_CONFIG_FILE="config.yaml"
MAX_DISCORD_FILE_SIZE=25000000
LOADING_CHARS="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"  # Characters for loading animation
HOSTNAME=$(hostname)  # Get the hostname of the system

# Dracula color codes
DRACULA_PURPLE="\e[0;35m"
DRACULA_CYAN="\e[0;36m"
DRACULA_ORANGE="\e[0;33m"
DRACULA_GREEN="\e[0;32m"
DRACULA_RED="\e[0;31m"
DRACULA_RESET="\e[0m"

CONFIG_FILE="$DEFAULT_CONFIG_FILE"  # Default configuration file

function send_message_to_telegram() {
    local file_path="$1"
    TELEGRAM_API_KEY=$(grep 'api_key' $CONFIG_FILE | awk '{print $2}' | sed 's/"//g')
    TELEGRAM_CHAT_ID=$(grep 'chat_id' $CONFIG_FILE | awk '{print $2}' | sed 's/"//g')

    if [ -z "$TELEGRAM_API_KEY" ] || [ -z "$TELEGRAM_CHAT_ID" ]; then
        echo -e "${DRACULA_ORANGE}❌ Error:${DRACULA_RESET} Telegram configuration is missing or incomplete."
        exit 1
    fi

    if [ ! -f "$file_path" ]; then
        echo -e "${DRACULA_ORANGE}❌ Error:${DRACULA_RESET} File not found: $file_path"
        exit 1
    fi

    file_name=$(basename "$file_path")

    # Actual Telegram sending logic using curl
    response=$(curl -s -F document=@"$file_path" "https://api.telegram.org/bot$TELEGRAM_API_KEY/sendDocument?chat_id=$TELEGRAM_CHAT_ID")
    
    if [[ "$response" == *"\"ok\":false"* ]]; then
        echo -e "${DRACULA_RED}❌ Error:${DRACULA_RESET} Failed to send file to Telegram."
    else
        echo -e "${DRACULA_GREEN}✅ Success:${DRACULA_RESET} File sent successfully to Telegram from $HOSTNAME: $file_name"
    fi
}

function send_file_to_discord() {
    local file_path="$1"
    DISCORD_WEBHOOK_URL=$(grep 'webhook_url' $CONFIG_FILE | awk '{print $2}' | sed 's/"//g')

    if [ -z "$DISCORD_WEBHOOK_URL" ]; then
        echo -e "${DRACULA_ORANGE}❌ Error:${DRACULA_RESET} Discord configuration is missing or incomplete."
        exit 1
    fi

    if [ ! -f "$file_path" ]; then
        echo -e "${DRACULA_ORANGE}❌ Error:${DRACULA_RESET} File not found: $file_path"
        exit 1
    fi

    file_name=$(basename "$file_path")
    file_size=$(stat -c %s "$file_path")

    if [ "$file_size" -gt "$MAX_DISCORD_FILE_SIZE" ]; then
        echo -e "${DRACULA_ORANGE}⚠️ Warning:${DRACULA_RESET} File size is larger than 25 MB. Consider sending via Telegram."
    fi

    # Display loading animation for Discord
    echo -en "${DRACULA_CYAN}🚀 Sending to Discord:${DRACULA_RESET} "
    for ((i=0; i<10; i++)); do
        echo -n "${LOADING_CHARS:i%10:1}"
        sleep 0.1
        echo -ne "\b"
    done

    # Actual Discord sending logic using curl
    response=$(curl -s -o /dev/null -w "%{http_code}" -F file=@"$file_path" "$DISCORD_WEBHOOK_URL")

    if [ "$response" -ne 200 ]; then
        echo -e "\b${DRACULA_RED}❌ Error:${DRACULA_RESET} Failed to send file to Discord. Response code: $response"
    else
        echo -e "\b${DRACULA_GREEN}✅ Success:${DRACULA_RESET} File sent successfully to Discord from $HOSTNAME: $file_name"
    fi
}

function print_usage() {
    echo "Usage: $0 [-t | -d] [-c config_file] <file_path>"
    echo "Options:"
    echo "  -t              Send the file to Telegram"
    echo "  -d              Send the file to Discord"
    echo "  -c config_file  Specify a different configuration file (default: config.yaml)"
}

# Parse command line arguments
while getopts ":tdc:" opt; do
    case $opt in
        t)
            action="telegram"
            ;;
        d)
            action="discord"
            ;;
        c)
            CONFIG_FILE="$OPTARG"
            ;;
        \?)
            echo -e "${DRACULA_ORANGE}❌ Error:${DRACULA_RESET} Invalid option: -$OPTARG"
            print_usage
            exit 1
            ;;
        :)
            echo -e "${DRACULA_ORANGE}❌ Error:${DRACULA_RESET} Option -$OPTARG requires an argument."
            print_usage
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

# Customize the output messages with colors
echo -e "${DRACULA_PURPLE}🔗 Send2ChatBot: Share files effortlessly${DRACULA_RESET}"
echo -e "${DRACULA_CYAN}------------------------------------------------${DRACULA_RESET}"

# Add alias to use the script globally
echo -e "${DRACULA_ORANGE}🌟 Tip:${DRACULA_RESET} To use this script globally, you can create an alias like:"
echo -e "${DRACULA_CYAN}    alias s2b='$PWD/Send2ChatBot.sh'${DRACULA_RESET}"

if [ -z "$action" ]; then
    echo -e "${DRACULA_ORANGE}❌ Error:${DRACULA_RESET} No flag specified."
    print_usage
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${DRACULA_ORANGE}❌ Error:${DRACULA_RESET} Config file '$CONFIG_FILE' not found."
    exit 1
fi

case "$action" in
    telegram)
        echo -e "${DRACULA_CYAN}📤 Sending to Telegram...${DRACULA_RESET}"
        send_message_to_telegram "$1"
        ;;
    discord)
        echo -e "${DRACULA_CYAN}📤 Sending to Discord...${DRACULA_RESET}"
        send_file_to_discord "$1"
        ;;
esac
