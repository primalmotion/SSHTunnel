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


- (id) init
{
	self = [super init];
	
	NSFileManager *f = [NSFileManager defaultManager];
	sessionSavePath	=  @"~/Library/Application Support/SSHTunnel/sessions.sst";
	
	if ([f fileExistsAtPath:[sessionSavePath stringByExpandingTildeInPath]] == YES)
		[self setSessions:[NSKeyedUnarchiver unarchiveObjectWithFile:[sessionSavePath stringByExpandingTildeInPath]]];
	else
		[self setSessions:[[NSMutableArray alloc] init]];
	
	[sessionsArrayController addObserver:self 
							  forKeyPath:@"arrangedObjects" 
								 options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								 context:NULL];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(handleDataNameChange:) 
												 name:@"AMSessionNameHasChange" 
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
	NSLog(@"Sessions status saved.");
	[NSKeyedArchiver archiveRootObject:[self sessions] toFile:[sessionSavePath stringByExpandingTildeInPath]];
}

- (AMSession*) getSelectedSession
{
	return (AMSession*)[[sessionsArrayController selectedObjects] objectAtIndex:0];
}


@end
