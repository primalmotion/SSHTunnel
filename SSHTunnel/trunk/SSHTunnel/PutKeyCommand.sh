#!/usr/bin/expect -f
#!/bin/sh

set localPath [lrange $argv 0 0]
set username [lrange $argv 1 1]
set tunnelHost [lrange $argv 2 2]
set password [lrange $argv 3 3 ]
set sessionName [lrange $argv 4 4]

spawn scp $localPath $username@$tunnelHost:~/.ssh/$sessionName
match_max 100000
set timeout -1
expect {
		"?sh: Error*" {puts "CONNECTION_ERROR"; exit};
		"*yes/no*" {send "yes\r"; exp_continue};
		"*?assword:*" {	send "$password\r"; set timeout 4;
						expect "*?assword:*" {puts "WRONG_PASSWORD"; exit;}
					  };
}

spawn ssh $username@$tunnelHost "cat ~/.ssh/$sessionName >> ~/.ssh/authorized_keys"
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
