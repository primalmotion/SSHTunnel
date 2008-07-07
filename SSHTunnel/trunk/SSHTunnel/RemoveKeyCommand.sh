#!/usr/bin/expect -f
#!/bin/sh

set username [lrange $argv 0 0]
set tunnelHost [lrange $argv 1 1]
set password [lrange $argv 2 2 ]



spawn ssh $username@$tunnelHost "rm ~/.ssh/authorized_keys"
match_max 100000
set timeout 4
expect {
		"?sh: Error*" {puts "CONNECTION_ERROR"; exit};
		"*yes/no*" {send "yes\r"; exp_continue};
		"*?assword:*" {	send "$password\r"; set timeout 4;
						expect "*?assword:*" {puts "WRONG_PASSWORD"; exit;}
					  };
}
puts "bye";
