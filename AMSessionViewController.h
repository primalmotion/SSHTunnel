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

#import "AMBaseViewController.h"
#import "AMSession.h"
#import "messages.h"




@interface AMSessionViewController :AMBaseViewController 
{	
	IBOutlet NSBox					*tunnelConfigBox;
	IBOutlet NSOutlineView			*sessionsOutlineView;
	IBOutlet NSSplitView			*splitView;
	IBOutlet NSTreeController		*__strong sessionsTreeController;
	IBOutlet NSView					*editSessionView;
	IBOutlet NSView					*groupInfoView;
	IBOutlet NSView					*inputTunnelConfigView;
	IBOutlet NSView					*outputTunnelConfigView;
	IBOutlet NSView					*proxyConfigView;
	NSMutableArray					*__strong sessions;
	NSString						*sessionSavePath;
	NSTimer							*pingDelayer;


}
@property(readwrite, strong)	NSMutableArray		*sessions;
@property(readwrite, strong)	NSTreeController	*sessionsTreeController;

#pragma mark -
#pragma mark Observers and delegates
- (void) createObservers;

#pragma mark -
#pragma mark Saving processes
- (void) performSaveProcess:(NSTimer *)theTimer;
- (void) saveState;

#pragma mark -
#pragma mark Helper methods
- (AMSession*) getSelectedSession;

#pragma mark -
#pragma mark Interface actions
- (IBAction) addNewOutgoingSession:(id)sender;
- (IBAction) addNewIncomingSession:(id)sender;
- (IBAction) addNewProxySession:(id)sender;
@end
