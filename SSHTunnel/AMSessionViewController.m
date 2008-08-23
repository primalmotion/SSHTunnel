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
@synthesize sessionsTreeController;

#pragma mark -
#pragma mark Initializations

- (id) init
{
	self = [super init];
	
	
	
	return self;
}

- (void) awakeFromNib
{
	NSFileManager *f = [NSFileManager defaultManager];
	sessionSavePath	=  [[[NSUserDefaults standardUserDefaults] stringForKey:@"applicationSupportFolder"] stringByAppendingString:@"/sessions.sst"];
	@try
	{
		if ([f fileExistsAtPath:[sessionSavePath stringByExpandingTildeInPath]] == YES)
			[self setSessions:[NSKeyedUnarchiver unarchiveObjectWithFile:[sessionSavePath stringByExpandingTildeInPath]]];
		else
		{
			NSLog(@"No sessions.sst file found. Regenerating the root tree.");
			
			[self setSessions:[[NSMutableArray alloc] init]];
			
			AMSession *outgoing = [[AMSession alloc] init];
			[outgoing setSessionName:AMGroupOutgoingName];
			[outgoing setIsLeaf:NO];
			[outgoing setIsGroup:YES];
			[outgoing setSessionTunnelType:AMSessionCategory];
			[outgoing setStatusImagePath:@""];
			[outgoing setChildrens:[NSMutableArray array]];
			[[self sessions] addObject:outgoing];
			
			AMSession *incoming = [[AMSession alloc] init];
			[incoming setSessionName:AMGroupIncomingName];
			[incoming setIsLeaf:NO];
			[incoming setIsGroup:YES];
			[incoming setStatusImagePath:@""];
			[incoming setSessionTunnelType:AMSessionCategory];
			[incoming setChildrens:[NSMutableArray array]];
			[[self sessions] addObject:incoming];
			
			AMSession *proxies = [[AMSession alloc] init];
			[proxies setSessionName:AMGroupProxyName];
			[proxies setIsLeaf:NO];
			[proxies setIsGroup:YES];
			[proxies setStatusImagePath:@""];
			[proxies setSessionTunnelType:AMSessionCategory];
			[proxies setChildrens:[NSMutableArray array]];
			[[self sessions] addObject:proxies];
		}
	}
	@catch (NSException *e) 
	{
		int rep = NSRunAlertPanel(@"Error while loading datas", @"SSHTunnel was unable to load its saved state. Would you like to revert to the factory presets ? ", @"Yes", @"No", nil);
		if (rep == NSAlertDefaultReturn)
			[[NSNotificationCenter defaultCenter] postNotificationName:AMErrorLoadingSavedState object:nil];
		else
			exit(-1);
	}
	f = nil;
	
	NSInteger tunnelType = AMSessionOutgoingTunnel;
	if ([[sessionsTreeController arrangedObjects] count] > 0)
		tunnelType = [[[sessionsTreeController selectedObjects] objectAtIndex:0] sessionTunnelType];
	
	if (tunnelType == AMSessionOutgoingTunnel)
	{
		[tunnelConfigBox setContentView:outputTunnelConfigView];
	}
	else if (tunnelType == AMSessionIncomingTunnel)
	{
		[tunnelConfigBox setContentView:inputTunnelConfigView];
		if ([[[[sessionsTreeController selectedObjects] objectAtIndex:0] remoteHost] isEqual:@""] == YES)
			[[[sessionsTreeController selectedObjects] objectAtIndex:0] setRemoteHost:@"127.0.0.1"];
	}
	else if (tunnelType == AMSessionGlobalProxy)
	{
		[tunnelConfigBox setContentView:proxyConfigView];
	}
	
	[self createObservers];
	
	//expand all items in outlineview
	NSUInteger i;
	for (i = 0; i < [sessionsOutlineView numberOfRows]; i++)
		[sessionsOutlineView expandItem:[sessionsOutlineView itemAtRow:i]];
	
	//resize the splitview
	NSRect frame = [[[splitView subviews] objectAtIndex:0] frame];
	frame.size.width = 190;
	[[[splitView subviews] objectAtIndex:0] setFrame:frame];
	[splitView addSubview:groupInfoView];
	
}



#pragma mark -
#pragma mark Observers and delegates

- (void) createObservers
{
	[sessionsTreeController addObserver:self 
							 forKeyPath:@"selection.currentServer" 
								options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								context:nil];
	
	[sessionsTreeController addObserver:self 
							 forKeyPath:@"selection.localPort" 
								options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								context:nil];
	
	[sessionsTreeController addObserver:self 
							 forKeyPath:@"selection.sessionName" 
								options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								context:nil];
	
	[sessionsTreeController addObserver:self 
							 forKeyPath:@"selection.remoteHost" 
								options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								context:nil];
	
	[sessionsTreeController addObserver:self 
							 forKeyPath:@"selection.remotePort" 
								options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								context:nil];
	
	[sessionsTreeController addObserver:self 
							 forKeyPath:@"selection.statusImagePath" 
								options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								context:nil];
	
	[sessionsTreeController addObserver:self 
							 forKeyPath:@"selection.tunnelTypeImagePath" 
								options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								context:nil];
	
	[sessionsTreeController addObserver:self 
							 forKeyPath:@"selection.outgoingTunnel" 
								options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								context:nil];
	
	[sessionsTreeController addObserver:self 
							 forKeyPath:@"selection.useDynamicProxy" 
								options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								context:nil];
	
	[sessionsTreeController addObserver:self 
							 forKeyPath:@"selection.dynamicProxyPort" 
								options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								context:nil];
	
	[sessionsTreeController addObserver:self 
							 forKeyPath:@"selection.childrens" 
								options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								context:nil];
	
	[sessionsTreeController addObserver:self 
							 forKeyPath:@"selection.autostart" 
								options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								context:nil];
	
	[sessionsTreeController addObserver:self 
							 forKeyPath:@"selection.autoReconnect" 
								options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								context:nil];
	
	
	[sessionsTreeController addObserver:self 
							 forKeyPath:@"selection.networkService" 
								options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								context:nil];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqual:@"selection.sessionName"])
	{
		NSInteger tunnelType = [[[object selectedObjects] objectAtIndex:0] sessionTunnelType];
		if (tunnelType == AMSessionCategory)
		{
			[splitView replaceSubview:editSessionView with:groupInfoView];
		}
		else
		{
			[splitView replaceSubview:groupInfoView with:editSessionView];

			if (tunnelType == AMSessionOutgoingTunnel)
			{
				[tunnelConfigBox setContentView:outputTunnelConfigView];
			}
			else if (tunnelType == AMSessionIncomingTunnel)
			{
				[tunnelConfigBox setContentView:inputTunnelConfigView];
				if ([[[[sessionsTreeController selectedObjects] objectAtIndex:0] remoteHost] length] == 0)
				{
					[[[object selectedObjects] objectAtIndex:0] setRemoteHost:@"127.0.0.1"];
					NSLog(@"remote host empty: filling with : %@", [[[object selectedObjects] objectAtIndex:0] remoteHost]);
				}
			}
			else if (tunnelType == AMSessionGlobalProxy)
			{
				[tunnelConfigBox setContentView:proxyConfigView];
			}
		}
		[self saveState];
	}
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
	return ([outlineView parentForItem:item] == nil);
}



#pragma mark -
#pragma mark Interface actions

- (IBAction) addNewOutgoingSession:(id)sender
{
	AMSession *newSession = [[AMSession alloc] init];
	[newSession setIsLeaf:YES];
	[newSession setIsGroup:NO];
	[newSession setSessionTunnelType:AMSessionOutgoingTunnel];
	[newSession setChildrens:[NSMutableArray array]];
	
	NSUInteger *path = malloc(sizeof(NSUInteger) * 2);
	NSUInteger i = 0;
	NSUInteger j = -1;
	for (i = 0; i < [sessionsOutlineView numberOfRows]; i++)
	{
		if ([[[sessionsOutlineView itemAtRow:i] representedObject] isGroup])
		{
			j++;
			if ([[[[sessionsOutlineView itemAtRow:i] representedObject] sessionName] isEqualToString:AMGroupOutgoingName])
			{
				path[0] = j;
				break;
			}
		}
	}
	path[1] = 0;
		
	[sessionsTreeController insertObject:newSession atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndexes:path length:2]];
	free(path);
}

- (IBAction) addNewIncomingSession:(id)sender
{
	AMSession *newSession = [[AMSession alloc] init];
	[newSession setIsLeaf:YES];
	[newSession setIsGroup:NO]; 
	[newSession setSessionTunnelType:AMSessionIncomingTunnel];
	[newSession setChildrens:[NSMutableArray array]];
	
	NSUInteger *path = malloc(sizeof(NSUInteger) * 2);
	
	NSUInteger i = 0;
	NSUInteger j = -1;
	for (i = 0; i < [sessionsOutlineView numberOfRows]; i++)
	{
		if ([[[sessionsOutlineView itemAtRow:i] representedObject] isGroup])
		{
			j++;
			if ([[[[sessionsOutlineView itemAtRow:i] representedObject] sessionName] isEqualToString:AMGroupIncomingName])
			{
				path[0] = j;
				break;
			}
		}
	}
	path[1] = 0;	
	
	[sessionsTreeController insertObject:newSession atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndexes:path length:2]];
	free(path);
}

- (IBAction) addNewProxySession:(id)sender
{
	AMSession *newSession = [[AMSession alloc] init];
	[newSession setIsLeaf:YES];
	[newSession setIsGroup:NO];
	[newSession setSessionTunnelType:AMSessionGlobalProxy];
	[newSession setChildrens:[NSMutableArray array]];
	
	NSUInteger *path = malloc(sizeof(NSUInteger) * 2);
	NSUInteger i = 0;
	NSUInteger j = -1;
	for (i = 0; i < [sessionsOutlineView numberOfRows]; i++)
	{
		if ([[[sessionsOutlineView itemAtRow:i] representedObject] isGroup])
		{
			j++;
			if ([[[[sessionsOutlineView itemAtRow:i] representedObject] sessionName] isEqualToString:AMGroupProxyName])
			{
				path[0] = j;
				break;
			}
		}
	}
	path[1] = 0;
	
	[sessionsTreeController insertObject:newSession atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndexes:path length:2]];
	free(path);	
}




#pragma mark -
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



#pragma mark -
#pragma mark Helper methods

- (AMSession*) getSelectedSession
{
	if ([[sessionsTreeController selectedObjects] count] > 0)
		 return (AMSession*)[[sessionsTreeController selectedObjects] objectAtIndex:0];
	else
		 return nil;
}


@end
