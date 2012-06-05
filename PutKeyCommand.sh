#!/usr/bin/expect -f
#!/bin/sh
# Copyright (C) 2008  Antoine Mercadal
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.


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
