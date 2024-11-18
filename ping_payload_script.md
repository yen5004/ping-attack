You can create a script that takes the IP address and the text string as inputs, and then converts the string to hex and sends the ping with the corresponding payload. Here's a simple Bash script that does that:

### Create the Script

1. Open your text editor and create a new file called `ping_hex.sh`.

2. Add the following code to the script:

```bash
#!/bin/bash

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
```

### Explanation:

- `#!/bin/bash`: This is the shebang, telling the system to use Bash to execute the script.
- `if [ "$#" -ne 2 ]; then`: This checks if exactly two arguments (IP address and text) are provided. If not, it prints the usage message and exits.
- `IP_ADDRESS=$1` and `TEXT_TO_CONVERT=$2`: These store the first and second command-line arguments (the IP address and the text to convert) into variables.
- `HEX_PAYLOAD=$(echo -n "$TEXT_TO_CONVERT" | xxd -p)`: This converts the text to its hexadecimal form and stores it in the variable `HEX_PAYLOAD`.
- `ping -c 1 "$IP_ADDRESS" -p "$HEX_PAYLOAD"`: This sends the ping with the hex payload.

### Make the Script Executable

Before you can run the script, you'll need to make it executable. In the terminal, run:

```bash
chmod +x ping_hex.sh
```

### Run the Script

Now you can run the script by providing an IP address and a text string:

```bash
./ping_hex.sh 192.168.1.5 "test"
```

This will send a ping to `192.168.1.5` with the hex-encoded string `"test"`. The string `"test"` will be converted to hex (`74657374`) and sent as the payload in the ICMP packet.

### Example:

```bash
./ping_hex.sh 192.168.1.5 "hello"
```

This would ping `192.168.1.5` with the hex payload for `"hello"`, which is `68656c6c6f`.

Let me know if you need any further customization!
