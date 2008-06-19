//
//  AMAuth.m
//  SSHTunnel
//
//  Created by Antoine Mercadal on 18/06/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import "AMAuth.h"


@implementation AMAuth

@synthesize host;
@synthesize username;
@synthesize password;

- (id) initWithCoder:(NSCoder *)coder
{
	[super init];
	
	host		= [[coder decodeObjectForKey:@"host"] retain];
	username	= [[coder decodeObjectForKey:@"username"] retain];
	password	= [[coder decodeObjectForKey:@"password"] retain];
	return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{	
	[coder encodeObject:host forKey:@"host"];
	[coder encodeObject:username forKey:@"username"];
	[coder encodeObject:password forKey:@"password"];
}

@end
