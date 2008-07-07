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
@synthesize localPort;
@synthesize remoteHost;
@synthesize remotePort;
@synthesize sshTask;
@synthesize isStillRunning;
@synthesize startDate;
@synthesize delegate;
//@synthesize hasPassphrase;

- (id) init
{
	[super init];
	[self setIsStillRunning:0];
	//[self setHasPassphrase:NO];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listernerForSSHTunnelDown:) 
												 name:@"NSTaskDidTerminateNotification" object:sshTask];
	return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	sessionName = nil;
	localPort = nil;
	remoteHost = nil;
	remotePort = nil;
	startDate = nil;
	stdOut = nil;
	
	if ([sshTask isRunning] == YES)
	{
		[[self sshTask] terminate];
		sshTask = nil;
	}
	
	[super dealloc];
}

/**
 * here is the part for timers 
 **/
- (void) checkShStatus:(NSNotification *) aNotification
{
	NSData		*data;
	NSPredicate *checkError;
	NSPredicate *checkWrongPass;
	NSPredicate *checkConnected;
	NSPredicate *checkRefused;
	NSPredicate *checkPort;
	
	data = [[aNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];
	
	// here are the predicates used to see the connection state
	outputContent	= [outputContent stringByAppendingString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
	checkError		= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'CONNECTION_ERROR'"];
	checkWrongPass	= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'WRONG_PASSWORD'"];
	checkConnected	= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'CONNECTED'"];
	checkRefused	= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'CONNECTION_REFUSED'"];
	checkPort		= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'Could not request local forwarding.'"];
	
	//NSLog(@"-- %@", outputContent);
	if ([data length])
	{
		if ([checkError evaluateWithObject:outputContent] == YES)
		{
			[[NSNotificationCenter defaultCenter]  removeObserver:self name:NSFileHandleReadCompletionNotification object:[stdOut fileHandleForReading]];
			[self setIsStillRunning: 0];
			[[self sshTask] terminate];
			[[self delegate] performSelector:@selector(errorPanelDisplaywithMessage:) 
								  withObject:[@"Can't connect. The host address might be misspelled for session " 
												stringByAppendingString:sessionName]];
			[delegate performSelector:@selector(formatQuickLink:) withObject:NO];
			[[self delegate] performSelector:@selector(enableInterface)];
			[delegate performSelector:@selector(stopWheel)];
			[delegate performSelector:@selector(updateList)];
		}
		else if ([checkWrongPass evaluateWithObject:outputContent] == YES)
		{
			[[NSNotificationCenter defaultCenter]  removeObserver:self 
															 name:NSFileHandleReadCompletionNotification 
														   object:[stdOut fileHandleForReading]];
			[self setIsStillRunning:0];
			[[self sshTask] terminate];
			[[self delegate] performSelector:@selector(errorPanelDisplaywithMessage:) 
								  withObject:[@"Can't connect. The given password was rejected for session " 
												stringByAppendingString:sessionName]];
			
			[delegate performSelector:@selector(formatQuickLink:) withObject:NO];
			[delegate performSelector:@selector(enableInterface)];
			[delegate performSelector:@selector(stopWheel)];
			[delegate performSelector:@selector(updateList)];
		}
		else if ([checkRefused evaluateWithObject:outputContent] == YES)
		{
			[[NSNotificationCenter defaultCenter]  removeObserver:self 
															 name:NSFileHandleReadCompletionNotification 
														   object:[stdOut fileHandleForReading]];
			[self setIsStillRunning:0];
			[[self sshTask] terminate];
			[[self delegate] performSelector:@selector(errorPanelDisplaywithMessage:) 
								  withObject:[@"Connection was rejected by remote host for session: " 
											  stringByAppendingString:sessionName]];
			
			[delegate performSelector:@selector(formatQuickLink:) withObject:NO];
			[delegate performSelector:@selector(enableInterface)];
			[delegate performSelector:@selector(stopWheel)];
			[delegate performSelector:@selector(updateList)];
		}		
		else if ([checkPort evaluateWithObject:outputContent] == YES)
		{
			[[NSNotificationCenter defaultCenter]  removeObserver:self 
															 name:NSFileHandleReadCompletionNotification 
														   object:[stdOut fileHandleForReading]];
			[self setIsStillRunning:0];
			[[self sshTask] terminate];
			[[self delegate] performSelector:@selector(errorPanelDisplaywithMessage:) 
								  withObject:[@"Can't connect. The given port is in use for session " 
											  stringByAppendingString:sessionName]];
			[delegate performSelector:@selector(formatQuickLink:) withObject:NO];
			[delegate performSelector:@selector(enableInterface)];
			[delegate performSelector:@selector(stopWheel)];
			[delegate performSelector:@selector(updateList)];
		}
		else if ([checkConnected evaluateWithObject:outputContent] == YES)
		{
			[self setIsStillRunning:1];
			[[self delegate] performSelector:@selector(errorPanelDisplaywithMessage:) 
								  withObject:[@"Tunnel is ready for session " stringByAppendingString:sessionName]];
			
			// will have to create to method to avoid passing of a bool as object
			[delegate performSelector:@selector(formatQuickLink:) withObject:YES];
			[delegate performSelector:@selector(stopWheel)];
			[delegate performSelector:@selector(updateList)];
			[delegate performSelector:@selector(disableInterface)];
		}
		else
			[[stdOut fileHandleForReading] readInBackgroundAndNotify];

	
		data = nil;
		checkError = nil;
		checkWrongPass = nil;
		checkConnected = nil;
		checkPort = nil;
	}
}


/**
 * the IBActions
 **/
- (void) openTunnelWithUsername:(NSString *)username Host:(NSString *)tunnelHost Port:(NSString*)port Password:(NSString *)password
{
	NSString	*helperPath;
	NSArray		*args;

	stdOut			= [NSPipe pipe];
	sshTask			= [[NSTask alloc] init];
	helperPath		=[[NSBundle mainBundle] pathForResource:@"SSHCommand" ofType:@"sh"];
	args			= [NSArray arrayWithObjects:localPort, remoteHost, remotePort, username, tunnelHost, password, port, nil];
	outputContent	= @"";
	
	[[self sshTask] setLaunchPath:helperPath];
	[[self sshTask] setArguments:args];
	[[self sshTask] setStandardOutput:stdOut];
	
	startDate = [NSDate date];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(checkShStatus:)
												 name:NSFileHandleReadCompletionNotification
											   object:[[sshTask standardOutput] fileHandleForReading]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(listernerForSSHTunnelDown:) 
												 name:@"NSTaskDidTerminateNotification" 
											   object:sshTask];
	
	[[stdOut fileHandleForReading] readInBackgroundAndNotify];
	[sshTask launch];
		
	[self setIsStillRunning:2];
	[delegate performSelector:@selector(startWheel)];
	
	helperPath = nil;
	args = nil;
}

- (void) closeTunnel
{
	[sshTask terminate];
	sshTask = nil;
	[self setIsStillRunning:0];
}

- (void) listernerForSSHTunnelDown:(NSNotification *)notification
{
		[[stdOut fileHandleForReading] closeFile];
		[self setIsStillRunning:0];
		[delegate performSelector:@selector(updateList)];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:sshTask];
}

/**
 * This part is for archiving this object
 **/
- (id) initWithCoder:(NSCoder *)coder
{
	[super init];
	
	sessionName		= [[coder decodeObjectForKey:@"MVsessionName"] retain];
	localPort		= [[coder decodeObjectForKey:@"MVlocalPort"] retain];
	remoteHost		= [[coder decodeObjectForKey:@"MVremoteHost"] retain];
	remotePort		= [[coder decodeObjectForKey:@"MVremotePort"] retain];
	//hasPassphrase	= [coder decodeBoolForKey:@"MVpassphrase"];
	isStillRunning = 0;
	return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{	
	[coder encodeObject:sessionName forKey:@"MVsessionName"];
	[coder encodeObject:localPort forKey:@"MVlocalPort"];
	[coder encodeObject:remoteHost forKey:@"MVremoteHost"];
	[coder encodeObject:remotePort forKey:@"MVremotePort"];
	//[coder encodeBool:hasPassphrase forKey:@"MVpassphrase"];
}
@end
