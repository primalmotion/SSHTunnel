#import "MyAppController.h"

@implementation MyAppController

@synthesize	sessions;
@synthesize servers;
@synthesize currentSession;

- (id) init
{
	[super init];
	
	NSFileManager *f = [NSFileManager defaultManager];
	
	NSString *saveFolder =  @"~/Library/Application Support/SSHTunnel/";
	sessionSavePath =  @"~/Library/Application Support/SSHTunnel/sessions.sst";
	serverSavePath  =  @"~/Library/Application Support/SSHTunnel/servers.sst";
	
	if ([f fileExistsAtPath:[saveFolder stringByExpandingTildeInPath]] == NO)
		[f createDirectoryAtPath:[saveFolder stringByExpandingTildeInPath] attributes:nil];
		
	if ([f fileExistsAtPath:[sessionSavePath stringByExpandingTildeInPath]] == YES)
		[self setSessions:[NSKeyedUnarchiver unarchiveObjectWithFile:[sessionSavePath stringByExpandingTildeInPath]]];
	else
		sessions = [[NSMutableArray alloc] init];
	
	if ([f fileExistsAtPath:[serverSavePath stringByExpandingTildeInPath]] == YES)
		[self setServers:[NSKeyedUnarchiver unarchiveObjectWithFile:[serverSavePath stringByExpandingTildeInPath]]];
	else
	{
		servers = [[NSMutableArray alloc] init];
		[servers addObject:[[AMAuth alloc] init]];
	}
	
	int i;
	for(i = 0; i < [sessions count]; i++)
		[[sessions objectAtIndex:i] setDelegate:self];

	return self;
}
 
- (void) awakeFromNib
{
	[tv setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
	[tv registerForDraggedTypes:[NSArray arrayWithObject:@"MyData"]];
	[wheel setUsesThreadedAnimation:YES];
	
	if ([sessions count] > 0)
	{
		currentSession = [sessions objectAtIndex:0];
		[localPort setStringValue:[currentSession localPort]];
		[remoteHost setStringValue:[currentSession remoteHost]];
		[remotePort setStringValue:[currentSession remotePort]];
	}
	
	if ([[servers objectAtIndex:0] host] == nil)
		[[mainWindow contentView] addSubview:serverView];
	else
		[[mainWindow contentView] addSubview:mainView];
}

/**
 * Here are the IBAction of the interface
 **/
- (IBAction)toggleTunnel:(id)sender 
{
	if ([currentSession isStillRunning] == 1)
	{
		NSLog(@"The ssh tunnel has been deleted");
		[self stopWheel];
		[currentSession closeTunnel];
		[tv reloadData];
		[self enableInterface];
		[self errorPanelDisplaywithMessage:[@"The ssh tunnel has been close for session " stringByAppendingString:[currentSession sessionName]]];
		[self stopWheel];
		
	}
	else
	{	
		[self disableInterface];
		AMAuth *auth = [servers objectAtIndex:0];

		[currentSession openTunnelWithUsername:[auth username] Host:[auth host] Port:[auth port] Password:[auth password]];
		[tv reloadData];
		[self errorPanelDisplaywithMessage:[[@"Starting session " stringByAppendingString:[currentSession sessionName]]
											stringByAppendingString:@"..."]];
		[self startWheel];

	}
}

- (IBAction)addSession:(id)sender
{
	SavedItemsObject *o = [[SavedItemsObject alloc] init];
	

	[o setLocalPort:@""];
	[o setRemoteHost:@""];
	[o setRemotePort:@""];

	[o setSessionName:@"New Session"];
	[o setDelegate:self];
	[sessions addObject:o];
	
	[self saveState];
	[tv reloadData];
}

- (IBAction)deleteSession:(id)sender
{	
	[[sessions objectAtIndex:[tv selectedRow]] closeTunnel];
	
	[sessions removeObjectAtIndex:[tv selectedRow]];
	[tv reloadData];
	[tv deselectAll:nil];
	[tv selectRow:([tv selectedRow] - 1) byExtendingSelection:NO];

	[self saveState];

}

- (IBAction) openAboutWindow:(id)sender
{
	if ([aboutWindow isVisible] == YES)
		[aboutWindow orderOut:nil];
	else
		[aboutWindow makeKeyAndOrderFront:nil];
}

- (IBAction) openMainWindow:(id)sender
{
	[mainWindow makeKeyAndOrderFront:nil];
}

- (IBAction) closeMainWindow:(id)sender
{
	[mainWindow orderOut:nil];
}


/**
 * this part is to manage the different
 * interace object.
 **/
- (void) startWheel
{
	//NSRect newPos = [bToggleTunnel frame];
	//newPos.size.width -= 30;
	//[[bToggleTunnel animator] setFrame:newPos];

	//newPos = [wheel frame];
	//newPos.origin.x -= 40;
	//[[wheel animator] setFrame:newPos];
	
	//[bToggleTunnel setEnabled:NO];
	[wheel setHidden:NO];
	[wheel startAnimation:nil];
}

- (void) stopWheel
{
	//NSRect newPos = [bToggleTunnel frame];
	//newPos.size.width = 178;
	//[[bToggleTunnel animator] setFrame:newPos];
	
	//newPos = [wheel frame];
	//newPos.origin.x = 590;
	//[[wheel animator] setFrame:newPos];
	[wheel setHidden:YES];
	[wheel stopAnimation:nil];
	//[bToggleTunnel setEnabled:YES];
}

- (void) incrementWheelValue
{
	[[wheel animator] setDoubleValue:[wheel doubleValue] + 8.00f];
	
}

- (void) updateList
{
	NSLog(@"kewkew");
	[tv reloadData];
}

-(void) enableInterface
{
	[remotePort setEnabled:YES];
	[remoteHost setEnabled:YES];
	[localPort setEnabled:YES];
	[bToggleTunnel setTitle:@"Create Tunnel"];
}

-(void) disableInterface
{
	[remotePort setEnabled:NO];
	[remoteHost setEnabled:NO];
	[localPort setEnabled:NO];
	[bToggleTunnel setTitle:@"Destroy Tunnel"];
}



/**
 * This part is for the delegation of the NSTableView to
 * enable instant save when modified.
 **/

- (void) errorPanelDisplaywithMessage:(NSString *)theMessage
{
	NSRect rect = [errorPanel frame];
	rect.origin.y = 0;
	[errorMessage setStringValue:theMessage];
	[[errorPanel animator] setFrame:rect];
	
	[NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(errorPanelClose:) userInfo:NULL repeats:NO];
}

- (void) errorPanelClose:(NSTimer *)theTimer
{
	NSRect rect = [errorPanel frame];
	rect.origin.y = -60;
	[[errorPanel animator] setFrame:rect];
}


/**
 * This part is for the delegation of the NSTableView to
 * enable instant save when modified.
 **/
- (int)numberOfRowsInTableView:(NSTableView *)tv 
{ 
    return [sessions count];
}

- (id)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row 
{
	
	if ([[tableColumn identifier] isEqual:@"session"] == YES)
	{
		NSString *v = [[sessions objectAtIndex:row]sessionName];
		return v; 
	}
	else if ([[tableColumn identifier] isEqual:@"activity"] == YES)
	{
		NSImage *img;
		if ([[sessions objectAtIndex:row] isStillRunning] == 1)
			img = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"statusGreen" 
																						  ofType:@"tif"]];
		else if ([[sessions objectAtIndex:row] isStillRunning] == 0)
			img = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"statusRed" 
																						  ofType:@"tif"]];
		else if ([[sessions objectAtIndex:row] isStillRunning] == 2)
			img = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"statusOrange" 
																						ofType:@"tif"]];
		[img retain];
		return img;
	}
	//else if ([[tableColumn identifier] isEqual:@"keyed"] == YES)
	//{
		//NSImage *img;
		/*if ([[sessions objectAtIndex:row] hasPassphrase] == YES)
		{
			img = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"keyed"
				   ofType:@"tiff"]];
			[img retain];
			return img;
		}*/
	//}
	
	return nil;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification 
{ 
	NSLog(@"current row selected %d", [tv selectedRow]);

	[localPort setStringValue:[[sessions objectAtIndex:[tv selectedRow]] localPort]];
	[remoteHost setStringValue:[[sessions objectAtIndex:[tv selectedRow]] remoteHost]];
	[remotePort setStringValue:[[sessions objectAtIndex:[tv selectedRow]] remotePort]];
	currentSession = [sessions objectAtIndex:[tv selectedRow]];
	
	if ([currentSession isStillRunning] == 2)
	{
		[self formatQuickLink:NO];
		[self startWheel];
	}
	else
		[self stopWheel];
	if ([currentSession isStillRunning] == 1)
	{
		[self formatQuickLink:YES];
		[self disableInterface];
	}
	else
	{
		[self formatQuickLink:NO];
		[self enableInterface];
	}
}

- (void) formatQuickLink:(BOOL)enabled 
{
	if ((enabled) && ([[sessions objectAtIndex:[tv selectedRow]] isStillRunning] == 1))
	{
		NSString *link = [@"You can access your destination through: http://127.0.0.1:" stringByAppendingString:[currentSession localPort]];
		[quickLink setTitle:link];
	}
	else
		[quickLink setTitle:@""];
}

- (IBAction) openUrl:(id)sender
{
	if ([quickLink title] != @"")
		[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:[[quickLink title] 
																	  stringByReplacingOccurrencesOfString:@"You can access your destination through: " withString:@""]]];
}

- (IBAction) killAllSSH:(id)sender
{
	int ret = NSRunAlertPanel(@"Warning", @"You are going to kill all active ssh session, even some that are not managed by SSHTunnel. Are you sure?", 
							  @"Yes", @"Abort", nil);
	if (ret ==  NSAlertDefaultReturn)
	{
		NSTask *t = [[NSTask alloc] init];
		[t setLaunchPath:@"/usr/bin/killall"];
		[t setArguments:[NSArray arrayWithObject:@"ssh"]];
		[t launch];
	}
}

-(void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	[[sessions objectAtIndex:rowIndex] setSessionName:anObject];
	[self saveState];
}


- (void) saveState
{
	[NSKeyedArchiver archiveRootObject:sessions toFile:[sessionSavePath stringByExpandingTildeInPath]];
	[NSKeyedArchiver archiveRootObject:servers toFile:[serverSavePath stringByExpandingTildeInPath]];
}

-(BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
	
    [pboard declareTypes:[NSArray arrayWithObject:@"MyData"] owner:self];
    [pboard setData:data forType:@"MyData"];
	
	data = nil;
	return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op
{
    if (op == NSTableViewDropOn)
		return NSDragOperationNone;
	else
		return NSDragOperationMove;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info
			  row:(int)row dropOperation:(NSTableViewDropOperation)operation
{
	
    NSPasteboard *pboard	= [info draggingPasteboard];
    NSData *rowData			= [pboard dataForType:@"MyData"];
    NSIndexSet *rowIndexes	= [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
    int dragRow				= [rowIndexes firstIndex];
	SavedItemsObject *o		= [[sessions objectAtIndex:dragRow] retain];
	
	[sessions removeObject:o];
	if (row == [sessions count])
	{
		[sessions addObject:o];
	}
	else
	{
		if (row - 1 < 0)
			row++;
		[sessions insertObject:o atIndex:(row - 1)];
		if (o == currentSession)
			[tv selectRow:(row - 1) byExtendingSelection:NO];
	}
	[tv reloadData];
	
	[o release];
	[self saveState];
	
	rowData = nil;
	rowIndexes = nil;
	pboard = nil;
	return YES;
	
}
 

/**
 * This part is for the delegation of the differents NSTextField, to
 * enable instant save when modified.
**/
- (void)controlTextDidChange:(NSNotification *)aNotification
{
	NSTextField *o  =[aNotification object];
	
		 
	if ([[aNotification object] isEqual:localPort])
		[currentSession setLocalPort:[o stringValue]];
		 
	else if ([[aNotification object] isEqual:remoteHost])
		[currentSession setRemoteHost:[o stringValue]];
	
	else if ([[aNotification object] isEqual:remotePort])
		 [currentSession setRemotePort:[o stringValue]];
	 
	else if ([[aNotification object] isEqual:tunnelHost])
		[[servers objectAtIndex:0] setHost:[o stringValue]];

	else if ([[aNotification object] isEqual:tunnelPort])
	{
		NSLog(@"toto => %@", [o stringValue]);
		[[servers objectAtIndex:0] setPort:[o stringValue]];
	}
	else if ([[aNotification object] isEqual:userName])
		[[servers objectAtIndex:0] setUsername:[o stringValue]];

	else if ([[aNotification object] isEqual:password])
		[[servers objectAtIndex:0] setPassword:[o stringValue]];
	
	
	[self saveState];

}


/**
 * This part is for the delegation of the NSApplication to
 * allow closing all ssh session before terminating
 **/
- (void) applicationWillTerminate: (NSNotification *) notification
{
	for (int i = 0; i < [sessions count]; i++)
		[[sessions objectAtIndex:i] closeTunnel];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
	[self openMainWindow:nil];    
	return YES;
}

- (void)animateWindow:(NSWindow*)win effect:(CGSTransitionType)fx direction:(CGSTransitionOption)dir
			 duration:(float)dur
{
	int handle;
	CGSTransitionSpec spec;
	

	handle = -1;
	
	spec.unknown1=0;
	spec.type=fx;
	spec.option=dir;
	spec.option |= (1<<7);
	spec.backColour=NULL;
	spec.wid=[win windowNumber];
	
	
	CGSConnection cgs= _CGSDefaultConnection();
	CGSNewTransition(cgs, &spec, &handle);
	
	[win display];
	
	if (fx == CGSNone)
		dur = 0.f; // if no transition effect, no need to have a duration, (it would be strange to wait for nothin') -> je n'te l'fai pas dire mec
	
	CGSInvokeTransition(cgs, handle, dur);
	usleep((useconds_t)(dur * 1000000));
	CGSReleaseTransition(cgs, handle);
	handle=0;
}

- (IBAction) switchWin:(id)sender
{
	
	
	if ([[[mainWindow contentView] subviews] containsObject:mainView])
	{
		[switcher setLabel:@"Manage Sessions"];
		[[mainWindow contentView] replaceSubview:mainView with:serverView];
		[self animateWindow:mainWindow effect:CGSCube direction:CGSLeft duration:0.2];
		[tunnelHost setStringValue:(NSString *)[[servers objectAtIndex:0] host]];
		[tunnelPort setStringValue:(NSString *)[[servers objectAtIndex:0] port]];
		[userName setStringValue:[[servers objectAtIndex:0] username]];
		[password setStringValue:[[servers objectAtIndex:0] password]];
	}
	else
	{
		[switcher setLabel:@"Manage Servers"];
		[[mainWindow contentView] replaceSubview:serverView with:mainView];
		[[mainWindow contentView] replaceSubview:aboutView with:mainView];
		[self animateWindow:mainWindow effect:CGSCube direction:CGSRight duration:0.2];
	}
}

- (IBAction) displayAbout:(id)sender
{
	if ([[[mainWindow contentView] subviews] containsObject:aboutView])
	{
		[[mainWindow contentView] replaceSubview:aboutView with:mainView];
		[self animateWindow:mainWindow effect:CGSCube direction:CGSUp duration:0.2];
	}
	else
	{
		[switcher setLabel:@"Manage Servers"];
		
		[[mainWindow contentView] replaceSubview:serverView with:aboutView];
		[[mainWindow contentView] replaceSubview:mainView with:aboutView];
		[self animateWindow:mainWindow effect:CGSCube direction:CGSDown duration:0.2];
	}
}

- (IBAction) openAllSession:(id)sender
{
	AMAuth *auth = [servers objectAtIndex:0];
	for (SavedItemsObject *o in sessions)
	{
		if ([o isStillRunning] == 0)
			[o openTunnelWithUsername:[auth username] Host:[auth host] Password:[auth password]];
	}
	[tv reloadData];
}

- (IBAction) closeAllSession:(id)sender
{
	for (SavedItemsObject *o in sessions)
	{
		if ([o isStillRunning] == 1)
			[o closeTunnel];
	}
	[tv reloadData];
}
@end
