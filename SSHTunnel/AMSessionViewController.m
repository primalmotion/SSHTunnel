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

#import "AMSessionViewController.h"

@implementation AMSessionViewController

@synthesize	sessions;
@synthesize sessionsArrayController;

#pragma mark Initializations
- (id) init
{
	self = [super init];
	
	
	NSFileManager *f = [NSFileManager defaultManager];
	sessionSavePath	=  @"~/Library/Application Support/SSHTunnel/sessions.sst";
	
	@try
	{
		if ([f fileExistsAtPath:[sessionSavePath stringByExpandingTildeInPath]] == YES)
			[self setSessions:[NSKeyedUnarchiver unarchiveObjectWithFile:[sessionSavePath stringByExpandingTildeInPath]]];
		else
			[self setSessions:[[NSMutableArray alloc] init]];
	}
	@catch (NSException *e) 
	{
		int rep = NSRunAlertPanel(@"Error while loading datas", @"SSHTunnel was unable to load its saved state. Would you like to revert to the factory presets ? ", @"Yes", @"No", nil);
		if (rep == NSAlertDefaultReturn)
			[[NSNotificationCenter defaultCenter] postNotificationName:AMErrorLoadingSavedState object:nil];
		else
			exit(0);
	}
	
	f = nil;
	
	return self;
}

- (void) awakeFromNib
{
	
	NSInteger tunnelType = 0;
	if ([[sessionsArrayController arrangedObjects] count] > 0)
		tunnelType = [[[sessionsArrayController selectedObjects] objectAtIndex:0] sessionTunnelType];
	
	if (tunnelType == 0)
	{
		[tunnelConfigBox setContentView:outputTunnelConfigView];
	}
	else if (tunnelType == 1)
	{
		[tunnelConfigBox setContentView:inputTunnelConfigView];
		if ([[[[sessionsArrayController selectedObjects] objectAtIndex:0] remoteHost] isEqual:@""] == YES)
			[[[sessionsArrayController selectedObjects] objectAtIndex:0] setRemoteHost:@"127.0.0.1"];
	}
	else if (tunnelType == 2)
	{
		[tunnelConfigBox setContentView:proxyConfigView];
	}
	
	[self createObservers];
}

- (void) createObservers
{
	[sessionsArrayController addObserver:self 
							  forKeyPath:@"selection.currentServer" 
								 options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								 context:nil];
	
	[sessionsArrayController addObserver:self 
							  forKeyPath:@"selection.localPort" 
								 options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								 context:nil];
	
	[sessionsArrayController addObserver:self 
							  forKeyPath:@"selection.sessionName" 
								 options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								 context:nil];
	
	[sessionsArrayController addObserver:self 
							  forKeyPath:@"selection.remoteHost" 
								 options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								 context:nil];
	
	[sessionsArrayController addObserver:self 
							  forKeyPath:@"selection.remotePort" 
								 options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								 context:nil];

	[sessionsArrayController addObserver:self 
							  forKeyPath:@"selection.statusImagePath" 
								 options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								 context:nil];

	[sessionsArrayController addObserver:self 
							  forKeyPath:@"selection.tunnelTypeImagePath" 
								 options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								 context:nil];

	[sessionsArrayController addObserver:self 
							  forKeyPath:@"selection.outgoingTunnel" 
								 options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								 context:nil];
	
	[sessionsArrayController addObserver:self 
							  forKeyPath:@"selection.useDynamicProxy" 
								 options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								 context:nil];
	
	[sessionsArrayController addObserver:self 
							  forKeyPath:@"selection.dynamicProxyPort" 
								 options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								 context:nil];
	
	
	
}



#pragma mark Observers and delegates
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqual:@"selection.outgoingTunnel"])
	{
		NSInteger tunnelType = [[[object selectedObjects] objectAtIndex:0] sessionTunnelType];
		
		if (tunnelType == 0)
		{
			[tunnelConfigBox setContentView:outputTunnelConfigView];
		}
		else if (tunnelType == 1)
		{
			[tunnelConfigBox setContentView:inputTunnelConfigView];
			if ([[[[sessionsArrayController selectedObjects] objectAtIndex:0] remoteHost] length] == 0)
			{
				[[[object selectedObjects] objectAtIndex:0] setRemoteHost:@"127.0.0.1"];
				NSLog(@"remote host empty: filling with : %@", [[[object selectedObjects] objectAtIndex:0] remoteHost]);
			}
		}
		else if (tunnelType == 2)
		{
			[tunnelConfigBox setContentView:proxyConfigView];
		}
	}
	
	[self saveState];
}



#pragma mark Saving processes
- (void) saveState
{
	if (pingDelayer != nil)
		[pingDelayer invalidate];
	
	NSLog(@"Sessions saving processes programmed.");
	pingDelayer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(performSaveProcess:) userInfo:nil repeats:NO];
	
}

- (void) performSaveProcess:(NSTimer *)theTimer
{
	NSLog(@"Sessions status saved.");
	[NSKeyedArchiver archiveRootObject:[self sessions] toFile:[sessionSavePath stringByExpandingTildeInPath]];
}



#pragma mark Helper methods

- (AMSession*) getSelectedSession
{
	if ([[sessionsArrayController selectedObjects] count] > 0)
		 return (AMSession*)[[sessionsArrayController selectedObjects] objectAtIndex:0];
	else
		 return nil;
}


@end
