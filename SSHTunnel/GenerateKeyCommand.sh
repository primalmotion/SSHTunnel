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


set passPhrase [lrange $argv 0 0]

spawn ssh-keygen -t dsa -N "$passPhrase" 
match_max 100000
set timeout 5
expect {
	"*y/n*" {send "y\r"; exp_continue};
	"Enter file in which to save the key*" {send "\r";exp_continue};
}
