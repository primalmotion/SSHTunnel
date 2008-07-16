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
#import "AMAuth.h"

@interface AMSession : NSObject <NSCoding> {
	NSString	*sessionName;
	NSString	*localPort;
	NSString	*remoteHost;
	NSString	*remotePort;	
	NSString	*statusImagePath;
	AMAuth		*currentServer;
	NSInteger	outgoingTunnel;
	BOOL		connected;
	BOOL		connectionInProgress;
	
	NSString	*outputContent;
	NSTask		*sshTask;
	NSPipe		*stdOut;
}
@property(readwrite, assign)	AMAuth		*currentServer;
@property(readwrite, assign)	NSString	*sessionName;
@property(readwrite, assign)	NSString	*localPort;
@property(readwrite, assign)	NSString	*remoteHost;
@property(readwrite, assign)	NSString	*remotePort;
@property(readwrite, assign)	NSString	*statusImagePath;
@property(readwrite)			BOOL		connected;
@property(readwrite)			BOOL		connectionInProgress;
@property(readwrite, assign)	NSInteger	outgoingTunnel;

- (void) openTunnel;
- (void) closeTunnel;
- (void) checkShStatus:(NSNotification *) notification;
- (void) listernerForSSHTunnelDown:(NSNotification *)notification;

@end
