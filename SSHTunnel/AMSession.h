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

#import <Foundation/Foundation.h>


@interface AMSession : NSObject <NSCoding> {
	NSString	*sessionName;
	NSString	*localPort;
	NSString	*remoteHost;
	NSString	*remotePort;	
	NSString	*statusImagePath;
	BOOL		connected;
	BOOL		connectionInProgress;
	
	NSString	*outputContent;
	NSTask		*sshTask;
	NSPipe		*stdOut;
}
@property(readwrite, copy)		NSString	*sessionName;
@property(readwrite, copy)		NSString	*localPort;
@property(readwrite, copy)		NSString	*remoteHost;
@property(readwrite, copy)		NSString	*remotePort;
@property(readwrite, copy)		NSString	*statusImagePath;
@property(readwrite)			BOOL		connected;
@property(readwrite)			BOOL		connectionInProgress;

- (void) openTunnelWithUsername:(NSString *)username Host:(NSString *)tunnelHost Port:(NSString*)port Password:(NSString *)password;
- (void) closeTunnel;
- (void) checkShStatus:(NSNotification *) notification;
- (void) listernerForSSHTunnelDown:(NSNotification *)notification;

@end
