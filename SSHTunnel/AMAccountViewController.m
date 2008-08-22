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


#pragma mark -
#pragma mark Initializations
- (id) init
{
	self = [super init];
	
	[self setIsCreatingAccount:NO];
	return self;
}


#pragma mark -
#pragma mark Observers and delegates

- (void) checkShStatus:(NSNotification *) aNotification
{
	NSData		*data;
	NSString	*outputContent	= @"";
	NSPredicate *checkExistingLogin;
	NSPredicate *checkSuccess;

	
	data = [[aNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];
	outputContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

	checkExistingLogin	= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'LOGIN_EXISTS'"];
	checkSuccess		= [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'LOGIN_CREATED'"];

	if ([data length])
	{
		if ([checkExistingLogin evaluateWithObject:outputContent] == YES)
		{
			[[NSNotificationCenter defaultCenter]  removeObserver:self name:NSFileHandleReadCompletionNotification object:[stdOut fileHandleForReading]];
			[sshTask terminate];
			[self setIsCreatingAccount:NO];
			[mainApplicationWindow runSheetAlertTitle:NSLocalizedString(@"ACCOUNT_CREATION_INCORRECT_LOGIN_TITLE", nil) 
											  message:NSLocalizedString(@"ACCOUNT_CREATION_INCORRECT_LOGIN_EXISTS", nil)
										  firstButton:NSLocalizedString(@"OK", nil)
										 secondButton:nil 
												 from:self
											 selector:nil];
		}
		else if ([checkSuccess evaluateWithObject:outputContent] == YES)
		{
			[[NSNotificationCenter defaultCenter]  removeObserver:self 
															 name:NSFileHandleReadCompletionNotification 
														   object:[stdOut fileHandleForReading]];
			[sshTask terminate];
			[self setIsCreatingAccount:NO];
			[mainApplicationWindow runSheetAlertTitle:NSLocalizedString(@"ACCOUNT_CREATION_SUCESSFULL_TITLE", nil) 
											  message:NSLocalizedString(@"ACCOUNT_string_CREATION_SUCCESSFULL", nil)
										  firstButton:NSLocalizedString(@"OK", nil)
										 secondButton:nil 
												 from:self
											 selector:nil];
			
			AMServer *newAuth = [[AMServer alloc] init];
			[newAuth setServerName:[serverPicker getCurrentServerName]];
			[newAuth setHost:[serverPicker getCurrentServerUrl]];
			[newAuth setPort:[serverPicker getCurrentServerPort]];
			[newAuth setUsername:login];
			[newAuth setPassword:password];
			[[serverController serversArrayController] addObject:newAuth];
			[serverController saveState];
			outputContent = nil;
		}
		else
			[[stdOut fileHandleForReading] readInBackgroundAndNotify];
		
		data = nil;
		checkExistingLogin = nil;
		checkSuccess = nil;
		outputContent = nil;
		
	}
}


#pragma mark -
#pragma mark Helper methods

- (BOOL) validateCurrentUserInformations
{
	if (![[NSFileManager defaultManager] fileExistsAtPath:[[NSBundle mainBundle] 
														   pathForResource:[serverPicker getCurrentServerShScriptName]
														   ofType:@"sh"]])
	{
		[self setIsCreatingAccount:NO];
		[mainApplicationWindow runSheetAlertTitle:NSLocalizedString(@"INTERNAL_ERROR_MESSAGE", nil) 
										  message:NSLocalizedString(@"ACCOUNT_SERVER_PLIST_WRONG_MESSAGE", nil)
									  firstButton:NSLocalizedString(@"OK", nil)
									 secondButton:nil 
											 from:self
										 selector:nil];
		return NO;
	}
	
	if ([password length] < 6)
	{
		[self setIsCreatingAccount:NO];
		[mainApplicationWindow runSheetAlertTitle:NSLocalizedString(@"ACCOUNT_CREATION_INCORRECT_PASSWORD_TITLE", nil) 
										  message:NSLocalizedString(@"ACCOUNT_CREATION_INCORRECT_PASSWORD_TOO_SHORT", nil)
									  firstButton:NSLocalizedString(@"OK", nil)
									 secondButton:nil 
											 from:self  
										 selector:nil];
		return NO;
	}
	
	if (![password isEqual:confirmPassword])
	{
		[self setIsCreatingAccount:NO];
		[mainApplicationWindow runSheetAlertTitle:NSLocalizedString(@"ACCOUNT_CREATION_INCORRECT_PASSWORD_TITLE", nil) 
										  message:NSLocalizedString(@"ACCOUNT_CREATION_INCORRECT_PASSWORD_NOT_MATCH", nil)
									  firstButton:NSLocalizedString(@"OK", nil)
									 secondButton:nil 
											 from:self  
										 selector:nil];
		return NO;
	}

	if ([login length] >= 7)
	{
		[self setIsCreatingAccount:NO];
		[mainApplicationWindow runSheetAlertTitle:NSLocalizedString(@"ACCOUNT_CREATION_INCORRECT_LOGIN_TITLE", nil) 
										  message:NSLocalizedString(@"ACCOUNT_CREATION_INCORRECT_LOGIN_TOO_LONG", nil)
									  firstButton:NSLocalizedString(@"OK", nil)
									 secondButton:nil 
											 from:self
										 selector:nil];
		return NO;
	}
	
	return YES;
}
	

#pragma mark -
#pragma mark Interface actions

- (IBAction) createAccount:(id)sender
{
	
	if ([self isCreatingAccount] == NO)
	{
		NSString		*helperPath;
		NSArray			*args;
		
		stdOut			= [NSPipe pipe];
		sshTask			= [[NSTask alloc] init];
		
		if ([self validateCurrentUserInformations] == NO)
			return;
		
		helperPath		= [[NSBundle mainBundle] pathForResource:[serverPicker getCurrentServerShScriptName] ofType:@"sh"];
		args			= [NSArray arrayWithObjects:login, password, nil];
		
		[sshTask setLaunchPath:helperPath];
		[sshTask setArguments:args];
		[sshTask setStandardOutput:stdOut];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(handleProcessusExecution:)
													 name:NSFileHandleReadCompletionNotification
												   object:[[sshTask standardOutput] fileHandleForReading]];
		
		[[stdOut fileHandleForReading] readInBackgroundAndNotify];
		[self setIsCreatingAccount:YES];
		[sshTask launch];
		
		helperPath = nil;
		args = nil;
	}
	else
	{
		[sshTask terminate];
		[self setIsCreatingAccount:NO];
		sshTask = nil;
	}
}

@end
