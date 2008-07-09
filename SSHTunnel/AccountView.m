#import "AccountView.h"

@implementation AccountView

@synthesize delegate;

- (void) awakeFromNib
{
	[progressor setHidden:YES];
}

- (IBAction) createAccount:(id)sender
{
	if ([[createButton title] isEqual:@"Register on Abornet"])
	{
		stdOut			= [NSPipe pipe];
		sshTask			= [[NSTask alloc] init];
		outputContent	= @"";
		NSString		*helperPath		= [[NSBundle mainBundle] pathForResource:@"createAbornetAccount" ofType:@"sh"];
		NSArray			*args			= [NSArray arrayWithObjects:[login stringValue], [password stringValue], nil];

		if ([[password stringValue] length] >= 6)
		{
			if (![[password stringValue] isEqual:[confirmPassword stringValue]])
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
		
		if ([[login stringValue] length] >= 7)
		{
			NSRunAlertPanel(@"Incorrect username", @"Your login must be at maximum of 6 characters lenght", @"Ok", nil, nil);
			return;
		}
		
		[createButton setTitle:@"Abort Registration"];
		[sshTask setLaunchPath:helperPath];
		[sshTask setArguments:args];
		[sshTask setStandardOutput:stdOut];
		
		
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(checkShStatus:)
													 name:NSFileHandleReadCompletionNotification
												   object:[[sshTask standardOutput] fileHandleForReading]];

		[[stdOut fileHandleForReading] readInBackgroundAndNotify];
		[progressor startAnimation:nil];
		[progressor setHidden:NO];
		[sshTask launch];
	}
	else
	{
		[sshTask terminate];
		[createButton setTitle:@"Register on Abornet"];
		[progressor stopAnimation:nil];
		[progressor setHidden:YES];
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
			[progressor stopAnimation:nil];
			[progressor setHidden:YES];
			NSRunAlertPanel(@"Error", @"Login already exists", @"ok", nil, nil);
		}
		else if ([checkSuccess evaluateWithObject:outputContent] == YES)
		{
			NSLog(@"Ok I'm here");
			[[NSNotificationCenter defaultCenter]  removeObserver:self 
															 name:NSFileHandleReadCompletionNotification 
														   object:[stdOut fileHandleForReading]];
			[sshTask terminate];
			[progressor stopAnimation:nil];
			[progressor setHidden:YES];
			int ret = NSRunAlertPanel(@"Account Created", @"Operation sucess. Would you like to use this account with SSTunnel?", 
							@"Yes, please configure for me", @"No, I will do it by myself", nil);
			
			if (ret == NSAlertDefaultReturn)
			{
				AMAuth *serv = [(NSArray*)[delegate valueForKey:@"servers"] objectAtIndex:0];
				if (serv != nil)
				{
					[serv setHost:@"m-net.arbornet.org"];
					[serv setPort:@"22"];
					[serv setUsername:[login stringValue]];
					[serv setPassword:[password stringValue]];
					[delegate performSelector:@selector(saveState)];
					[delegate performSelector:@selector(displayServerView:)];
				}
			}
		}
		else
			[[stdOut fileHandleForReading] readInBackgroundAndNotify];
		
		
		data = nil;
		checkExistingLogin = nil;
		checkSuccess = nil;
	}
}

@end
