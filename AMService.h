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


@interface AMService : NSObject <NSCoding> 
{
	BOOL		inputService;
	NSString	*serviceDescription;
	NSString	*serviceLocalPorts;
	NSString	*serviceName;
	NSString	*serviceRemotePorts;

}
@property(readwrite)			BOOL		inputService;
@property(readwrite)	NSString	*serviceDescription;
@property(readwrite)	NSString	*serviceLocalPorts;
@property(readwrite)	NSString	*serviceName;
@property(readwrite)	NSString	*serviceRemotePorts;

#pragma mark -
#pragma mark Initializations
- (id) initWithName:(NSString*)name localPorts:(NSString*)localports remotePorts:(NSString*)remoteports description:(NSString*)desc input:(BOOL)isInput;

@end