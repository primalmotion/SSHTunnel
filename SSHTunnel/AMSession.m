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
@synthesize sessionTunnelType;
@synthesize tunnelTypeImagePath;
@synthesize connectionLink;
@synthesize globalProxyPort;
@synthesize useDynamicProxy;
@synthesize childrens;
@synthesize	isLeaf;
@synthesize isGroup;
@synthesize autostart;

#pragma mark Initilizations

- (id) init
{
	self = [super init];
	
	[self setStatusImagePath:[[NSBundle mainBundle] pathForResource:@"statusRed" ofType:@"tif"]];
	[self setConnected:NO];
	[self setConnectionInProgress:NO];
	[self setSessionTunnelType:AMSessionOutgoingTunnel];
	[self setGlobalProxyPort:@"7777"];
	[self setUseDynamicProxy:NO];
	[self setChildrens:nil];
	[self setIsLeaf:YES];
	[self setIsGroup:NO];
	[self setAutostart:NO];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listernerForSSHTunnelDown:) 
												 name:@"NSTaskDidTerminateNotification" object:self];
	return self;
}

- (id) initWithCoder:(NSCoder *)coder
{
	self = [super init];
	
	sessionName			= [[coder decodeObjectForKey:@"MVsessionName"] retain];
	portsMap			= [[coder decodeObjectForKey:@"portsMap"] retain];
	remoteHost			= [[coder decodeObjectForKey:@"MVremoteHost"] retain];
	statusImagePath		= [[coder decodeObjectForKey:@"MVStatusImagePath"] retain];
	currentServer		= [[coder decodeObjectForKey:@"MVcurrentServer"] retain];
	globalProxyPort		= [[coder decodeObjectForKey:@"MVdynamicProxyPort"] retain];
	sessionTunnelType	= [coder decodeIntForKey:@"MVoutgoingTunnel"];
	useDynamicProxy		= [coder decodeBoolForKey:@"MVuseDynamicProxy"];
	childrens			= [coder decodeObjectForKey:@"MVChildrens"];
	isLeaf				= [coder decodeBoolForKey:@"MVIsLeaf"];
	autostart			= [coder decodeBoolForKey:@"MVAutostart"];
	isGroup				= [coder decodeBoolForKey:@"MVIsGroup"];
	
	[self setConnected:NO];
	[self setConnectionInProgress:NO];
	
	if (![self isGroup])
		[self setStatusImagePath:[[NSBundle mainBundle] pathForResource:@"statusRed" ofType:@"tif"]];
	else
		[self setStatusImagePath:@""];
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
	[coder encodeInt:sessionTunnelType forKey:@"MVoutgoingTunnel"];
	[coder encodeObject:globalProxyPort forKey:@"MVdynamicProxyPort"];
	[coder encodeBool:useDynamicProxy forKey:@"MVuseDynamicProxy"];
	[coder encodeObject:childrens forKey:@"MVChildrens"];
	[coder encodeBool:isLeaf forKey:@"MVIsLeaf"];
	[coder encodeBool:autostart forKey:@"MVAutostart"];
	[coder encodeBool:isGroup forKey:@"MVIsGroup"];
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




#pragma mark Overloaded accesors

- (NSString *) tunnelTypeImagePath
{
	if ([self sessionTunnelType] == AMSessionOutgoingTunnel)
		return [[NSBundle mainBundle] pathForResource:@"outTunnel" ofType:@"tif"];
	else if ([self sessionTunnelType] == AMSessionIncomingTunnel) 
		return [[NSBundle mainBundle] pathForResource:@"inTunnel" ofType:@"tif"];
	else 
		return [[NSBundle mainBundle] pathForResource:@"inTunnel" ofType:@"tif"];

}


- (void) setSessionTunnelType:(NSInteger)newValue
{
	[self willChangeValueForKey:@"outgoingTunnel"];
	[self willChangeValueForKey:@"tunnelTypeImagePath"];
	[self willChangeValueForKey:@"remoteHost"];
	sessionTunnelType = newValue;
	[self didChangeValueForKey:@"outgoingTunnel"];
	[self didChangeValueForKey:@"tunnelTypeImagePath"];
	[self didChangeValueForKey:@"remoteHost"];
}




#pragma mark Helper methods

- (void)setProxyEnableForThisSession:(BOOL)enabled onPort:(NSString*)port
{
	NSTask *activateProxy = [[NSTask alloc] init];
	[activateProxy setLaunchPath:@"/usr/sbin/networksetup"];
	
	if (enabled)
		[activateProxy setArguments:[NSArray arrayWithObjects:@"-setsocksfirewallproxy", 
									 [[NSUserDefaults standardUserDefaults] stringForKey:@"networkServicesForProxies"], 
									 @"127.0.0.1", port, @"off", nil]];
	else
		[activateProxy setArguments:[NSArray arrayWithObjects:@"-setsocksfirewallproxystate",  
									 [[NSUserDefaults standardUserDefaults] stringForKey:@"networkServicesForProxies"], @"off", nil]];

	[activateProxy launch];
}

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

- (NSMutableString *) prepareSSHCommandWithRemotePorts:(NSMutableArray *)remotePorts localPorts:(NSMutableArray *)localPorts  
{
	NSMutableString *argumentsString = @"ssh ";
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"forceSSHVersion2"])
		argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:@" -2 "];
	
	if ([self sessionTunnelType] == AMSessionOutgoingTunnel)
	{
		int i;
		for(i = 0; i < [remotePorts count]; i++)
		{
			argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:@"-N -L "];
			argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:[localPorts objectAtIndex:i]];
			argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:@":"];
			argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:remoteHost];
			argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:@":"];
			argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:[remotePorts objectAtIndex:i]];
		}
	}
	else if ([self sessionTunnelType] == AMSessionIncomingTunnel)
	{
		int i;
		for(i = 0; i < [remotePorts count]; i++)
		{
			argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:@"-N -R "];
			argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:[remotePorts objectAtIndex:i]];
			argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:@":"];
			argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:@"127.0.0.1"];
			argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:@":"];
			argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:[localPorts objectAtIndex:i]];
		}
	}
	
	if (([self useDynamicProxy] == YES) || ([self sessionTunnelType] == AMSessionGlobalProxy))
	{
		argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:@" -D "];
		argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:[self globalProxyPort]];
	}
	
	argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:@" "];
	NSLog(@"toto1 -- %@", currentServer);
	argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:[currentServer username]];
	NSLog(@"toto2");
	argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:@"@"];
	argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:[currentServer host]];
	argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:@" -p "];
	argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:[currentServer port]];

	NSLog(@"Used SSH Command : %@", argumentsString);
	
	return argumentsString;
}




#pragma mark Control methods

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
	
	argumentsString = [self prepareSSHCommandWithRemotePorts:remotePorts localPorts:localPorts];
	
	args			= [NSArray arrayWithObjects:argumentsString, [currentServer password], nil];

	outputContent	= @"";
	
	[sshTask setLaunchPath:helperPath];
	[sshTask setArguments:args];

	[sshTask setStandardOutput:stdOut];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(handleProcessusExecution:)
												 name:NSFileHandleReadCompletionNotification
											   object:[[sshTask standardOutput] fileHandleForReading]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(listernerForSSHTunnelDown:) 
												 name:@"NSTaskDidTerminateNotification" 
											   object:sshTask];
	
	[[stdOut fileHandleForReading] readInBackgroundAndNotify];
	[self setConnectionInProgress:YES];
	
	
	[sshTask launch];
	NSLog(@"Session %@ is now launched.", [self sessionName]);
	[[NSNotificationCenter defaultCenter] postNotificationName:AMNewGeneralMessage
														object:[@"Initializing connexion for session "
																stringByAppendingString:[self sessionName]]];
	
	[self setStatusImagePath:[[NSBundle mainBundle] pathForResource:@"statusOrange" ofType:@"tif"]];
	
	helperPath = nil;
	args = nil;
}

- (void) closeTunnel
{
	if ([self sessionTunnelType] == AMSessionGlobalProxy)
		[self setProxyEnableForThisSession:NO onPort:nil];
	
	NSLog(@"Session %@ is now closed.", [self sessionName]);
	[sshTask terminate];
	sshTask = nil;
}



#pragma mark Observers and delegates
- (void) handleProcessusExecution:(NSNotification *) aNotification
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
	checkPort		= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'Could not request local forwarding'"];
	
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
			[[NSNotificationCenter defaultCenter] postNotificationName:AMNewGeneralMessage 
																object:[@"Unknown error for session " 
																		stringByAppendingString:[self sessionName]]];
			NSRunAlertPanel(@"Error while connecting", @"Unknown error as occured while connecting." , @"Ok", nil, nil);
		}
		else if ([checkWrongPass evaluateWithObject:outputContent] == YES)
		{
			[[NSNotificationCenter defaultCenter]  removeObserver:self name:NSFileHandleReadCompletionNotification object:[stdOut fileHandleForReading]];
			[self setConnected:NO];
			[self setConnectionInProgress:NO];
			[self setStatusImagePath:[[NSBundle mainBundle] pathForResource:@"statusRed" ofType:@"tif"]];
			[self setConnectionLink:@""];
			[sshTask terminate];
			[[NSNotificationCenter defaultCenter] postNotificationName:AMNewGeneralMessage
																object:[@"Wrong server password for session "
																		stringByAppendingString:[self sessionName]]];
			NSRunAlertPanel(@"Error while connecting", @"The password or username set for the server are wrong" , @"Ok", nil, nil);
		}
		else if ([checkRefused evaluateWithObject:outputContent] == YES)
		{
			[[NSNotificationCenter defaultCenter]  removeObserver:self name:NSFileHandleReadCompletionNotification  object:[stdOut fileHandleForReading]];
			
			[self setStatusImagePath:[[NSBundle mainBundle] pathForResource:@"statusRed" ofType:@"tif"]];
			[self setConnected:NO];
			[self setConnectionInProgress:NO];
			[self setConnectionLink:@""];
			[sshTask terminate];
			[[NSNotificationCenter defaultCenter] postNotificationName:AMNewGeneralMessage
																object:[@"Connexion has been refused by server for session "
																		stringByAppendingString:[self sessionName]]];
			NSRunAlertPanel(@"Error while connecting", @"Connection has been rejected by the server." , @"Ok", nil, nil);
		}		
		else if ([checkPort evaluateWithObject:outputContent] == YES)
		{
			[[NSNotificationCenter defaultCenter]  removeObserver:self name:NSFileHandleReadCompletionNotification object:[stdOut fileHandleForReading]];
			
			[self setStatusImagePath:[[NSBundle mainBundle] pathForResource:@"statusRed" ofType:@"tif"]];
			[self setConnected:NO];
			[self setConnectionInProgress:NO];
			[self setConnectionLink:@""];
			[sshTask terminate];
			[[NSNotificationCenter defaultCenter] postNotificationName:AMNewGeneralMessage
																object:[@"Wrong server port for session " 
																		stringByAppendingString:[self sessionName]]];
			NSRunAlertPanel(@"Error while connecting", @"The port is already in used on server." , @"Ok", nil, nil);
		}
		else if ([checkConnected evaluateWithObject:outputContent] == YES)
		{
			[[NSNotificationCenter defaultCenter]  removeObserver:self name:NSFileHandleReadCompletionNotification  object:[stdOut fileHandleForReading]];
			
			[self setConnected:YES];
			[self setConnectionInProgress:NO];
			[self setStatusImagePath:[[NSBundle mainBundle] pathForResource:@"statusGreen" ofType:@"tif"]];
			[[NSNotificationCenter defaultCenter] postNotificationName:AMNewGeneralMessage
																object:[@"Sucessfully connects session "
																		stringByAppendingString:[self sessionName]]];
		
			if ([self sessionTunnelType] == AMSessionOutgoingTunnel)
				[self setConnectionLink:[@"127.0.0.1:" stringByAppendingString:[portsMap serviceLocalPorts]]];
			else if ([self sessionTunnelType] == AMSessionIncomingTunnel)
				[self setConnectionLink:[[[self currentServer] host] stringByAppendingString:[@":" stringByAppendingString:[portsMap serviceRemotePorts]]]];
			
			if ([self sessionTunnelType] == AMSessionGlobalProxy)
				[self setProxyEnableForThisSession:YES onPort:globalProxyPort];

			
			//[[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObject: NSStringPboardType] owner: nil];
			//[[NSPasteboard generalPasteboard] setString:[self connectionLink] forType:NSStringPboardType];
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
	[[stdOut fileHandleForReading] closeFile];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:sshTask];
	[self setConnected:NO];
	[self setConnectionInProgress:NO];
	[self setConnectionLink:@""];
	[self setStatusImagePath:[[NSBundle mainBundle] pathForResource:@"statusRed" ofType:@"tif"]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:AMNewGeneralMessage
														object:[@"Connexion close for session "
																stringByAppendingString:[self sessionName]]];
}


@end
