# Docker image basic required insstructions

OS=$(cat /etc/os-release | grep -E "^NAME=*" | cut -d = -f 2 | tr -d '"')
OS_VERSION=$(cat /etc/os-release | grep -E "^VERSION_ID=*" | cut -d = -f 2 | tr -d '"')

echo "Setup pre instructions..."

if [ "$OS" == "Ubuntu" ]; then
    apt-get update
    apt-get install -y wget git
elif [ "$OS" == "Alpine Linux" ]; then
    apk update
    apk add --no-cache wget git
else
    echo "Error. Please implement the pre-setup instructions for OS=$OS"
fi