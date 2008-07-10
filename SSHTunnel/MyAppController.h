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
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/CoreImage.h>
#import "AMSession.h"
#import "AMAuth.h"
#import "CGSPrivate.h"
#import "AMAccountViewController.h"
#import "AMServerViewController.h"
#import "AMSessionViewController.h"


@interface MyAppController : NSObject {
	
	IBOutlet NSTextField			 *errorMessage;
	IBOutlet NSView					 *errorPanel;
	IBOutlet NSWindow				 *mainWindow;
	IBOutlet NSView					 *serverView;
	IBOutlet NSView					 *mainView;
	IBOutlet NSView					 *aboutView;
	IBOutlet NSView					 *registerView;
	IBOutlet AMSessionViewController *sessionController;
	IBOutlet AMServerViewController  *serverController;

	NSTimer							 *timer;
	NSView							 *backViewReminder;
	NSString						 *hostName;
	
	
}
@property(readwrite, assign) NSString *hostName;

- (IBAction) toggleTunnel:(id)sender;
- (IBAction) openAllSession:(id)sender;
- (IBAction) closeAllSession:(id)sender;
- (IBAction) killAllSSH:(id)sender;


- (IBAction) displayServerView:(id)sender;
- (IBAction) displayAboutView:(id)sender;
- (IBAction) displayRegisterView:(id)sender;
- (IBAction) displayMainView:(id)sender;

- (IBAction) openMainWindow:(id)sender;
- (IBAction) closeMainWindow:(id)sender;


- (void) performInfoMessage:(NSNotification*)notif;
- (void) errorPanelDisplaywithMessage:(NSString *)message;
- (void) errorPanelClose:(NSTimer *)theTimer;

- (void) animateWindow:(NSWindow*)win effect:(CGSTransitionType)fx direction:(CGSTransitionOption)dir duration:(float)dur;





/// TMP ZONE




/// TMP ZONE
@end
