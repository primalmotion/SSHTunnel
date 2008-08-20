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

#import "messages.h"

#import "AMServer.h";
#import "AMService.h";

@interface AMSession : NSObject <NSCoding> {
	NSString	*sessionName;
	NSString	*remoteHost;
	AMService	*portsMap;	
	NSString	*statusImagePath;
	NSString	*tunnelTypeImagePath;
	AMServer	*currentServer;
	NSInteger	sessionTunnelType;
	BOOL		connected;
	BOOL		connectionInProgress;
	NSString	*connectionLink;
	NSString	*dynamicProxyPort;
	BOOL		useDynamicProxy;
	
	NSString	*outputContent;
	NSTask		*sshTask;
	NSPipe		*stdOut;
}
@property(readwrite, assign)	AMServer	*currentServer;
@property(readwrite, assign)	AMService	*portsMap;
@property(readwrite, assign)	NSString	*sessionName;
@property(readwrite, assign)	NSString	*remoteHost;
@property(readwrite, assign)	NSString	*statusImagePath;
@property(readwrite, assign)	NSString	*tunnelTypeImagePath;
@property(readwrite, assign)	NSString	*connectionLink;
@property(readwrite, assign)	NSString	*dynamicProxyPort;
@property(readwrite)			BOOL		useDynamicProxy;
@property(readwrite)			BOOL		connected;
@property(readwrite)			BOOL		connectionInProgress;
@property(readwrite)			NSInteger	sessionTunnelType;


#pragma mark Control methods
- (void) openTunnel;
- (void) closeTunnel;

#pragma mark Observers and delegates
- (void) checkShStatus:(NSNotification *) notification;
- (void) listernerForSSHTunnelDown:(NSNotification *)notification;

#pragma mark Helper methods
- (NSMutableArray *) parsePortsSequence:(NSString*)seq;
- (NSMutableString *) prepareSSHCommandWithRemotePorts:(NSMutableArray *)remotePorts localPorts:(NSMutableArray *)localPorts;
- (void)setProxyEnableForThisSession:(BOOL)enabled onPort:(NSString*)port;


@end
