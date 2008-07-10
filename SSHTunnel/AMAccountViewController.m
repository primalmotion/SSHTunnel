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

#import "AMAccountViewController.h"

@implementation AMAccountViewController

@synthesize login;
@synthesize password;
@synthesize confirmPassword;
@synthesize isCreatingAccount;

- (id) init
{
	self = [super init];
	
	[self setIsCreatingAccount:NO];

	return self;
}

- (IBAction) createAccount:(id)sender
{
	
	if ([self isCreatingAccount] == NO)
	{
		stdOut			= [NSPipe pipe];
		sshTask			= [[NSTask alloc] init];
		outputContent	= @"";
		NSString		*helperPath = nil;
		NSArray			*args = nil;

		if ([[serverPicker titleOfSelectedItem] isEqual:@"Abornet.org"])
		{
			helperPath		= [[NSBundle mainBundle] pathForResource:@"createAbornetAccount" ofType:@"sh"];
			args			= [NSArray arrayWithObjects:login, password, nil];
		}
		else
			return;
			
		if ([password length] >= 6)
		{
			if (![password isEqual:confirmPassword])
			{
				NSRunAlertPanel(@"Incorrect password", @"Your password not matching", @"Ok", nil, nil);
				return;
			}
		}
		else
		{
			NSRunAlertPanel(@"Incorrect password", @"Your password must be at least 6 characters", @"Ok", nil, nil);
			return;
		}
		
		if ([login length] >= 7)
		{
			NSRunAlertPanel(@"Incorrect username", @"Your login must be at maximum of 6 characters lenght", @"Ok", nil, nil);
			return;
		}
	
		[sshTask setLaunchPath:helperPath];
		[sshTask setArguments:args];
		[sshTask setStandardOutput:stdOut];
		
		
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(checkShStatus:)
													 name:NSFileHandleReadCompletionNotification
												   object:[[sshTask standardOutput] fileHandleForReading]];

		[[stdOut fileHandleForReading] readInBackgroundAndNotify];
		[self setIsCreatingAccount:YES];
		[sshTask launch];
	}
	else
	{
		[sshTask terminate];
		[createButton setTitle:@"Register on Abornet"];
		[self setIsCreatingAccount:NO];
	}
}


- (void) checkShStatus:(NSNotification *) aNotification
{
	NSData		*data;
	NSPredicate *checkExistingLogin;
	NSPredicate *checkSuccess;

	
	data = [[aNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];
	
	outputContent		= [outputContent stringByAppendingString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
	checkExistingLogin	= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'LOGIN_EXISTS'"];
	checkSuccess		= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'LOGIN_CREATED'"];

	
	NSLog(@"-- %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
	if ([data length])
	{
		if ([checkExistingLogin evaluateWithObject:outputContent] == YES)
		{
			[[NSNotificationCenter defaultCenter]  removeObserver:self name:NSFileHandleReadCompletionNotification object:[stdOut fileHandleForReading]];
			[sshTask terminate];
			NSRunAlertPanel(@"Error", @"Login already exists", @"ok", nil, nil);
			[self setIsCreatingAccount:NO];
		}
		else if ([checkSuccess evaluateWithObject:outputContent] == YES)
		{
			[[NSNotificationCenter defaultCenter]  removeObserver:self 
															 name:NSFileHandleReadCompletionNotification 
														   object:[stdOut fileHandleForReading]];
			[sshTask terminate];
			[self setIsCreatingAccount:NO];
			NSRunAlertPanel(@"Account Created", @"Operation sucess. The server has been added into the list", 
							@"Ok", nil, nil);
			
			AMAuth *newAuth = [[AMAuth alloc] init];
			[newAuth setServerName:@"Abornet"];
			[newAuth setHost:@"m-net.arbornet.org"];
			[newAuth setPort:@"22"];
			[newAuth setUsername:login];
			[newAuth setPassword:password];
			[[serverController serversArrayController] addObject:newAuth];
			[serverController saveState];
		}
		else
			[[stdOut fileHandleForReading] readInBackgroundAndNotify];
		
		data = nil;
		checkExistingLogin = nil;
		checkSuccess = nil;
	}
}

@end
