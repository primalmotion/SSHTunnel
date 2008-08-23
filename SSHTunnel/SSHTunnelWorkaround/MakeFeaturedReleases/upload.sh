#!/usr/bin/expect -f

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

set PASSWORDFILEPATH 	[exec cat "/Users/Tonio/Desktop/googlecode.pass"]
set USERNAME 			[lindex $argv 1]
set PROJECT 			[lindex $argv 2]
set SUMMARY				[lindex $argv 3]
set FILE				[lindex $argv 4]

set timeout 1
spawn python ./googlecode_upload.py -s $SUMMARY -p $PROJECT -u $USERNAME --config-dir=none $FILE
match_max 10000

set timeout -1
expect {
		"*?assword:*" {	send $PASSWORDFILEPATH; set timeout 4;}
}
expect eof;
