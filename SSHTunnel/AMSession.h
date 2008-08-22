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


@interface AMSession : NSObject <NSCoding> 
{
	AMServer 		*currentServer;
	AMService		*portsMap;	
	BOOL			autostart;
	BOOL			connected;
	BOOL			connectionInProgress;
	BOOL			isGroup;
	BOOL			isLeaf;
	BOOL			useDynamicProxy;
	NSInteger		sessionTunnelType;
	NSMutableArray 	*childrens;
	NSPipe 			*stdOut;
	NSString 		*connectionLink;
	NSString 		*globalProxyPort;
	NSString 		*outputContent;
	NSString 		*remoteHost;
	NSString 		*sessionName;
	NSString 		*statusImagePath;
	NSString 		*tunnelTypeImagePath;
	NSTask			*sshTask;

}
@property(readwrite)			BOOL				autostart;
@property(readwrite)			BOOL				isGroup;
@property(readwrite)			BOOL				isLeaf;
@property(readwrite)			BOOL				connected;
@property(readwrite)			BOOL				connectionInProgress;
@property(readwrite)			BOOL				useDynamicProxy;
@property(readwrite)			NSInteger			sessionTunnelType;
@property(readwrite, assign)	AMServer 			*currentServer;
@property(readwrite, assign)	AMService 			*portsMap;
@property(readwrite, assign)	NSMutableArray		*childrens;
@property(readwrite, assign)	NSString 			*connectionLink;
@property(readwrite, assign)	NSString 			*globalProxyPort;
@property(readwrite, assign)	NSString 			*remoteHost;
@property(readwrite, assign)	NSString 			*sessionName;
@property(readwrite, assign)	NSString 			*statusImagePath;
@property(readwrite, assign)	NSString 			*tunnelTypeImagePath;


#pragma mark -
#pragma mark Control methods
- (void) closeTunnel;
- (void) openTunnel;

#pragma mark -
#pragma mark Observers and delegates
- (void) handleProcessusExecution:(NSNotification *) notification;
- (void) listernerForSSHTunnelDown:(NSNotification *)notification;

#pragma mark -
#pragma mark Helper methods
- (NSMutableArray *) parsePortsSequence:(NSString*)seq;
- (NSMutableString *) prepareSSHCommandWithRemotePorts:(NSMutableArray *)remotePorts localPorts:(NSMutableArray *)localPorts;
- (void) setProxyEnableForThisSession:(BOOL)enabled onPort:(NSString*)port;


@end
