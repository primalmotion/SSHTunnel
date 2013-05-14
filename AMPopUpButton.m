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

#import "AMPopUpButton.h"

@implementation AMPopUpButton

- (void) awakeFromNib
{
	accountServers = [[NSMutableArray alloc] init];
	NSString *path = [[NSBundle mainBundle] pathForResource:@"serversAccounts" ofType:@"plist"];
	NSData *plistData;
	NSString *error;
	NSPropertyListFormat format;
	plistData = [NSData dataWithContentsOfFile:path];

	
	NSMutableArray *plist = [NSPropertyListSerialization propertyListFromData:plistData mutabilityOption:NSPropertyListImmutable
													   format:&format errorDescription:&error];
	if(!plist)
	{
		NSLog(@"%@",error);
	}
	
	NSEnumerator* e = [plist objectEnumerator];
	NSDictionary* server = nil;
	while((server = [e nextObject]) != nil )
	{
		[self addItemWithTitle:[server valueForKey:@"name"]];
		[accountServers addObject:server];
	}
}

- (NSString *) getCurrentServerName
{
	return [[accountServers objectAtIndex:[self indexOfSelectedItem]] valueForKey:@"name"];
}

- (NSString *) getCurrentServerUrl
{
	return [[accountServers objectAtIndex:[self indexOfSelectedItem]] valueForKey:@"url"];
}

- (NSString *) getCurrentServerPort
{
	return [[accountServers objectAtIndex:[self indexOfSelectedItem]] valueForKey:@"port"];
}

- (NSString *) getCurrentServerShScriptName
{
	return [[accountServers objectAtIndex:[self indexOfSelectedItem]] valueForKey:@"shScriptName"];
}
@end
