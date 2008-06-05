//
//  untitled.m
//  SSHTunnel
//
//  Created by Antoine Mercadal on 02/06/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import "SavedItemsObject.h"

@implementation SavedItemsObject

@synthesize	sessionName;
@synthesize userName;
@synthesize tunnelHost;
@synthesize localPort;
@synthesize remoteHost;
@synthesize remotePort;
@synthesize sshTask;
@synthesize password;
@synthesize setIsStillRunning;
@synthesize startDate;
@synthesize updateWheelTimer;
@synthesize delegate;

- (id) init
{
	[super init];
	[self setIsReallyActive:0];
	return self;
}

- (void) dealloc
{
	if ([sshTask isRunning] == YES)
	{
		[[self sshTask] terminate];
		sshTask = nil;
	}
	[super dealloc];
}

- (void) checkShStatus:(NSTimer *)theTimer
{
	NSData		*data;
	NSString	*string;
	NSPredicate *checkError;
	NSPredicate *checkWrongPass;
	NSPredicate *checkConnected;
	
	data			= [[stdOut fileHandleForReading] availableData];
	string			= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	checkError		= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'CONNECTION_ERROR'"];
	checkWrongPass	= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'WRONG_PASSWORD'"];
	checkConnected	= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'CONNECTED'"];
	
	if ([checkError evaluateWithObject:string] == YES)
	{
		[self setIsStillRunning: 0];
		[[self sshTask] terminate];
		[[self delegate] performSelector:@selector(errorPanelDisplaywithMessage:) 
							  withObject:[@"Can't connect. The host address might be misspelled for session " 
												stringByAppendingString:sessionName]];
	}
	else if ([checkWrongPass evaluateWithObject:string] == YES)
	{
		[self setIsStillRunning:0];
		[[self sshTask] terminate];
		[[self delegate] performSelector:@selector(errorPanelDisplaywithMessage:) 
							  withObject:[@"Can't connect. The given password was rejected for session " 
												stringByAppendingString:sessionName]];
	}
	else if ([checkConnected evaluateWithObject:string] == YES)
	{
		[self setIsStillRunning:1];
		[[self delegate] performSelector:@selector(errorPanelDisplaywithMessage:) 
							  withObject:[@"Tunnel is ready for session " stringByAppendingString:sessionName]];
	}
	[delegate performSelector:@selector(setWheelValue:) withObject:[NSNumber numberWithDouble:100.0f]];
	[delegate performSelector:@selector(stopWheel)];
	[delegate performSelector:@selector(updateList)];
	
	[[self updateWheelTimer] invalidate];
}

- (void)openTunnel
{
	
	NSString *helperPath;
	NSArray *args;
	
	stdOut		= [NSPipe pipe];
	sshTask		= [[NSTask alloc] init];
	helperPath	= [[NSBundle mainBundle] pathForResource:@"SSHCommand" ofType:@"sh"];
	args		= [NSArray arrayWithObjects:localPort, remoteHost, remotePort, userName, tunnelHost, password, nil];
	
	[[self sshTask] setLaunchPath:helperPath];
	[[self sshTask] setArguments:args];
	[[self sshTask] setStandardOutput:stdOut];
	startDate = [NSDate date];
	[sshTask launch];

	[NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(checkShStatus:) userInfo:NULL repeats:NO];
	updateWheelTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(incrementIndicator:) userInfo:NULL repeats:YES];

	[self setIsReallyActive:2];
	
	[delegate performSelector:@selector(startWheel)];
}

- (void) closeTunnel
{
	[sshTask terminate];
	sshTask = nil;
	[self setIsStillRunning:0];
}



- (void) incrementIndicator:(NSTimer *)theTimer
{
	[delegate performSelector:@selector(incrementWheelValue)];
}


- (id) initWithCoder:(NSCoder *)coder
{
	[super init];
	
	sessionName	= [[coder decodeObjectForKey:@"MVsessionName"] retain];
	tunnelHost	= [[coder decodeObjectForKey:@"MVtunnelHost"] retain];
	userName	= [[coder decodeObjectForKey:@"MVuserName"] retain];
	localPort	= [[coder decodeObjectForKey:@"MVlocalPort"] retain];
	remoteHost	= [[coder decodeObjectForKey:@"MVremoteHost"] retain];
	remotePort	= [[coder decodeObjectForKey:@"MVremotePort"] retain];
	password	= [[coder decodeObjectForKey:@"MVpassword"] retain];
	//delegate	= [[coder decodeObjectForKey:@"MVdelegate"] retain];
	[self setIsStillRunning:0];	
	return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{	
	[coder encodeObject:sessionName forKey:@"MVsessionName"];
	[coder encodeObject:tunnelHost forKey:@"MVtunnelHost"];
	[coder encodeObject:userName forKey:@"MVuserName"];
	[coder encodeObject:localPort forKey:@"MVlocalPort"];
	[coder encodeObject:remoteHost forKey:@"MVremoteHost"];
	[coder encodeObject:remotePort forKey:@"MVremotePort"];
	[coder encodeObject:password forKey:@"MVpassword"];
	//[coder encodeObject:delegate forKey:@"MVdelegate"];
}
@end
