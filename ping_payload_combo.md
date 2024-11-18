Yes, you can combine the `echo` and `ping` commands into one step by piping the output of the `echo` command directly into `xxd` for hex conversion, and then using `ping` with the resulting hex string. Here's how you can do it:

```bash
ping -c 1 -p $(echo -n "test" | xxd -p)
```

### Explanation:
1. `echo -n "test"`: This echoes the string `"test"` without a trailing newline (`-n` flag prevents the newline).
2. `xxd -p`: This converts the string `"test"` into a hexadecimal string (`74657374`).
3. `$(...)`: This command substitution syntax allows the result of the `echo` and `xxd` combination to be used as the argument for the `ping` command.
4. `ping -c 1 -p`: The `ping` command sends one ICMP packet with the hex-encoded data you generated.

### What happens:
The `echo` command converts the string `"test"` into its hexadecimal representation (`74657374`), and that hexadecimal string is directly passed to the `ping` command using the `-p` option to send the payload as part of the ICMP request.

If you run this, the ping will include the hex representation of `"test"` as its payload.
