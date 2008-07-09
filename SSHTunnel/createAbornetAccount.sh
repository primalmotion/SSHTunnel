#!/usr/bin/expect -f
#!/bin/sh

set login [lrange $argv 0 0]
set password [lrange $argv 1 1]

spawn telnet m-net.arbornet.org
match_max 1000000

set timeout -1
expect {
		"*login:*" {send "newuser\r"; exp_continue};
		"*Press any key to Continue*" {send "\r"; exp_continue};
		"*Please press your backspace key*" {send "\r"; exp_continue};
		"*Enter your login name:*" {send "$login\r"; exp_continue};
		"*Sorry, that name is in use.  Please choose another name.*" {puts "LOGIN_EXISTS"; exit};
		"*Enter your full name:*" {send "no\r"; exp_continue};
		"*Enter your password*" {send "$password\r"; exp_continue};
		"*Enter the shell you want (? for a list)*" {send "bash\r"; exp_continue};
		"*Enter the editor you want (? for a list)*" {send "pico\r"; exp_continue};
		"*Enter your email address:*" {send "\r"; exp_continue};
		"*Enter your occupation:*" {send "\r"; exp_continue};
		"*Enter your gender:*" {send "\r"; exp_continue};
		"*Enter your birthday:*" {send "\r"; exp_continue};
		"*Enter letter of the field to change, or just press ENTER if done:*" {send "\r"; exp_continue};
		"*Your new M-Net account has been created!*" {puts "LOGIN_CREATED"; exit};
		"Password:*" {puts "LOGIN_CREATED"; exit};
}

set timeout -1
expect eof;

