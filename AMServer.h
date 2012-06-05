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

@interface AMServer : NSObject <NSCoding> 
{
	NSString	*password;
	NSString	*port;
	NSString	*serverName;
	NSString	*statusImagePath;
	NSString	*username;
	NSString	*host;
	NSPipe		*standartOutput;
	NSPipe		*standartInput;
	NSPipe		*stdOut;
	NSTask		*ping;
}
@property(readwrite, assign) NSString	*host;
@property(readwrite, assign) NSString	*password;
@property(readwrite, assign) NSString	*port;
@property(readwrite, assign) NSString	*serverName;
@property(readwrite, assign) NSString	*statusImagePath;
@property(readwrite, assign) NSString	*username;
@property(readwrite, assign) NSPipe		*standartOutput;
@property(readwrite, assign) NSPipe		*standartInput;


#pragma mark -
#pragma mark Helper methods
- (void) pingHost;

#pragma mark -
#pragma mark Observers and delegates
- (void) handleEndOfPing:(NSNotification *) aNotification;
- (void) openShellOnThisServer;

@end
