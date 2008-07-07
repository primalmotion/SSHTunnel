//
//  AMAuth.h
//  SSHTunnel
//
//  Created by Antoine Mercadal on 18/06/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
    @class
    @abstract    This class is the server object to remember the connection 
    @discussion  <#(comprehensive description)#>
*/

@interface AMAuth : NSObject <NSCoding> {
	NSString	*host;
	NSString	*port;
	NSString	*username;
	NSString	*password;
}
@property(readwrite, copy) NSString	*host;
@property(readwrite, copy) NSString *port;
@property(readwrite, copy) NSString	*username;
@property(readwrite, copy) NSString	*password;

@end
