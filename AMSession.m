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

#import "AMResourcesHelper.h"

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
@synthesize networkService;
@synthesize autoReconnect;

#pragma mark Initilizations

- (id) init
{
	self = [super init];
	
	[self setStatusImagePath:[AMResourcesHelper pathForImageNamed:@"statusRed"]];
	[self setConnected:NO];
	[self setConnectionInProgress:NO];
	[self setSessionTunnelType:AMSessionOutgoingTunnel];
	[self setGlobalProxyPort:@"7777"];
	[self setUseDynamicProxy:NO];
	[self setChildrens:nil];
	[self setIsLeaf:YES];
	[self setIsGroup:NO];
	[self setAutostart:NO];
	[self setAutoReconnect:NO];
	autoReconnectTimes = 0;
	

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listernerForSSHTunnelDown:) 
												 name:@"NSTaskDidTerminateNotification" object:self];
	return self;
}

- (void) prepareAuthorization
{	
	OSStatus myStatus;
	AuthorizationFlags myFlags = kAuthorizationFlagDefaults;
	AuthorizationRef myAuthorizationRef;
	myStatus = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment,
								   myFlags, &myAuthorizationRef);    
	
	if (myStatus != errAuthorizationSuccess) 
	{
		NSLog(@"An administrator password is required...");
	}
	else
	{
		AuthorizationItem myItems = {kAuthorizationRightExecute, 0, NULL, 0};
		
		AuthorizationRights myRights = {1, &myItems};
		myFlags = kAuthorizationFlagDefaults |                   
		kAuthorizationFlagInteractionAllowed |
		kAuthorizationFlagPreAuthorize |
		kAuthorizationFlagExtendRights;
		
		myStatus = AuthorizationCopyRights (myAuthorizationRef, &myRights, NULL, myFlags, NULL );
	}		
}

- (id) initWithCoder:(NSCoder *)coder
{
	self = [super init];
	
	sessionName			= [coder decodeObjectForKey:@"MVsessionName"];
	portsMap			= [coder decodeObjectForKey:@"portsMap"];
	remoteHost			= [coder decodeObjectForKey:@"MVremoteHost"];
	statusImagePath		= [coder decodeObjectForKey:@"MVStatusImagePath"];
	currentServer		= [coder decodeObjectForKey:@"MVcurrentServer"];
	globalProxyPort		= [coder decodeObjectForKey:@"MVdynamicProxyPort"];
	sessionTunnelType	= [coder decodeIntForKey:@"MVoutgoingTunnel"];
	useDynamicProxy		= [coder decodeBoolForKey:@"MVuseDynamicProxy"];
	childrens			= [coder decodeObjectForKey:@"MVChildrens"];
	isLeaf				= [coder decodeBoolForKey:@"MVIsLeaf"];
	autostart			= [coder decodeBoolForKey:@"MVAutostart"];
	autoReconnect		= [coder decodeBoolForKey:@"MVAutoReconnect"];
	isGroup				= [coder decodeBoolForKey:@"MVIsGroup"];
	networkService		= [coder decodeObjectForKey:@"MVNetworkService"];
	
	[self setConnected:NO];
	[self setConnectionInProgress:NO];
	autoReconnectTimes = 0;
	
	if (![self isGroup])
		[self setStatusImagePath:[AMResourcesHelper pathForImageNamed:@"statusRed"]];
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
	[coder encodeBool:autoReconnect forKey:@"MVAutoReconnect"];
	[coder encodeBool:isGroup forKey:@"MVIsGroup"];
	[coder encodeObject:networkService forKey:@"MVNetworkService"];
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
	NSLog(@"%@", networkService);
	if (enabled)
		[activateProxy setArguments:[NSArray arrayWithObjects:@"-setsocksfirewallproxy", 
									 [self networkService], 
									 @"127.0.0.1", port, @"off", nil]];
	else
		[activateProxy setArguments:[NSArray arrayWithObjects:@"-setsocksfirewallproxystate",  
									 [self networkService]
									 , @"off", nil]];

	//[activateProxy launch];
    [activateProxy performSelector:@selector(launch) withObject:nil afterDelay:0.1];
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
			[ports addObject:[NSString stringWithFormat:@"%ld", (long)i]];
	}
	
	return ports;
}

- (NSMutableString *) prepareSSHCommandWithRemotePorts:(NSMutableArray *)remotePorts localPorts:(NSMutableArray *)localPorts  
{
	NSMutableString *argumentsString = [NSMutableString stringWithString:@"ssh "];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"forceSSHVersion2"])
		argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:@" -2 "];
	
	if ([self sessionTunnelType] == AMSessionOutgoingTunnel)
	{
		int i;
		for(i = 0; i < [remotePorts count]; i++)
		{
			argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:@" -N -L "];
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
			argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:@" -N -R "];
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
	argumentsString = (NSMutableString *)[argumentsString stringByAppendingString:[currentServer username]];
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
	
	//[self prepareAuthorization];
	
	if ([self currentServer] == nil)
	{
		[self setConnected:NO];
		[self setConnectionInProgress:NO];
		[[NSNotificationCenter defaultCenter] postNotificationName:AMNewErrorMessage  
															object:@"There is no server set for this session."];
		return;
	}
	
	if ([self sessionTunnelType] == AMSessionOutgoingTunnel)
	{
		if (([self remoteHost] == nil) ||
			([self portsMap] == nil))
		{
			[self setConnected:NO];
			[self setConnectionInProgress:NO];
			[[NSNotificationCenter defaultCenter] postNotificationName:AMNewErrorMessage   
																object:@"There is no service or remote host set for this session"];
			return;
		}
	}
	else if ([self sessionTunnelType] == AMSessionIncomingTunnel)
	{
		if (([self portsMap] == nil) ||
			(([self useDynamicProxy] == YES) && ([self globalProxyPort] == nil)))
		{
			[self setConnected:NO];
			[self setConnectionInProgress:NO];
			[[NSNotificationCenter defaultCenter] postNotificationName:AMNewErrorMessage 
																object:@"There is no services or dynamic port set for this session."];
			return;
		}
	}
	else if ([self sessionTunnelType] == AMSessionGlobalProxy)
	{
		if (([self networkService] == nil) ||
			([self globalProxyPort] == nil))
		{
			[self setConnected:NO];
			[self setConnectionInProgress:NO];
			[[NSNotificationCenter defaultCenter] postNotificationName:AMNewErrorMessage 
																object:@"There is no dynamic port set for this session."];
			
			return;
		}
	}
	stdOut			= [NSPipe pipe];
	sshTask			= [[NSTask alloc] init];
	helperPath		= [[NSBundle mainBundle] pathForResource:@"SSHCommand" ofType:@"sh"];
	
	remotePorts		= [self parsePortsSequence:[portsMap serviceRemotePorts]];
	localPorts		= [self parsePortsSequence:[portsMap serviceLocalPorts]];
	
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
	NSError *error = nil;
	[auth obtainWithRight:"system.privileges.admin" 
                    flags:kAuthorizationFlagDefaults|kAuthorizationFlagInteractionAllowed|
	 kAuthorizationFlagExtendRights|kAuthorizationFlagPreAuthorize
                    error:&error];
	
	
	[sshTask launch];

	NSLog(@"Session %@ is now launched.", [self sessionName]);
	[[NSNotificationCenter defaultCenter] postNotificationName:AMNewGeneralMessage
														object:[@"Initializing connection for session "
																stringByAppendingString:[self sessionName]]];
	
	[self setStatusImagePath:[AMResourcesHelper pathForImageNamed:@"statusOrange"]];
	
	helperPath = nil;
	args = nil;
}

- (void) closeTunnel
{
	if ([self sessionTunnelType] == AMSessionGlobalProxy)
		[self setProxyEnableForThisSession:NO onPort:nil];
	
	NSLog(@"Session %@ is now closed.", [self sessionName]);
	if ([sshTask isRunning])
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
    NSPredicate *checkLoggedIn;
	
	data = [[aNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];
	
	outputContent	= [outputContent stringByAppendingString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
	checkError		= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'CONNECTION_ERROR'"];
	checkWrongPass	= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'WRONG_PASSWORD'"];
	checkConnected	= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'CONNECTED'"];
	checkRefused	= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'CONNECTION_REFUSED'"];
	checkPort		= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'Could not request local forwarding'"];
    checkLoggedIn   = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'Last login:'"]; // This is for if there is a pub/priv key set up
	
	
	if ([data length])
	{
		if ([checkError evaluateWithObject:outputContent] == YES)
		{
			[[NSNotificationCenter defaultCenter]  removeObserver:self name:NSFileHandleReadCompletionNotification object:[stdOut fileHandleForReading]];
			
			[self setStatusImagePath:[AMResourcesHelper pathForImageNamed:@"statusRed"]];
			[self setConnected:NO];
			[self setConnectionInProgress:NO];
			[self setConnectionLink:@""];
			[sshTask terminate];
			[[NSNotificationCenter defaultCenter] postNotificationName:AMNewErrorMessage 
																object:[@"Unknown error for session " 
																		stringByAppendingString:[self sessionName]]];
			NSRunAlertPanel(@"Error while connecting", @"Unknown error as occured while connecting." , @"Ok", nil, nil);
		}
		else if ([checkWrongPass evaluateWithObject:outputContent] == YES)
		{
			[[NSNotificationCenter defaultCenter]  removeObserver:self name:NSFileHandleReadCompletionNotification object:[stdOut fileHandleForReading]];
			[self setConnected:NO];
			[self setConnectionInProgress:NO];
			[self setStatusImagePath:[AMResourcesHelper pathForImageNamed:@"statusRed"]];
			[self setConnectionLink:@""];
			[sshTask terminate];
			[[NSNotificationCenter defaultCenter] postNotificationName:AMNewErrorMessage
																object:[@"Wrong server password for session "
																		stringByAppendingString:[self sessionName]]];
			NSRunAlertPanel(@"Error while connecting", @"The password or username set for the server are wrong" , @"Ok", nil, nil);
		}
		else if ([checkRefused evaluateWithObject:outputContent] == YES)
		{
			[[NSNotificationCenter defaultCenter]  removeObserver:self name:NSFileHandleReadCompletionNotification  object:[stdOut fileHandleForReading]];
			
			[self setStatusImagePath:[AMResourcesHelper pathForImageNamed:@"statusRed"]];
			[self setConnected:NO];
			[self setConnectionInProgress:NO];
			[self setConnectionLink:@""];
			[sshTask terminate];
			[[NSNotificationCenter defaultCenter] postNotificationName:AMNewErrorMessage
																object:[@"Connection has been refused by server for session "
																		stringByAppendingString:[self sessionName]]];
			NSRunAlertPanel(@"Error while connecting", @"Connection has been rejected by the server." , @"Ok", nil, nil);
		}		
		else if ([checkPort evaluateWithObject:outputContent] == YES)
		{
			[[NSNotificationCenter defaultCenter]  removeObserver:self name:NSFileHandleReadCompletionNotification object:[stdOut fileHandleForReading]];
			
			[self setStatusImagePath:[AMResourcesHelper pathForImageNamed:@"statusRed"]];
			[self setConnected:NO];
			[self setConnectionInProgress:NO];
			[self setConnectionLink:@""];
			[sshTask terminate];
			[[NSNotificationCenter defaultCenter] postNotificationName:AMNewErrorMessage
																object:[@"Wrong server port for session " 
																		stringByAppendingString:[self sessionName]]];
			NSRunAlertPanel(@"Error while connecting", @"The port is already in used on server." , @"Ok", nil, nil);
		}
		else if ([checkConnected evaluateWithObject:outputContent] == YES || [checkLoggedIn evaluateWithObject:outputContent] == YES)
		{
			[[NSNotificationCenter defaultCenter]  removeObserver:self name:NSFileHandleReadCompletionNotification  object:[stdOut fileHandleForReading]];
			
			[self setConnected:YES];
			[self setConnectionInProgress:NO];
			[self setStatusImagePath:[AMResourcesHelper pathForImageNamed:@"statusGreen"]];
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
	[self setStatusImagePath:[AMResourcesHelper pathForImageNamed:@"statusRed"]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:AMNewGeneralMessage
														object:[@"Connection close for session "
																stringByAppendingString:[self sessionName]]];
}


@end
