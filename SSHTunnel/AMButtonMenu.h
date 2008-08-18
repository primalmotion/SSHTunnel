//
//  AMButtonMenu.h
//  SSHTunnel
//
//  Created by Antoine Mercadal on 18/08/08.
//  Copyright 2008 Capgemini. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AMButtonMenu : NSButton {
	NSPopUpButtonCell *popUpCell;
	IBOutlet NSMenu	*popUpMenu;
}

@end
