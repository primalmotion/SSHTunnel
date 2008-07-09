//
//  ServerView.h
//  SSHTunnel
//
//  Created by Antoine Mercadal on 09/07/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import "AMAuth.h"
#import <Cocoa/Cocoa.h>


@interface AMServerViewController : NSObject {

	IBOutlet NSArrayController		*serversArrayController;
	
	NSMutableArray					*servers;
	NSString						*serverSavePath;
	
	
}

@property(readwrite, assign)	NSMutableArray		*servers;

- (void) saveState;
- (void) handleDataNameChange:(NSNotification*)notif;
- (AMAuth*) getSelectedServer;

@end
