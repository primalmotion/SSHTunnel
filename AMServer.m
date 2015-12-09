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

#import "AMServer.h"

#import "AMResourcesHelper.h"

@implementation AMServer

@synthesize serverName;
@synthesize host;
@synthesize username;
@synthesize password;
@synthesize port;
@synthesize statusImagePath;
@synthesize standartOutput;
@synthesize standartInput;

#pragma mark -
#pragma mark Initializations
- (id) init
{
	self = [super init];
	
	[self setStandartOutput: [NSPipe pipe]];
	[self pingHost];
	
	return self;
}

- (void) dealloc
{
	host = nil;
	port = nil;
	username = nil;
	password = nil;
	serverName = nil;
	statusImagePath = nil;
	stdOut = nil;
	
}

- (id) initWithCoder:(NSCoder *)coder
{
	self = [super init];
	
	host		= [coder decodeObjectForKey:@"host"];
	port		= [coder decodeObjectForKey:@"port"];
	username	= [coder decodeObjectForKey:@"username"];
	password	= [coder decodeObjectForKey:@"password"];
	serverName	= [coder decodeObjectForKey:@"serverName"];
	
	[self setStandartInput:[NSPipe pipe]];
	
	[self pingHost];
	
	return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{	
	[coder encodeObject:host forKey:@"host"];
	[coder encodeObject:port forKey:@"port"];
	[coder encodeObject:username forKey:@"username"];
	[coder encodeObject:password forKey:@"password"];
	[coder encodeObject:serverName forKey:@"serverName"];
}


#pragma mark -
#pragma mark Overloaded accessors

- (NSString *) description
{
	return serverName;
}


#pragma mark -
#pragma mark Observers and delegates

- (void) handleEndOfPing:(NSNotification *) aNotification
{
	NSData		*data;
	NSString	*outputContent;
	NSPredicate *checkSuccess;
	
	data = [[aNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];
	
	outputContent		= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	checkSuccess		= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] '0% packet loss'"];
	
	
	if ([checkSuccess evaluateWithObject:outputContent] == YES)
		[self setStatusImagePath:[AMResourcesHelper pathForImageNamed:@"statusGreen"]];
	else
		[self setStatusImagePath:[AMResourcesHelper pathForImageNamed:@"statusRed"]];
	
	[[NSNotificationCenter defaultCenter]  removeObserver:self name:NSFileHandleReadCompletionNotification object:[stdOut fileHandleForReading]];
	[ping terminate];
	data = nil;
	outputContent = nil;
	checkSuccess = nil;
	ping = nil;
}


#pragma mark -
#pragma mark Helper methods

- (void) pingHost
{
	ping			= [[NSTask alloc] init];
	stdOut			= [NSPipe pipe];
	
	if ([self host] == nil)
		return;
	
	[self setStatusImagePath:[AMResourcesHelper pathForImageNamed:@"statusOrange"]];
	[ping setLaunchPath:@"/sbin/ping"];
	[ping setArguments:[NSArray arrayWithObjects:@"-c", @"1", @"-t", @"2", [self host], nil]];
	[ping setStandardOutput:stdOut];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(handleEndOfPing:)
												 name:NSFileHandleReadToEndOfFileCompletionNotification
											   object:[[ping standardOutput] fileHandleForReading]];
	
	
	[[stdOut fileHandleForReading] readToEndOfFileInBackgroundAndNotify];
	[ping launch];
}

- (void) openShellOnThisServer
{	
	NSTask *shellTask = [[NSTask alloc] init];
	[shellTask setLaunchPath:[[NSBundle mainBundle] pathForResource:@"SSHShell" ofType:@"command"]];
	[shellTask setArguments:[NSArray arrayWithObjects:[self username], [self password], nil]];
	[shellTask setStandardOutput:[self standartOutput]];
	
	
	[shellTask launch];
}
@end
