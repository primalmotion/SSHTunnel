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
	NSString	*userName;
	NSString	*tunnelHost;
	NSString	*localPort;
	NSString	*remoteHost;
	NSString	*remotePort;
	NSString	*password;
	NSDate		*startDate;	
	NSTask		*sshTask;
	NSPipe		*stdOut;
	NSTimer		*updateWheelTimer;
	id			delegate;
	int			isStillRunning;	
}

@property(readwrite, copy)	NSTask		*sshTask;
@property(readwrite, copy)	NSString	*sessionName;
@property(readwrite, copy)	NSString	*userName;
@property(readwrite, copy)	NSString	*tunnelHost;
@property(readwrite, copy)	NSString	*localPort;
@property(readwrite, copy)	NSString	*remoteHost;
@property(readwrite, copy)	NSString	*remotePort;
@property(readwrite, copy)	NSString	*password;
@property(readwrite, copy)	NSDate		*startDate;
@property(readwrite, copy)	NSTimer		*updateWheelTimer;
@property(readwrite,assign)	id			delegate;
@property(readwrite)		int			isStillRunning;

- (void) openTunnel;
- (void) closeTunnel;
@end
