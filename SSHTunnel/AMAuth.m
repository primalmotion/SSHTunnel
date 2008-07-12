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

#import "AMAuth.h"

@implementation AMAuth

@synthesize serverName;
@synthesize host;
@synthesize username;
@synthesize password;
@synthesize port;
@synthesize statusImagePath;

- (id) init
{
	self = [super init];
	
	[self addObserver:self forKeyPath:@"serverName" 
			  options:(NSKeyValueObservingOptionNew | 
					   NSKeyValueObservingOptionOld)
			  context:NULL];
	
	[self pingHost];
	
	return self;
}

- (void) pingHost
{
	ping			= [[NSTask alloc] init];
	stdOut			= [NSPipe pipe];
	
	[self setStatusImagePath:[[NSBundle mainBundle] pathForResource:@"statusOrange" ofType:@"tif"]];
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

- (void) handleEndOfPing:(NSNotification *) aNotification
{
	NSData		*data;
	NSString	*outputContent;
	NSPredicate *checkSuccess;
	
	data = [[aNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];
		
	outputContent		= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	checkSuccess		= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] '0% packet loss'"];
	
	
	if ([checkSuccess evaluateWithObject:outputContent] == YES)
		[self setStatusImagePath:[[NSBundle mainBundle] pathForResource:@"statusGreen" ofType:@"tif"]];
	else
		[self setStatusImagePath:[[NSBundle mainBundle] pathForResource:@"statusRed" ofType:@"tif"]];
	
	[[NSNotificationCenter defaultCenter]  removeObserver:self name:NSFileHandleReadCompletionNotification object:[stdOut fileHandleForReading]];
	[ping terminate];
	data = nil;
	outputContent = nil;
	checkSuccess = nil;
	ping = nil;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AMServerNameHasChanged" object:self];
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
	
	[super dealloc];
}

- (id) initWithCoder:(NSCoder *)coder
{
	[super init];
	
	host		= [[coder decodeObjectForKey:@"host"] retain];
	port		= [[coder decodeObjectForKey:@"port"] retain];
	username	= [[coder decodeObjectForKey:@"username"] retain];
	password	= [[coder decodeObjectForKey:@"password"] retain];
	serverName	= [[coder decodeObjectForKey:@"serverName"] retain];
	
	[self addObserver:self forKeyPath:@"serverName" 
			  options:(NSKeyValueObservingOptionNew | 
					   NSKeyValueObservingOptionOld)
			  context:NULL];
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

- (NSString *) description
{
	return serverName;
}

@end
