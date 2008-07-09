//
//  ServerView.m
//  SSHTunnel
//
//  Created by Antoine Mercadal on 09/07/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import "AMServerViewController.h"


@implementation AMServerViewController

@synthesize servers;

- (id) init
{
	self = [super init];
	
	NSFileManager *f = [NSFileManager defaultManager];
	
	serverSavePath			=  @"~/Library/Application Support/SSHTunnel/servers.sst";
	
	if ([f fileExistsAtPath:[serverSavePath stringByExpandingTildeInPath]] == YES)
		[self setServers:[NSKeyedUnarchiver unarchiveObjectWithFile:[serverSavePath stringByExpandingTildeInPath]]];
	else
		[self setServers:[[NSMutableArray alloc] init]];
	
	[serversArrayController addObserver:self 
							 forKeyPath:@"arrangedObjects" 
								options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								context:NULL];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(handleDataNameChange:) 
												 name:@"AMServerNameHasChanged" 
											   object:nil];

	return self;
	
}

- (void) handleDataNameChange:(NSNotification*)notif
{
	[self saveState];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[self saveState];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	[self saveState];
}

- (void) saveState
{
	NSLog(@"Servers status saved.");
	[NSKeyedArchiver archiveRootObject:[self servers] toFile:[serverSavePath stringByExpandingTildeInPath]];
}

- (AMAuth*) getSelectedServer
{
	return (AMAuth*)[[serversArrayController selectedObjects] objectAtIndex:0];
}



@end
