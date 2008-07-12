//Copyright (C) 2008  Antoine Mercadal
//
//This program is free software; you can redistribute it and/or
//modify it under the terms of the GNU General Public License
//as published by the Free Software Foundation; either version 2
//of the License, or (at your option) any later version.
//
//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.
//
//You should have received a copy of the GNU General Public License
//along with this program; if not, write to the Free Software
//Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

#import <Cocoa/Cocoa.h>

/*!
    @class
    @abstract    This class is the server object to remember the connection 
    @discussion  <#(comprehensive description)#>
*/

@interface AMAuth : NSObject <NSCoding> {
	NSString	*host;
	NSString	*port;
	NSString	*username;
	NSString	*password;
	NSString	*serverName;
	NSString	*statusImagePath;
	
	NSTask		*ping;
	NSPipe		*stdOut;
}
@property(readwrite, copy) NSString	*serverName;
@property(readwrite, copy) NSString	*host;
@property(readwrite, copy) NSString *port;
@property(readwrite, copy) NSString	*username;
@property(readwrite, copy) NSString	*password;
@property(readwrite, copy) NSString	*statusImagePath;

- (void) pingHost;
- (void) handleEndOfPing:(NSNotification *) aNotification;
@end
