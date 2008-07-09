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

#import "AMAuth.h"

@implementation AMAuth

@synthesize serverName;
@synthesize host;
@synthesize username;
@synthesize password;
@synthesize port;

- (id) init
{
	self = [super init];
	
	[self addObserver:self forKeyPath:@"serverName" 
			  options:(NSKeyValueObservingOptionNew | 
					   NSKeyValueObservingOptionOld)
			  context:NULL];
	
	return self;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AMServerNameHasChanged" object:self];
}

- (id) initWithCoder:(NSCoder *)coder
{
	[super init];
	
	host		= [[coder decodeObjectForKey:@"host"] retain];
	port		= [[coder decodeObjectForKey:@"port"] retain];
	username	= [[coder decodeObjectForKey:@"username"] retain];
	password	= [[coder decodeObjectForKey:@"password"] retain];
	serverName	= [[coder decodeObjectForKey:@"serverName"] retain];
	
	[self addObserver:self forKeyPath:@"serverName" 
			  options:(NSKeyValueObservingOptionNew | 
					   NSKeyValueObservingOptionOld)
			  context:NULL];
	
	return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{	
	[coder encodeObject:host forKey:@"host"];
	[coder encodeObject:port forKey:@"port"];
	[coder encodeObject:username forKey:@"username"];
	[coder encodeObject:password forKey:@"password"];
	[coder encodeObject:serverName forKey:@"serverName"];
}

- (NSString *) description
{
	return host;
}

@end
