#!/bin/bash

CONFIG_FILE="config.yaml"
MAX_DISCORD_FILE_SIZE=25000000
LOADING_CHARS="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"  # Characters for loading animation
HOSTNAME=$(hostname)  # Get the hostname of the system

# Dracula color codes
DRACULA_PURPLE="\e[0;35m"
DRACULA_CYAN="\e[0;36m"
DRACULA_ORANGE="\e[0;33m"
DRACULA_GREEN="\e[0;32m"
DRACULA_RESET="\e[0m"

function send_message_to_telegram() {
    local file_path="$1"
    TELEGRAM_API_KEY=$(grep 'api_key' $CONFIG_FILE | awk '{print $2}' | sed 's/"//g')
    TELEGRAM_CHAT_ID=$(grep 'chat_id' $CONFIG_FILE | awk '{print $2}' | sed 's/"//g')
    
    if [ ! -f "$file_path" ]; then
        echo -e "${DRACULA_ORANGE}❌ Error:${DRACULA_RESET} File not found: $file_path"
        exit 1
    fi

    file_name=$(basename "$file_path")
    
    # Actual Telegram sending logic using curl
    curl -s -F document=@"$file_path" "https://api.telegram.org/bot$TELEGRAM_API_KEY/sendDocument?chat_id=$TELEGRAM_CHAT_ID" > /dev/null
    echo -e "${DRACULA_GREEN}✅ Success:${DRACULA_RESET} File sent successfully to Telegram from $HOSTNAME: $file_name"
}

function send_file_to_discord() {
    local file_path="$1"
    DISCORD_WEBHOOK_URL=$(grep 'webhook_url' $CONFIG_FILE | awk '{print $2}' | sed 's/"//g')
    
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
    echo -e "\b${DRACULA_GREEN}✅ Done!${DRACULA_RESET}"
    
    # Actual Discord sending logic using curl
    curl -F file=@"$file_path" "$DISCORD_WEBHOOK_URL" > /dev/null
    echo -e "${DRACULA_GREEN}✅ Success:${DRACULA_RESET} File sent successfully to Discord from $HOSTNAME: $file_name"
}

function print_usage() {
    echo "Usage: $0 [-t | -d] <file_path>"
    echo "Options:"
    echo "  -t  Send the file to Telegram"
    echo "  -d  Send the file to Discord"
}

# Customize the output messages with colors
echo -e "${DRACULA_PURPLE}🔗 Send2ChatBot: Share files effortlessly${DRACULA_RESET}"
echo -e "${DRACULA_CYAN}------------------------------------------------${DRACULA_RESET}"

if [ -z "$1" ]; then
    echo -e "${DRACULA_ORANGE}❌ Error:${DRACULA_RESET} No flag specified."
    print_usage
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${DRACULA_ORANGE}❌ Error:${DRACULA_RESET} Config file '$CONFIG_FILE' not found."
    exit 1
fi

case $1 in
    -t)
        echo -e "${DRACULA_CYAN}📤 Sending to Telegram...${DRACULA_RESET}"
        send_message_to_telegram "$2"
        ;;
    -d)
        echo -e "${DRACULA_CYAN}📤 Sending to Discord...${DRACULA_RESET}"
        send_file_to_discord "$2"
        ;;
    *)
        # Check if both configurations are available
        TELEGRAM_API_KEY=$(grep 'api_key' $CONFIG_FILE | awk '{print $2}' | sed 's/"//g')
        DISCORD_WEBHOOK_URL=$(grep 'webhook_url' $CONFIG_FILE | awk '{print $2}' | sed 's/"//g')
        if [ -n "$TELEGRAM_API_KEY" ] && [ -n "$DISCORD_WEBHOOK_URL" ]; then
            echo -e "${DRACULA_ORANGE}❓ Info:${DRACULA_RESET} No flag specified. Sending to both Telegram and Discord..."
            send_message_to_telegram "$1"
            send_file_to_discord "$1"
        else
            echo -e "${DRACULA_ORANGE}❌ Error:${DRACULA_RESET} No valid configuration found for Telegram or Discord."
            print_usage
            exit 1
        fi
        ;;
esac
