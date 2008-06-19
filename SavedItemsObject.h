//
//  untitled.h
//  SSHTunnel
//
//  Created by Antoine Mercadal on 02/06/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SavedItemsObject : NSTask <NSCoding> {
	NSString	*sessionName;
	NSString	*localPort;
	NSString	*remoteHost;
	NSString	*remotePort;
	NSDate		*startDate;	
	NSTask		*sshTask;
	NSPipe		*stdOut;
	NSString	*outputContent;
	id			delegate;
	int			isStillRunning;	
	//BOOL		hasPassphrase;
}

@property(readwrite, copy)	NSTask		*sshTask;
@property(readwrite, copy)	NSString	*sessionName;
@property(readwrite, copy)	NSString	*localPort;
@property(readwrite, copy)	NSString	*remoteHost;
@property(readwrite, copy)	NSString	*remotePort;
@property(readwrite, copy)	NSDate		*startDate;
@property(readwrite,assign)	id			delegate;
@property(readwrite)		int			isStillRunning;
//@property(readwrite)		BOOL		hasPassphrase;

- (void) openTunnelWithUsername:(NSString *)username Host:(NSString *)tunnelHost Password:(NSString *)password;
- (void) closeTunnel;
- (void) checkShStatus:(NSNotification *) notification;
- (void) listernerForSSHTunnelDown:(NSNotification *)notification;

@end
