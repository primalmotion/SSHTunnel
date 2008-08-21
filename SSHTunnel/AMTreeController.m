//
//  AMTreeController.m
//  SSHTunnel
//
//  Created by Antoine Mercadal on 21/08/08.
//  Copyright 2008 Capgemini. All rights reserved.
//

#import "AMTreeController.h"


@implementation AMTreeController

- (BOOL) canRemove
{
	BOOL result =  [super canRemove];
	if (!result)
		return result;
	
	if (([self selection] != nil) && ([[[self selection] valueForKey:@"isGroup"] boolValue] == YES))
		result = NO;
	
	return result;
}

@end
