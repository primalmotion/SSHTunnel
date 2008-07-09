#!/usr/bin/expect -f
#!/bin/sh

set localPort [lrange $argv 0 0]
set remoteHost [lrange $argv 1 1]
set remotePort [lrange $argv 2 2]
set username [lrange $argv 3 3]
set tunnelHost [lrange $argv 4 4]
set password [lrange $argv 5 5 ]
set serverPort [lrange $argv 6 6 ]

spawn ssh -N -L$localPort:$remoteHost:$remotePort $username@$tunnelHost -p $serverPort  -R *:$localPort:host:hostport
match_max 100000

set timeout 1
#expect  "*yes/no*" {send "yes\r"; exp_continue};

set timeout -1
expect {
		"?sh: Error*" {puts "CONNECTION_ERROR"; exit};
		"*yes/no*" {send "yes\r"; exp_continue};
		"*Connection refused*" {puts "CONNECTION_REFUSED"; exit};
		"*?assword:*" {	send "$password\r"; set timeout 4;
						expect "*?assword:*" {puts "WRONG_PASSWORD"; exit;}
					  };
}

puts "CONNECTED";
set timeout -1
expect eof;

