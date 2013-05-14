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

#import <Cocoa/Cocoa.h>

#import "messages.h"

#import "AMBaseViewController.h"
#import "AMServer.h"

@interface AMServerViewController : AMBaseViewController 
{
	IBOutlet NSArrayController		*__strong serversArrayController;
	NSMutableArray					*__strong servers;
	NSString						*serverSavePath;
	NSTimer							*pingDelayer;
}

@property(readwrite, strong)	NSArrayController	*serversArrayController;
@property(readwrite, strong)	NSMutableArray		*servers;

#pragma mark -
#pragma mark Observers and delegates
- (void) createObservers;

#pragma mark -
#pragma mark Saving processes
- (void) performSaveProcess:(NSTimer *)theTimer;
- (void) saveState;

#pragma mark -
#pragma mark Helper methods
- (AMServer*) getSelectedServer;

#pragma mark -
#pragma mark Interface actions
- (IBAction) refreshPings:(id)sender;
- (IBAction) openShellOnCurrentServer:(id)sender;

@end
