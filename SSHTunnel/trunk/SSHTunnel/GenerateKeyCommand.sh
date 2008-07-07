#!/usr/bin/expect -f
#!/bin/sh

set passPhrase [lrange $argv 0 0]

spawn ssh-keygen -t dsa -N "$passPhrase" 
match_max 100000
set timeout 5
expect {
	"*y/n*" {send "y\r"; exp_continue};
	"Enter file in which to save the key*" {send "\r";exp_continue};
}
