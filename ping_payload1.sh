#!/bin/bash
#This script is used to ping an address with a text in data field of the ICMP message.
#Provide the IP of the ping machine and the text, the script will automatically convert to hex and place in message
#Requires 2 arguements

# Check if correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <IP_ADDRESS> <TEXT_TO_CONVERT>"
    exit 1
fi

# Assign arguments to variables
IP_ADDRESS=$1
TEXT_TO_CONVERT=$2

# Convert the text to hex
HEX_PAYLOAD=$(echo -n "$TEXT_TO_CONVERT" | xxd -p)

# Send the ping with the hex payload
ping -c 1 "$IP_ADDRESS" -p "$HEX_PAYLOAD"
