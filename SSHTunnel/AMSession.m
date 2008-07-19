// Copyright (C) 2008  Antoine Mercadal
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

#import "AMSession.h"

@implementation AMSession

@synthesize	sessionName;
@synthesize portsMap;
@synthesize remoteHost;
@synthesize statusImagePath;
@synthesize connected;
@synthesize connectionInProgress;
@synthesize currentServer;
@synthesize outgoingTunnel;
@synthesize tunnelTypeImagePath;
@synthesize connectionLink;


/**
 Initializations, deallocations and archiving
 **/

- (id) init
{
	self = [super init];
	
	[self setStatusImagePath:[[NSBundle mainBundle] pathForResource:@"statusRed" ofType:@"tif"]];
	[self setConnected:NO];
	[self setConnectionInProgress:NO];
	[self setOutgoingTunnel:0];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listernerForSSHTunnelDown:) 
												 name:@"NSTaskDidTerminateNotification" object:self];
	return self;
}

- (id) initWithCoder:(NSCoder *)coder
{
	self = [super init];
	
	sessionName		= [[coder decodeObjectForKey:@"MVsessionName"] retain];
	portsMap		= [[coder decodeObjectForKey:@"portsMap"] retain];
	remoteHost		= [[coder decodeObjectForKey:@"MVremoteHost"] retain];
	statusImagePath	= [[coder decodeObjectForKey:@"MVStatusImagePath"] retain];
	currentServer	= [[coder decodeObjectForKey:@"MVcurrentServer"] retain];
	outgoingTunnel	= [coder decodeIntForKey:@"MVoutgoingTunnel"];
	
	[self setConnected:NO];
	[self setConnectionInProgress:NO];
	
	[self setStatusImagePath:[[NSBundle mainBundle] pathForResource:@"statusRed" ofType:@"tif"]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listernerForSSHTunnelDown:) 
												 name:@"NSTaskDidTerminateNotification" object:self];
	
	
	return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{	
	[coder encodeObject:sessionName forKey:@"MVsessionName"];
	[coder encodeObject:portsMap forKey:@"portsMap"];
	[coder encodeObject:remoteHost forKey:@"MVremoteHost"];
	[coder encodeObject:statusImagePath forKey:@"MVStatusImagePath"];
	[coder encodeObject:currentServer forKey:@"MVcurrentServer"];
	[coder encodeInt:outgoingTunnel forKey:@"MVoutgoingTunnel"];
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	sessionName = nil;
	portsMap = nil;
	remoteHost = nil;
	stdOut = nil;
	
	if ([sshTask isRunning] == YES)
		[sshTask terminate];
	
	sshTask = nil;
	
	[super dealloc];
}



/**
 overriding some accessors
 **/

- (NSString*) tunnelTypeImagePath
{
	if ([self outgoingTunnel] == 0)
		return [[NSBundle mainBundle] pathForResource:@"outTunnel" ofType:@"tif"];
	else 
		return [[NSBundle mainBundle] pathForResource:@"inTunnel" ofType:@"tif"];
}

- (void) setOutgoingTunnel:(NSInteger)newValue
{
	[self willChangeValueForKey:@"outgoingTunnel"];
	[self willChangeValueForKey:@"tunnelTypeImagePath"];
	[self willChangeValueForKey:@"remoteHost"];
	outgoingTunnel = newValue;
	[self didChangeValueForKey:@"outgoingTunnel"];
	[self didChangeValueForKey:@"tunnelTypeImagePath"];
	[self didChangeValueForKey:@"remoteHost"];
}




/**
 Performing computing operation on strings
 **/

- (NSMutableArray *) parsePortsSequence:(NSString*)seq
{
	NSArray *units;
	NSMutableArray *ranges = [[NSMutableArray alloc] init];
	NSMutableArray	*ports  = [[NSMutableArray alloc] init];
	NSPredicate *containRange = [NSPredicate predicateWithFormat:@"SELF contains[c] '-' "];
	NSPredicate *validPort = [NSPredicate predicateWithFormat:@"SELF matches '[0-9]+'"];
	
	units = [seq componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ,;"]];
	
	for (NSString* s in units)
	{
		
		if ([containRange evaluateWithObject:s] == YES)
		{
			[ranges addObject:s];
		}
		else if ([validPort evaluateWithObject:s])
		{
			[ports addObject:s];
		}
	}
	
	for (NSString* s in ranges)
	{
		NSInteger	startPort;
		NSInteger	stopPort;
		NSInteger	i;
		NSArray		*bounds;
		
		bounds = [s componentsSeparatedByString:@"-"];
		startPort = [[bounds objectAtIndex:0] intValue];
		stopPort = [[bounds objectAtIndex:1] intValue];
		
		for (i = startPort; i <= stopPort; i++)
			[ports addObject:[NSString stringWithFormat:@"%d", i]];
	}
	
	return ports;
}

- (NSMutableString *) prepareSSHCommand:(NSMutableArray *)remotePorts localPorts:(NSMutableArray *)localPorts  
{
	NSMutableString *argumentsString = @"ssh -N";
	
	if ([self outgoingTunnel] == 0)
	{
		for(NSString * s in remotePorts)
		{
			argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:@" -L "];
			argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:[localPorts objectAtIndex:0]];
			argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:@":"];
			argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:remoteHost];
			argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:@":"];
			argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:s];
		}
	}
	else
	{
		for(NSString * s in localPorts)
		{
			argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:@" -R "];
			argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:[remotePorts objectAtIndex:0]];
			argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:@":"];
			argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:@"127.0.0.1"];
			argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:@":"];
			argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:s];
		}
	}
	
	argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:@" "];
	argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:[currentServer username]];
	argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:@"@"];
	argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:[currentServer host]];
	argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:@" -p "];
	argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:[currentServer port]];
	
	return argumentsString;
}



/**
 Control the ssh command
 **/

- (void) openTunnel
{
	NSString			*helperPath;
	NSArray				*args;
	NSMutableArray		*remotePorts;
	NSMutableArray		*localPorts;
	NSMutableString		*argumentsString;
	
	stdOut			= [NSPipe pipe];
	sshTask			= [[NSTask alloc] init];
	helperPath		= [[NSBundle mainBundle] pathForResource:@"SSHCommand" ofType:@"sh"];
	remotePorts		= [self parsePortsSequence:[portsMap serviceRemotePorts]];
	localPorts		= [self parsePortsSequence:[portsMap serviceLocalPorts]];
	
	
	// OK SO NO I'VE TO MAKE SOMETHING IN THE SSH SCRIPT TO HANDLE THE POSSIBLE
	// DELUGE OF PORTS PASSING TROUGHT ARGUMENTS... Let's have a break..
	
	argumentsString = [self prepareSSHCommand:remotePorts localPorts:localPorts];


	NSLog(@"ARGUUMENTS: %@", argumentsString);
	
	args			= [NSArray arrayWithObjects:argumentsString, [currentServer password], nil];

//	args			= [NSArray arrayWithObjects:[localPort servicePort], remoteHost, [remotePort servicePort], [currentServer username],
//					   [currentServer host], [currentServer password], [currentServer port], [NSString stringWithFormat:@"%d", outgoingTunnel], nil];
	
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



/*
 Listener and observer for the NSTask (termination and incoming data processing)
*/
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
			[self setConnectionLink:@""];
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
			[self setConnectionLink:@""];
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
			[self setConnectionLink:@""];
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
			[self setConnectionLink:@""];
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
			if ([self outgoingTunnel] == 0)
				[self setConnectionLink:[@"127.0.0.1:" stringByAppendingString:[portsMap serviceLocalPorts]]];
			else
				[self setConnectionLink:[[[self currentServer] host] stringByAppendingString:[@":" stringByAppendingString:[portsMap serviceRemotePorts]]]];
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

- (void) listernerForSSHTunnelDown:(NSNotification *)notification
{
	NSLog(@"NOTIFICATION RECU DE : ", [notification object]);
	
	[[stdOut fileHandleForReading] closeFile];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:sshTask];
	[self setConnected:NO];
	[self setConnectionInProgress:NO];
	[self setConnectionLink:@""];
	[self setStatusImagePath:[[NSBundle mainBundle] pathForResource:@"statusRed" ofType:@"tif"]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AMNewGeneralMessage" 
														object:[@"Connexion close for session "
																stringByAppendingString:[self sessionName]]];
}


@end
