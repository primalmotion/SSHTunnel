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

#import "AMServerViewController.h"


@implementation AMServerViewController

@synthesize servers;
@synthesize serversArrayController;

- (id) init
{
	self = [super init];
	
	NSFileManager *f = [NSFileManager defaultManager];
	
	serverSavePath			=  @"~/Library/Application Support/SSHTunnel/servers.sst";
	
	if ([f fileExistsAtPath:[serverSavePath stringByExpandingTildeInPath]] == YES)
		[self setServers:[NSKeyedUnarchiver unarchiveObjectWithFile:[serverSavePath stringByExpandingTildeInPath]]];
	else
		[self setServers:[[NSMutableArray alloc] init]];
	
	f= nil;
	
	return self;
}

- (void) createObservers;
{
	[serversArrayController addObserver:self 
							 forKeyPath:@"selection.serverName" 
								options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								context:NULL];
	
	[serversArrayController addObserver:self 
							 forKeyPath:@"selection.host" 
								options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								context:NULL];
	
	[serversArrayController addObserver:self 
							 forKeyPath:@"selection.port" 
								options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								context:NULL];
	
	[serversArrayController addObserver:self 
							 forKeyPath:@"selection.username" 
								options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								context:NULL];
	
	[serversArrayController addObserver:self 
							 forKeyPath:@"selection.password" 
								options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								context:NULL];
}

- (void) awakeFromNib
{
	[self createObservers];
}


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[self saveState];
}

- (void) saveState
{
	if (pingDelayer != nil)
		[pingDelayer invalidate];
	
	NSLog(@"Servers saving processes programmed.");
	pingDelayer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(performSaveProcess:) userInfo:nil repeats:NO];
	
}

- (void) performSaveProcess:(NSTimer *)theTimer
{
	NSLog(@"Servers status saved.");
	[NSKeyedArchiver archiveRootObject:[self servers] toFile:[serverSavePath stringByExpandingTildeInPath]];
	[[self getSelectedServer] pingHost];
}

- (AMServer*) getSelectedServer
{
	return (AMServer*)[[serversArrayController selectedObjects] objectAtIndex:0];
}

- (IBAction) refreshPings:(id)sender
{
	for(AMServer *s in servers)
		[s pingHost];
}


@end
