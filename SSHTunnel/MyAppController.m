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

#import "MyAppController.h"

@implementation MyAppController
@synthesize hostName;

#pragma mark -
#pragma mark Initialisation methods

- (id) init
{
	self = [super init];
	
	preferencesViewHeight = 470;
	NSDictionary *initialValues = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"YES", 
																	   @"YES", 
																	   @"NO", 
																	   @"NO", 
																	   @"0", 
																	   @"0", 
																	   @"YES", 
																	   @"YES",
																	   [@"~/Library/Application Support/SSHTunnel" stringByExpandingTildeInPath], nil] 
															  forKeys:[NSArray arrayWithObjects:@"checkForNewVersion", 
																	   @"useGraphicalEffects",
																	   @"forceSSHVersion2", 
																	   @"useKeychainIntegration", 
																	   @"selectedTransitionType", 
																	   @"selectedTransitionSubtype", 
																	   @"displayIconInDock", 
																	   @"displayIconInStatusBar",
																	   @"applicationSupportFolder",
																	   nil]];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:initialValues];
	NSFileManager *f = [NSFileManager defaultManager];
	
	if ([f fileExistsAtPath:[[NSUserDefaults standardUserDefaults] stringForKey:@"applicationSupportFolder"]] == NO)
		[self prepareApplicationSupports:f];
	
	[self createObservers];
	
	return self;
}

- (void) awakeFromNib
{	
	[self setHostName:[[NSHost currentHost] name]];
	NSRect currentSize = [[mainApplicationWindow contentView] frame];
	[sessionView setFrame:currentSize];
	[[mainApplicationWindow contentView] addSubview:sessionView];
	
	[preferencesController addObserver:self forKeyPath:@"values.selectedTransitionType" options:NSKeyValueObservingOptionNew context:nil];
	[preferencesController addObserver:self forKeyPath:@"values.selectedTransitionSubtype" options:NSKeyValueObservingOptionNew context:nil];
	[preferencesController addObserver:self forKeyPath:@"values.useGraphicalEffects" options:NSKeyValueObservingOptionNew context:nil];
	
	[self setAnimationsTypes];

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"checkForNewVersion"] == YES)
		[self checkNewVersionOnServerFromUser:NO];
	
    // This should be performed after other ui elements have had time to finish
    // what they are doing.  Therefore, it is called after a small delay
    [self performSelector:@selector(performAutostart) withObject:nil afterDelay:0.1];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"displayIconInStatusBar"] == YES)
		[self prepareStatusBarMenu];
}


#pragma mark -
#pragma mark Helper methods

- (void) prepareApplicationSupports: (NSFileManager *) fileManager  
{
	NSError *error = nil;
	[fileManager createDirectoryAtPath:[[NSUserDefaults standardUserDefaults] stringForKey:@"applicationSupportFolder"] 
           withIntermediateDirectories:YES attributes:nil
                                 error:&error];
	
	[fileManager copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"services" ofType:@"sst"] 
                         toPath:[[[NSUserDefaults standardUserDefaults] stringForKey:@"applicationSupportFolder"]stringByAppendingString:@"/services.sst"] 
                          error:&error];
    
	[fileManager copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"sessions" ofType:@"sst"]
                         toPath:[[[NSUserDefaults standardUserDefaults] stringForKey:@"applicationSupportFolder"] stringByAppendingString:@"/sessions.sst"] 
                          error:&error];
}

- (void) resetAndRestart
{
    NSError *error = nil;
	NSFileManager *f = [NSFileManager defaultManager];
	[f removeItemAtPath:[[NSUserDefaults standardUserDefaults] stringForKey:@"applicationSupportFolder"] 
                  error:&error];
	exit(0);
}

- (void) setAnimationsTypes 
{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"useGraphicalEffects"])
	{
		transition = [[CATransition alloc] init];
		[[mainApplicationWindow contentView] setWantsLayer:YES];
		
		if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"selectedTransitionType"] isEqualTo:@"0"])
			[transition setType:kCATransitionPush];
		else if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"selectedTransitionType"] isEqualTo:@"1"])
			[transition setType:kCATransitionReveal];
		else if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"selectedTransitionType"] isEqualTo:@"2"])
			[transition setType:kCATransitionFade];
		else if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"selectedTransitionType"] isEqualTo:@"3"])
			[transition setType:kCATransitionMoveIn];
		
		if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"selectedTransitionSubtype"] isEqualTo:@"0"])
			[transition setSubtype:kCATransitionFromTop];
		else if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"selectedTransitionSubtype"] isEqualTo:@"1"])
			[transition setSubtype:kCATransitionFromBottom];
		else if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"selectedTransitionSubtype"] isEqualTo:@"2"])
			[transition setSubtype:kCATransitionFromLeft];
		else if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"selectedTransitionSubtype"] isEqualTo:@"3"])
			[transition setSubtype:kCATransitionFromRight];
		
		[transition setDelegate:self];
		currentAnimation = [NSDictionary dictionaryWithObject:transition forKey:@"subviews"];
		[[mainApplicationWindow contentView] setAnimations:currentAnimation];
	}
	else
		[[mainApplicationWindow contentView] setWantsLayer:NO];
	
}

- (void) executeKillAllSSH:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;
{
	// Do not ask me why NSAlertDefaultReturn doesn't work...
	if (returnCode ==  1000)
	{
		NSTask *t = [[NSTask alloc] init];
		[t setLaunchPath:@"/usr/bin/killall"];
		[t setArguments:[NSArray arrayWithObject:@"ssh"]];
		[t launch];
	}
}

- (void) checkNewVersionOnServerFromUser:(BOOL)userRequest
{
	NSLog(@"Checking for new version of the programm on internet");
	
	NSString *currentVersion		= [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
	NSDictionary *serverVersion		= [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:@"http://antoinemercadal.fr/updates/sshtunnel/versions.plist"]];
	NSNumber *currentMajorVersion	= [NSNumber numberWithInt:[[[currentVersion  componentsSeparatedByString:@"."] objectAtIndex:0] intValue]];
	NSNumber *currentMinorVersion	= [NSNumber numberWithInt:[[[currentVersion  componentsSeparatedByString:@"."] objectAtIndex:1] intValue]];
	NSNumber *remoteMajorVersion	= [NSNumber numberWithInt:[[serverVersion objectForKey:@"Major"] intValue]];
	NSNumber *remoteMinorVersion	= [NSNumber numberWithInt:[[serverVersion objectForKey:@"Minor"] intValue]];
	
	if (([currentMajorVersion intValue] < [remoteMajorVersion intValue]) 
		|| ( ([currentMajorVersion intValue] == [remoteMajorVersion intValue]) 
			&& ([currentMinorVersion intValue] < [remoteMinorVersion intValue])))
	{
		int resp = NSRunAlertPanel([NSString stringWithFormat:@"New version %@.%@ is out!", 
									remoteMajorVersion, remoteMinorVersion],
								   [serverVersion valueForKey:@"Changes"], 
								   @"Download Version", 
								   @"Ignore", 
								   nil);
		
		if (resp == NSAlertDefaultReturn)
			[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[serverVersion objectForKey:@"DownloadURL"]]];
	}
	else if (userRequest)
		NSRunAlertPanel(@"Version Checker", @"You copy of SSHTunnel is actually up-to-date",  @"OK", nil, nil);
}

- (BOOL) stopAllOtherRunningGlobalProxy
{
	for (AMSession *o in [sessionController sessions])
	{
		if (([o connected] || [o connectionInProgress] ) && ([o sessionTunnelType] == AMSessionGlobalProxy))
		{
			int r = NSRunAlertPanel(@"Global Proxy", @"The global proxy session is in execution. Only one global proxy can ran. Would you like to stop it ?", @"OK", @"Cancel", nil);
		
			if (r == NSAlertAlternateReturn)
				return NO;
			else
				[o closeTunnel];
		}
	}
	return YES;
}

- (void) performAutostart
{
	for (AMSession *s in [sessionController sessions])
		for (AMSession *o in [s childrens])
		{
			if ([o autostart] == YES)
				[o openTunnel];
		}	
}

- (void) prepareStatusBarMenu
{
	/*
	for (AMSession *ss  in  [sessionController sessions])
	{
		for (AMSession *s in [ss childrens])
		{
			if ([s sessionTunnelType] == AMSessionOutgoingTunnel)
			{
				if ([s sessionName] != nil)
				{
					NSMenuItem *i = [[NSMenuItem alloc] initWithTitle:[s sessionName] action:nil keyEquivalent:@""];
					[i setState:NSOffState];
					[i setOffStateImage:[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"statusRed" ofType:@"tif"]]];
					[i setOnStateImage:[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"statusGreen" ofType:@"tif"]]];		
					[i setTitle:[s sessionName]];
					[i setAction:@selector(displaySessionView:)];
					[taskBarMenu addItem:i];
				}
			}
		}
	}
	 */
	NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
	statusBarItem = [[statusBar statusItemWithLength: NSVariableStatusItemLength] retain];
	
	[statusBarItem setImage:[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"taskbarIcon" ofType:@"tiff"]]];
	[statusBarItem setEnabled:YES];
	[statusBarItem setMenu:taskBarMenu];
}


#pragma mark -
#pragma mark Observer and Delegates

- (void) createObservers 
{
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(performInfoMessage:) 
												 name:AMNewGeneralMessage
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(performInfoMessage:) 
												 name:AMNewErrorMessage
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(resetAndRestart) 
												 name:AMErrorLoadingSavedState 
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(applyCurrentServerToAllSessions:) 
												 name:AMErrorLoadingSavedState 
											   object:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	NSLog(@"Animations preferences changes detected");
	[self setAnimationsTypes];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
//	[[mainApplicationWindow contentView] setWantsLayer:NO];
//	NSLog(@"Removing Core Layer.");
}

- (void)animationDidStart:(CAAnimation *)theAnimation
{
//	[[mainApplicationWindow contentView] setWantsLayer:YES];
//	NSLog(@"animation did start.");
}


#pragma mark -
#pragma mark Interface builder actions

- (IBAction) resetApplicationSupportFolder:(id)sender
{
	int rep = NSRunAlertPanel(@"Reset factory presets", @"Are you really sure you want to reset the factory presets ? Note you have to relaunch application.", @"Yes", @"No", nil);
	
	if (rep == NSAlertDefaultReturn)
	{
		[self resetAndRestart];
	}
}

- (IBAction) openSession:(id)sender
{
	AMSession	*currentSession = [sessionController getSelectedSession];
	if (([currentSession connected] == NO) && ([currentSession connectionInProgress] == NO))
	{
		if ([currentSession sessionTunnelType] == AMSessionGlobalProxy)
		{	
			if ([self stopAllOtherRunningGlobalProxy] == YES)
				[currentSession openTunnel];
		}
		else
			[currentSession openTunnel];
	}
}

- (IBAction) closeSession:(id)sender
{
	AMSession	*currentSession = [sessionController getSelectedSession];
	
	[currentSession closeTunnel];
}

- (IBAction) toggleTunnel:(id)sender 
{
	AMSession	*currentSession = [sessionController getSelectedSession];
	
	if ([currentSession connected] == NO)
		[currentSession closeTunnel];
	else
	{
		[currentSession openTunnel];
	}
}

- (IBAction) killAllSSH:(id)sender
{
	[mainApplicationWindow runSheetAlertTitle:NSLocalizedString(@"KILLALLSSH_TITLE", nil) 
									  message:NSLocalizedString(@"KILLALLSSH_MESSAGE", nil)
								  firstButton:NSLocalizedString(@"OK", nil)
								 secondButton:NSLocalizedString(@"CANCEL", nil)
										 from:self
									 selector:(@"executeKillAllSSH:returnCode:contextInfo:")];
}

- (IBAction) openAllSession:(id)sender
{
	for (AMSession *s in [sessionController sessions])
		for (AMSession *o in [s childrens])
		{
			if ([o connected] == NO)
				[o openTunnel];
		}
}

- (IBAction) closeAllSession:(id)sender
{
	for (AMSession *s in [sessionController sessions])
		for (AMSession *o in [s childrens])
		{
			NSLog(@"Session %@ closed.", [o sessionName]);
			[o closeTunnel];
		}
}

- (IBAction) openSessionInSafari:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[@"http://" stringByAppendingString:[sender title]]]];
}

- (IBAction) checkForNewVersion:(id)sender
{
	[self checkNewVersionOnServerFromUser:YES];
}

- (IBAction) openMainWindow:(id)sender
{
	[mainApplicationWindow makeKeyAndOrderFront:nil];
}

- (IBAction) closeMainWindow:(id)sender
{
	[mainApplicationWindow orderOut:nil];
}

- (IBAction) applyCurrentServerToAllSessions:(id)sender
{
	int rep = NSRunAlertPanel(@"Apply current server to all sessions", @"You are going to set the server as the selected one to every sessions. Are you sure ?", @"Yes", @"no", nil);
	
	if (rep == NSAlertDefaultReturn)
	{
		NSLog(@"Applying current server to all sessions");
		for (AMSession *s in [sessionController sessions])
			for (AMSession *o in [s childrens])
			{
				[o setCurrentServer:[serverController getSelectedServer]];
			}
	}
}



#pragma mark -
#pragma mark View management

- (IBAction) displaySessionView:(id)sender
{
	if (![[[mainApplicationWindow contentView] subviews] containsObject:sessionView])
	{
		if ([[[mainApplicationWindow contentView] subviews] containsObject:preferencesView])
			[mainApplicationWindow setFrame:oldWindowFrame display:YES animate:YES];
		
		NSRect currentSize = [[mainApplicationWindow contentView] frame];
		[sessionView setFrame:currentSize];
		NSView *currentView = [[[mainApplicationWindow contentView] subviews] objectAtIndex:0];
		[[[mainApplicationWindow contentView] animator] replaceSubview:currentView with:sessionView];
	}
}

- (IBAction) displayServerView:(id)sender
{
	if (![[[mainApplicationWindow contentView] subviews] containsObject:serverView])
	{
		if ([[[mainApplicationWindow contentView] subviews] containsObject:preferencesView])
			[mainApplicationWindow setFrame:oldWindowFrame display:YES animate:YES];
		
		NSRect currentSize = [[mainApplicationWindow contentView] frame];
		[serverView setFrame:currentSize];
		NSView *currentView = [[[mainApplicationWindow contentView] subviews] objectAtIndex:0];
		[[[mainApplicationWindow contentView] animator] replaceSubview:currentView with:serverView];
	}
}

- (IBAction) displayAboutView:(id)sender
{
	if (![[[mainApplicationWindow contentView] subviews] containsObject:aboutView])
	{
		if ([[[mainApplicationWindow contentView] subviews] containsObject:preferencesView])
			[mainApplicationWindow setFrame:oldWindowFrame display:YES animate:YES];
		
		NSRect currentSize = [[mainApplicationWindow contentView] frame];
		[aboutView setFrame:currentSize];
		NSView *currentView = [[[mainApplicationWindow contentView] subviews] objectAtIndex:0];
		[[[mainApplicationWindow contentView] animator] replaceSubview:currentView with:aboutView];
	}
}

- (IBAction) displayRegisterView:(id)sender
{
	if (![[[mainApplicationWindow contentView] subviews] containsObject:registerView])
	{
		if ([[[mainApplicationWindow contentView] subviews] containsObject:preferencesView])
			[mainApplicationWindow setFrame:oldWindowFrame display:YES animate:YES];
		
		NSRect currentSize = [[mainApplicationWindow contentView] frame];
		[registerView setFrame:currentSize];
		NSView *currentView = [[[mainApplicationWindow contentView] subviews] objectAtIndex:0];
		[[[mainApplicationWindow contentView] animator] replaceSubview:currentView with:registerView];
	}
}

- (IBAction) displayServiceView:(id)sender
{
	if (![[[mainApplicationWindow contentView] subviews] containsObject:serviceView])
	{
		if ([[[mainApplicationWindow contentView] subviews] containsObject:preferencesView])
			[mainApplicationWindow setFrame:oldWindowFrame display:YES animate:YES];
			
		NSRect currentSize = [[mainApplicationWindow contentView] frame];
		[serviceView setFrame:currentSize];
		NSView *currentView = [[[mainApplicationWindow contentView] subviews] objectAtIndex:0];
		[[[mainApplicationWindow contentView] animator] replaceSubview:currentView with:serviceView];
	}
}

- (IBAction) displayPreferenceView:(id)sender
{
	if (![[[mainApplicationWindow contentView] subviews] containsObject:preferencesView])
	{
		oldWindowFrame = [mainApplicationWindow frame];
		
		if (oldWindowFrame.size.height < preferencesViewHeight)
		{
			NSRect wframe = oldWindowFrame;
			wframe.size.height = preferencesViewHeight;
			[mainApplicationWindow setFrame:wframe display:NO animate:YES];
		}
		
		NSRect currentSize = [[mainApplicationWindow contentView] frame];
		[preferencesView setFrame:currentSize];
		NSView *currentView = [[[mainApplicationWindow contentView] subviews] objectAtIndex:0];
		[[[mainApplicationWindow contentView] animator] replaceSubview:currentView with:preferencesView];
	}
}


#pragma mark -
#pragma mark Messaging display methods

- (void) performInfoMessage:(NSNotification*)notif
{
	if ([[notif name] isEqualToString:AMNewErrorMessage])
		[errorMessage setTextColor:[NSColor redColor]];
	else if  ([[notif name] isEqualToString:AMNewGeneralMessage])
		[errorMessage setTextColor:[NSColor whiteColor]];
		 
	[self errorPanelDisplaywithMessage: (NSString*)[notif object]];
}

- (void) errorPanelDisplaywithMessage:(NSString *)theMessage
{
	if (timer != nil)
		[timer invalidate];
	
	NSRect rect = [errorPanel frame];
	rect.origin.y = 0;
	[errorMessage setStringValue:theMessage];
	[[errorPanel animator] setFrame:rect];
	
	timer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(errorPanelClose:) userInfo:NULL repeats:NO];
}

- (void) errorPanelClose:(NSTimer *)theTimer
{
	NSRect rect = [errorPanel frame];
	rect.origin.y = -60;
	[[errorPanel animator] setFrame:rect];
}


#pragma mark -
#pragma mark Application status managers

- (void) applicationWillTerminate: (NSNotification *) notification
{
	[self closeAllSession:nil];

	[serverController performSaveProcess:nil];
	[serviceController performSaveProcess:nil];
	[sessionController performSaveProcess:nil];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
	[self openMainWindow:nil];    
	return YES;
}

@end
