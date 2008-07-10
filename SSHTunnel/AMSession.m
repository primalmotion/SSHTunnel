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

#import "AMSession.h"

@implementation AMSession

@synthesize	sessionName;
@synthesize localPort;
@synthesize remoteHost;
@synthesize remotePort;
@synthesize statusImagePath;
@synthesize connected;
@synthesize connectionInProgress;
@synthesize currentServer;

- (id) init
{
	self = [super init];
	
	[self setStatusImagePath:[[NSBundle mainBundle] pathForResource:@"statusRed" ofType:@"tif"]];
	[self setConnected:NO];
	[self setConnectionInProgress:NO];
	
	[self addObserver:self forKeyPath:@"sessionName" 
			  options:(NSKeyValueObservingOptionNew | 
					   NSKeyValueObservingOptionOld)
			  context:NULL];
	
	[self addObserver:self forKeyPath:@"currentServer" 
			  options:(NSKeyValueObservingOptionNew | 
					   NSKeyValueObservingOptionOld)
			  context:NULL];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listernerForSSHTunnelDown:) 
												 name:@"NSTaskDidTerminateNotification" object:self];
	return self;
}

- (id) initWithCoder:(NSCoder *)coder
{
	self = [super init];
	
	sessionName		= [[coder decodeObjectForKey:@"MVsessionName"] retain];
	localPort		= [[coder decodeObjectForKey:@"MVlocalPort"] retain];
	remoteHost		= [[coder decodeObjectForKey:@"MVremoteHost"] retain];
	remotePort		= [[coder decodeObjectForKey:@"MVremotePort"] retain];
	statusImagePath	= [[coder decodeObjectForKey:@"MVStatusImagePath"] retain];
	currentServer	= [[coder decodeObjectForKey:@"MVcurrentServer"] retain];
	
	[self setConnected:NO];
	[self setConnectionInProgress:NO];
	[self setStatusImagePath:[[NSBundle mainBundle] pathForResource:@"statusRed" ofType:@"tif"]];
	[self addObserver:self forKeyPath:@"sessionName" 
			  options:(NSKeyValueObservingOptionNew | 
					   NSKeyValueObservingOptionOld)
			  context:NULL];
	
	[self addObserver:self forKeyPath:@"currentServer" 
			  options:(NSKeyValueObservingOptionNew | 
					   NSKeyValueObservingOptionOld)
			  context:NULL];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listernerForSSHTunnelDown:) 
												 name:@"NSTaskDidTerminateNotification" object:self];
	return self;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	NSLog(@"OBSERVING A CHANGE IN SOME PROPRIETIES");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AMSessionNameHasChange" object:self];
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	sessionName = nil;
	localPort = nil;
	remoteHost = nil;
	remotePort = nil;
	stdOut = nil;
	
	if ([sshTask isRunning] == YES)
	{
		[sshTask terminate];
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
	
	outputContent	= [outputContent stringByAppendingString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
	checkError		= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'CONNECTION_ERROR'"];
	checkWrongPass	= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'WRONG_PASSWORD'"];
	checkConnected	= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'CONNECTED'"];
	checkRefused	= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'CONNECTION_REFUSED'"];
	checkPort		= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'Could not request local forwarding.'"];
	
	if ([data length])
	{
		if ([checkError evaluateWithObject:outputContent] == YES)
		{
			[[NSNotificationCenter defaultCenter]  removeObserver:self name:NSFileHandleReadCompletionNotification object:[stdOut fileHandleForReading]];

			[self setStatusImagePath:[[NSBundle mainBundle] pathForResource:@"statusRed" ofType:@"tif"]];
			[self setConnected:NO];
			[self setConnectionInProgress:NO];
			[sshTask terminate];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"AMNewGeneralMessage" 
																object:[@"Unknown error for session " 
																		stringByAppendingString:[self sessionName]]];
		}
		else if ([checkWrongPass evaluateWithObject:outputContent] == YES)
		{
			[[NSNotificationCenter defaultCenter]  removeObserver:self name:NSFileHandleReadCompletionNotification object:[stdOut fileHandleForReading]];
			[self setConnected:NO];
			[self setConnectionInProgress:NO];
			[self setStatusImagePath:[[NSBundle mainBundle] pathForResource:@"statusRed" ofType:@"tif"]];
			[sshTask terminate];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"AMNewGeneralMessage" 
																object:[@"Wrong server password for session "
																		stringByAppendingString:[self sessionName]]];
		}
		else if ([checkRefused evaluateWithObject:outputContent] == YES)
		{
			[[NSNotificationCenter defaultCenter]  removeObserver:self name:NSFileHandleReadCompletionNotification  object:[stdOut fileHandleForReading]];
			
			[self setStatusImagePath:[[NSBundle mainBundle] pathForResource:@"statusRed" ofType:@"tif"]];
			[self setConnected:NO];
			[self setConnectionInProgress:NO];
			[sshTask terminate];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"AMNewGeneralMessage" 
																object:[@"Connexion has been refused by server for session "
																		stringByAppendingString:[self sessionName]]];
		}		
		else if ([checkPort evaluateWithObject:outputContent] == YES)
		{
			[[NSNotificationCenter defaultCenter]  removeObserver:self name:NSFileHandleReadCompletionNotification object:[stdOut fileHandleForReading]];

			[self setStatusImagePath:[[NSBundle mainBundle] pathForResource:@"statusRed" ofType:@"tif"]];
			[self setConnected:NO];
			[self setConnectionInProgress:NO];
			[sshTask terminate];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"AMNewGeneralMessage" 
																object:[@"Wrong server port for session " 
																		stringByAppendingString:[self sessionName]]];
		}
		else if ([checkConnected evaluateWithObject:outputContent] == YES)
		{
			[[NSNotificationCenter defaultCenter]  removeObserver:self name:NSFileHandleReadCompletionNotification  object:[stdOut fileHandleForReading]];

			[self setConnected:YES];
			[self setConnectionInProgress:NO];
			[self setStatusImagePath:[[NSBundle mainBundle] pathForResource:@"statusGreen" ofType:@"tif"]];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"AMNewGeneralMessage" 
																object:[@"Sucessfully connects session "
																		stringByAppendingString:[self sessionName]]];
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
- (void) openTunnel
{
	NSString	*helperPath;
	NSArray		*args;
	
	stdOut			= [NSPipe pipe];
	sshTask			= [[NSTask alloc] init];
	helperPath		= [[NSBundle mainBundle] pathForResource:@"SSHCommand" ofType:@"sh"];
	args			= [NSArray arrayWithObjects:localPort, remoteHost, remotePort, [currentServer username],
					   [currentServer host], [currentServer password], [currentServer port], nil];
	
	outputContent	= @"";
	
	[sshTask setLaunchPath:helperPath];
	[sshTask setArguments:args];
	[sshTask setStandardOutput:stdOut];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(checkShStatus:)
												 name:NSFileHandleReadCompletionNotification
											   object:[[sshTask standardOutput] fileHandleForReading]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(listernerForSSHTunnelDown:) 
												 name:@"NSTaskDidTerminateNotification" 
											   object:sshTask];
	
	[[stdOut fileHandleForReading] readInBackgroundAndNotify];
	[self setConnectionInProgress:YES];
	[sshTask launch];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AMNewGeneralMessage" 
														object:[@"Initializing connexion for session "
																stringByAppendingString:[self sessionName]]];
	
	[self setStatusImagePath:[[NSBundle mainBundle] pathForResource:@"statusOrange" ofType:@"tif"]];
	
	helperPath = nil;
	args = nil;
}

- (void) closeTunnel
{
	[sshTask terminate];
	sshTask = nil;
}

- (void) listernerForSSHTunnelDown:(NSNotification *)notification
{
	NSLog(@"NOTIFICATION RECU DE : ", [notification object]);
	
	[[stdOut fileHandleForReading] closeFile];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:sshTask];
	[self setConnected:NO];
	[self setConnectionInProgress:NO];
	[self setStatusImagePath:[[NSBundle mainBundle] pathForResource:@"statusRed" ofType:@"tif"]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AMNewGeneralMessage" 
														object:[@"Connexion close for session "
																stringByAppendingString:[self sessionName]]];
}

/**
 * This part is for archiving this object
 **/


- (void) encodeWithCoder:(NSCoder *) coder
{	
	[coder encodeObject:sessionName forKey:@"MVsessionName"];
	[coder encodeObject:localPort forKey:@"MVlocalPort"];
	[coder encodeObject:remoteHost forKey:@"MVremoteHost"];
	[coder encodeObject:remotePort forKey:@"MVremotePort"];
	[coder encodeObject:statusImagePath forKey:@"MVStatusImagePath"];
	[coder encodeObject:currentServer forKey:@"MVcurrentServer"];
}
@end
