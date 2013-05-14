//
//  AMNEtworkServicesChooser.h
//  SSHTunnel
//
//  Created by Antoine Mercadal on 23/08/08.
//  Copyright 2008 Capgemini. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AMNetworkServicesChooser : NSPopUpButton
{
	NSMutableArray	*__strong content;
	
	NSTask			*task;
	NSPipe			*stdOut;
	
}
@property(readwrite, strong)	NSMutableArray *content;

- (void) handleEndOfTask:(NSNotification *) aNotification;
- (void) getSystemNetworkServices;
@end
