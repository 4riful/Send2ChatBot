#!/bin/bash
#!writtenby_xettabyte
CONFIG=config.yaml
hname=$(hostname)

function send_message() {
    local target_type=$1
    local format=$2
    local webhook_url=$3
    local chat_id=$4
    local api_key=$5
    local parsemode=$6

    local payload=""
    local url=""

    if [ "$target_type" == "telegram" ]; then
        payload="chat_id=$chat_id&text=$format&parse_mode=$parsemode"
        url="https://api.telegram.org/bot$api_key/sendMessage"
    elif [ "$target_type" == "discord" ]; then
        payload="{\"username\": \"$USER\", \"content\": \"$format\"}"
        url="$webhook_url"
    fi

    response=$(curl --progress-bar -o /dev/null -w "%{http_code}" -X POST -d "$payload" "$url")
    if [ "$response" -ne 200 ]; then
        echo "Failed to send message to $target_type. Response code: $response"
    fi
}

# Read the configuration file and send messages
while IFS= read -r line; do
    if [[ "$line" =~ "discord_format: " ]]; then
        discord_format="${line#discord_format: }"
    elif [[ "$line" =~ "discord_webhook_url: " ]]; then
        discord_webhook_url="${line#discord_webhook_url: }"
    elif [[ "$line" =~ "discord_channel: " ]]; then
        discord_channel="${line#discord_channel: }"
    elif [[ "$line" =~ "discord_username: " ]]; then
        discord_username="${line#discord_username: }"
    elif [[ "$line" =~ "telegram_format: " ]]; then
        telegram_format="${line#telegram_format: }"
    elif [[ "$line" =~ "telegram_webhook_url: " ]]; then
        telegram_webhook_url="${line#telegram_webhook_url: }"
    elif [[ "$line" =~ "telegram_chat_id: " ]]; then
        telegram_chat_id="${line#telegram_chat_id: }"
    elif [[ "$line" =~ "telegram_api_key: " ]]; then
        telegram_api_key="${line#telegram_api_key: }"
    elif [[ "$line" =~ "telegram_parsemode: " ]]; then
        telegram_parsemode="${line#telegram_parsemode: }"
    fi

    if [ "$line" == "" ]; then
        current_id=""
        if [ "$discord_format" != "" ] && [ "$discord_webhook_url" != "" ] && [ "$discord_channel" != "" ]; then
            current_id="discord"
        fi
        if [ "$telegram_format" != "" ] && [ "$telegram_webhook_url" != "" ] && [ "$telegram_chat_id" != "" ]; then
            if [ "$current_id" == "" ]; then
                current_id="telegram"
            else
                current_id="both"
            fi
        fi

        if [ "$current_id" != "" ]; then
            case "$current_id" in
                "discord") send_message "discord" "$discord_format" "$discord_webhook_url" "" "" "" ;;
                "telegram") send_message "telegram" "$telegram_format" "$telegram_webhook_url" "$telegram_chat_id" "$telegram_api_key" "$telegram_parsemode" ;;
                "both")
                    send_message "discord" "$discord_format" "$discord_webhook_url" "" "" ""
                    send_message "telegram" "$telegram_format" "$telegram_webhook_url" "$telegram_chat_id" "$telegram_api_key" "$telegram_parsemode"
                    ;;
            esac
        fi

        # Reset variables
        discord_format=""
        discord_webhook_url=""
        discord_channel=""
        discord_username=""
        telegram_format=""
        telegram_webhook_url=""
        telegram_chat_id=""
        telegram_api_key=""
        telegram_parsemode=""
    fi
done < "$CONFIG"

# Check for a file argument and send the file
if [ -z "$1" ]; then
    echo "Usage: $0 [-t | -d] <file_path>"
else
    while getopts ":td" opt; do
        case $opt in
            t)
                send_message "telegram" "$hname sent a file: $1" "$telegram_webhook_url" "$telegram_chat_id" "$telegram_api_key" "$telegram_parsemode"
                ;;
            d)
                send_message "discord" "$discord_format" "$discord_webhook_url" "" "" ""
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                echo "Usage: $0 [-t | -d] <file_path>"
                exit 1
                ;;
        esac
    done

    echo -e "\nFile sent successfully."
fi

