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

set PASSWORDFILEPATH 	[exec cat "/Users/Tonio/Documents/Perso/Dev/googlecode.pass"]
set USERNAME 			"antoine.mercadal"
set PROJECT 			"cocoa-sshtunnel"
set SUMMARY				[exec cat FeaturedSummary.txt]
set FILE				"build/Bundle/${VOLNAME}-${DATE}.dmg"

puts $FILE
set timeout -1
spawn ./SSHTunnelWorkaround/MakeFeaturedReleases/googlecode_upload.py -s $SUMMARY -p $PROJECT -u $USERNAME --config-dir=none $FILE
match_max 10000
expect {
		"Password:*" {	send "$PASSWORDFILEPATH\r"; };
}
expect eof;
