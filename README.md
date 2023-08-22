<div align="center">
  <img src="assets/send2chatbot-logot.png" alt="Send2ChatBot Logo" width="200" height="200">
</div>

# Send2ChatBot 🤖

[![GitHub stars](https://img.shields.io/github/stars/4riful/Send2ChatBot)](https://github.com/4riful/Send2ChatBot/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/4riful/Send2ChatBot)](https://github.com/4riful/Send2ChatBot/issues)

Send2ChatBot is a versatile 🌟 Bash script that simplifies the process of sending messages and files to popular chatbot platforms, including Telegram and Discord. This script provides an intuitive command-line interface for seamless communication with your audience.

<p align="center">
  <img src="assets/send2chatbot-demo.gif" alt="Send2ChatBot Demo" width="600">
</p>

## Features 🚀

- **Cross-Platform Messaging:** Effortlessly send messages and files to both Telegram and Discord.
- **Customizable Configuration:** Configure API keys, chat IDs, and webhooks via the user-friendly `config.yaml` file.
- **Intuitive Usage:** A command-line interface that accommodates a wide range of users.
- **Visual Feedback:** A built-in progress indicator for monitoring file uploads.

## Getting Started 🛠️

### Prerequisites 📋

- Bash shell (usually available by default on Linux and macOS)

### Installation ⚙️

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/your-username/Send2ChatBot.git

  ### Configure `config.yaml`:

Create a configuration file named `config.yaml` in the `~/.custom_path/` directory. Fill in the necessary details for both Telegram and Discord:

```yaml
telegram:
  api_key: "YOUR_TELEGRAM_API_KEY"
  chat_id: "YOUR_TELEGRAM_CHAT_ID"

discord:
  webhook_url: "YOUR_DISCORD_WEBHOOK_URL"
```
### Make the Script Executable:
```
chmod +x Send2ChatBot.sh
```
## Usage 📦
```bash
To send a file to Telegram:
./Send2ChatBot.sh -t /path/to/your/file.txt

To send a file to Discord:
./Send2ChatBot.sh -d /path/to/your/file.txt

To use a custom config file use -c flag 
./Send2ChatBot.sh -d -c custom_config.yaml /path/to/your/file.txt
```

Use the following flags to specify the destination:

- `-t`: Send the file to Telegram.
- `-d`: Send the file to Discord.
- No flag: If configurations exist for both platforms, the file will be sent to both.
[![asciicast](https://asciinema.org/a/E4QrxzzJh0erpKEO0n3wyYZNX.svg)](https://asciinema.org/a/E4QrxzzJh0erpKEO0n3wyYZNX) 



**Note:** Before using the script to send messages and files, ensure that you've properly configured your `config.yaml` file with the necessary API keys, chat IDs, and webhook URLs. Make sure to replace `/path/to/your/file.txt` with the actual path to the file you want to send.

## Contributing 👥

Contributions are welcome! Feel free to open issues and submit pull requests.

## License 📄


This project is licensed under the [MIT License](LICENSE).

