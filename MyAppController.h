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
#import <Security/Security.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/CoreImage.h>

#import "messages.h"

#import "AMSession.h"
#import "AMServer.h"
#import "AMAccountViewController.h"
#import "AMServerViewController.h"
#import "AMSessionViewController.h"
#import "AMBaseViewController.h"
#import "AMServiceViewController.h"


@interface MyAppController : AMBaseViewController {
	
	IBOutlet NSTextField				*errorMessage;
	IBOutlet NSView						*errorPanel;
	IBOutlet NSView						*serverView;
	IBOutlet NSView						*sessionView;
	IBOutlet NSView						*aboutView;
	IBOutlet NSView						*registerView;
	IBOutlet NSView						*serviceView;
	IBOutlet NSMenu						*taskBarMenu;
	IBOutlet NSView						*preferencesView;
	IBOutlet AMSessionViewController	*sessionController;
	IBOutlet AMServerViewController		*serverController;
	IBOutlet AMServiceViewController	*serviceController;
	IBOutlet NSUserDefaultsController	*preferencesController;
	
	NSTimer							*timer;
	NSView							*backViewReminder;
	NSString						*__strong hostName;
	CATransition					*transition;
	NSDictionary					*currentAnimation;
	NSStatusItem					*statusBarItem;
	NSRect							oldWindowFrame;
	NSInteger						preferencesViewHeight;
	
	
}
@property(readwrite, strong) NSString *hostName;

#pragma mark -
#pragma mark Interface Actions
- (IBAction) openSessionInSafari:(id)sender;
- (IBAction) toggleTunnel:(id)sender;
- (IBAction) openSession:(id)sender;
- (IBAction) closeSession:(id)sender;
- (IBAction) openAllSession:(id)sender;
- (IBAction) closeAllSession:(id)sender;
- (IBAction) killAllSSH:(id)sender;
- (IBAction) checkForNewVersion:(id)sender;
- (IBAction) resetApplicationSupportFolder:(id)sender;
- (IBAction) openMainWindow:(id)sender;
- (IBAction) closeMainWindow:(id)sender;
- (IBAction) applyCurrentServerToAllSessions:(id)sender;

#pragma mark -
#pragma mark View management
- (IBAction) displayServerView:(id)sender;
- (IBAction) displayAboutView:(id)sender;
- (IBAction) displayRegisterView:(id)sender;
- (IBAction) displaySessionView:(id)sender;
- (IBAction) displayServiceView:(id)sender;
- (IBAction) displayPreferenceView:(id)sender;

#pragma mark -
#pragma mark Helper methods
- (void) prepareApplicationSupports: (NSFileManager *) fileManager; 
- (void) resetAndRestart;
- (void) executeKillAllSSH:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void) setAnimationsTypes;
- (void) checkNewVersionOnServerFromUser:(BOOL)userRequest;
- (BOOL) stopAllOtherRunningGlobalProxy;
- (void) performAutostart;
- (void) prepareStatusBarMenu;

#pragma mark -
#pragma mark Observer and Delegates
- (void) createObservers;

#pragma mark -
#pragma mark Messaging methods
- (void) performInfoMessage:(NSNotification*)notif;
- (void) errorPanelDisplaywithMessage:(NSString *)message;
- (void) errorPanelClose:(NSTimer *)theTimer;


@end
