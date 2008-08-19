//
//  AMSwitchButton.h
//  SSHTunnel
//
//  Created by Antoine Mercadal on 18/08/08.
//  Copyright 2008 Capgemini. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MyAppController.h"
#import "AMSessionViewController.h";

@interface AMSwitchButton : NSView {
	IBOutlet NSView	*switchView;
	IBOutlet NSView *backgroundImage;
	IBOutlet MyAppController *appController;
	IBOutlet AMSessionViewController *sessionController;
	IBOutlet NSView *onLabel;
	IBOutlet NSView *offLabel;
	
	NSColor *startingColor;
	NSColor *endingColor;
	BOOL status;
}

@property(readwrite) BOOL status;

- (IBAction) switchStatus:(id)sender;
- (void) pushOn;
- (void) pushOff;
@end
