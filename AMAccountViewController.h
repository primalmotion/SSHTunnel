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

#import "messages.h"

#import "AMBaseViewController.h"
#import "AMServer.h"
#import "AMPopUpButton.h"
#import "AMServerViewController.h"

@interface AMAccountViewController : AMBaseViewController 
{
	BOOL							isCreatingAccount;
	IBOutlet AMPopUpButton			*serverPicker;
	IBOutlet AMServerViewController *serverController;
	IBOutlet NSButton				*createButton;
	NSMutableString					*__strong confirmPassword;
	NSMutableString					*__strong login;
	NSMutableString					*__strong password;
	NSPipe							*stdOut;
	NSTask							*sshTask;
}
@property(readwrite)			BOOL				isCreatingAccount;
@property(readwrite, strong)	NSMutableString		*confirmPassword;
@property(readwrite, strong)	NSMutableString		*login;
@property(readwrite, strong)	NSMutableString		*password;


#pragma mark -
#pragma mark Helper methods
- (BOOL) validateCurrentUserInformations;

#pragma mark -
#pragma mark Interface actions
- (IBAction) createAccount:(id)sender;

@end
