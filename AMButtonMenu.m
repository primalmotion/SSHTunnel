//
//  AMButtonMenu.m
//  SSHTunnel
//
//  Created by Antoine Mercadal on 18/08/08.
//  Copyright 2008 Capgemini. All rights reserved.
//

#import "AMButtonMenu.h"


@implementation AMButtonMenu

- (void)awakeFromNib
{
    popUpCell = [[NSPopUpButtonCell alloc] initTextCell:@"" pullsDown:YES];
    [popUpCell setMenu:popUpMenu];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(menuClosed:)
												 name:NSMenuDidEndTrackingNotification
											   object:popUpMenu];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	[self highlight:YES];
	[popUpCell performClickWithFrame:[self bounds] inView:self];
}

- (void)menuClosed:(NSNotification *)note
{
	[self highlight:NO];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSMenuDidEndTrackingNotification
												  object:popUpMenu];
}

@end
