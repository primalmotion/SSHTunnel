#import "MyAppController.h"

@implementation MyAppController

@synthesize	savedItems;
@synthesize currentSession;


- (id) init
{
	[super init];
	
	NSFileManager *f = [NSFileManager defaultManager];
	
	NSString *saveFolder =  @"~/Library/Application Support/SSHTunnel/";
	savePath =  @"~/Library/Application Support/SSHTunnel/sav.sst";
	
	if ([f fileExistsAtPath:[saveFolder stringByExpandingTildeInPath]] == NO)
		[f createDirectoryAtPath:[saveFolder stringByExpandingTildeInPath] attributes:nil];
		
	if ([f fileExistsAtPath:[savePath stringByExpandingTildeInPath]] == YES)
		[self setSavedItems:[NSKeyedUnarchiver unarchiveObjectWithFile:[savePath stringByExpandingTildeInPath]]];
	else
		savedItems = [[NSMutableArray alloc] init];
	
	int i;
	for(i = 0; i < [savedItems count]; i++)
	{
		[[savedItems objectAtIndex:i] setDelegate:self];
	}
	

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenerForSSHTunnelDown) 
												 name:@"NSTaskDidTerminateNotification" object:nil];
	
	return self;
}

- (void) awakeFromNib
{
	[tv setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
	[tv registerForDraggedTypes:[NSArray arrayWithObject:@"MyData"]];
	[wheel setUsesThreadedAnimation:YES];
	
	
	if ([savedItems count] > 0)
	{
		[tunnelHost setStringValue:[[savedItems objectAtIndex:[tv selectedRow]] tunnelHost]];
		[userName setStringValue:[[savedItems objectAtIndex:[tv selectedRow]] userName]];
		[localPort setStringValue:[[savedItems objectAtIndex:[tv selectedRow]] localPort]];
		[remoteHost setStringValue:[[savedItems objectAtIndex:[tv selectedRow]] remoteHost]];
		[remotePort setStringValue:[[savedItems objectAtIndex:[tv selectedRow]] remotePort]];
		[password setStringValue:[[savedItems objectAtIndex:[tv selectedRow]] password]];
		currentSession = [savedItems objectAtIndex:[tv selectedRow]];
	}
}


/**
 * Here are the IBAction of the interface
 **/
- (IBAction)toggleTunnel:(id)sender 
{
	if ([currentSession isStillRunning] == 1)
	{
		[self stopWheel];
		[currentSession closeTunnel];
		[tv reloadData];
		[self enableInterface];
		[self errorPanelDisplaywithMessage:[@"The ssh tunnel has been close for session " stringByAppendingString:[currentSession sessionName]]];
		NSLog(@"The ssh tunnel has been deleted");
	}
	else
	{	
		[self disableInterface];		
		[currentSession openTunnel];
		[tv reloadData];
		[self errorPanelDisplaywithMessage:[[@"Starting session " stringByAppendingString:[currentSession sessionName]]
											stringByAppendingString:@"..."]];

	}
}

- (IBAction)addSession:(id)sender
{
	SavedItemsObject *o = [[SavedItemsObject alloc] init];
	
	[o setUserName:@""];
	[o setTunnelHost:@""];
	[o setLocalPort:@""];
	[o setRemoteHost:@""];
	[o setRemotePort:@""];
	[o setPassword:@""];
	[o setSessionName:@"New Session"];
	[o setDelegate:self];
	[savedItems addObject:o];
	
	[NSKeyedArchiver archiveRootObject:savedItems toFile:[savePath stringByExpandingTildeInPath]];
	[tv reloadData];
}

- (IBAction)deleteSession:(id)sender
{	
	[[savedItems objectAtIndex:[tv selectedRow]] closeTunnel];
	
	[savedItems removeObjectAtIndex:[tv selectedRow]];
	[tv reloadData];
	[tv deselectAll:nil];
	[tv selectRow:([tv selectedRow] - 1) byExtendingSelection:NO];

	[NSKeyedArchiver archiveRootObject:savedItems toFile:[savePath stringByExpandingTildeInPath]];
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
	NSRect newPos = [bToggleTunnel frame];
	newPos.size.width -= 30;
	[[bToggleTunnel animator] setFrame:newPos];
	
	[self setWheelValue:[NSNumber numberWithDouble:0.0f]];
	newPos = [wheel frame];
	newPos.origin.x -= 40;
	[[wheel animator] setFrame:newPos];
	
	[bToggleTunnel setEnabled:NO];
}

- (void) stopWheel
{
	NSRect newPos = [bToggleTunnel frame];
	newPos.size.width = 178;
	[[bToggleTunnel animator] setFrame:newPos];
	
	newPos = [wheel frame];
	newPos.origin.x = 590;
	[[wheel animator] setFrame:newPos];
	[wheel stopAnimation:nil];
	[self setWheelValue:[NSNumber numberWithDouble:0.0f]];
	[bToggleTunnel setEnabled:YES];
}

- (void) setWheelValue:(NSNumber *)value
{
	[[wheel animator] setDoubleValue:[value doubleValue]];
}

- (void) incrementWheelValue
{
	[[wheel animator] setDoubleValue:[wheel doubleValue] + 8.00f];
	
}

- (void) updateList
{
	[tv reloadData];
}

-(void) enableInterface
{
	[tunnelHost setEnabled:YES];
	[remotePort setEnabled:YES];
	[userName setEnabled:YES];
	[remoteHost setEnabled:YES];
	[localPort setEnabled:YES];
	[password setEnabled:YES];
	[bToggleTunnel setTitle:@"Create Tunnel"];
}

-(void) disableInterface
{
	[tunnelHost setEnabled:NO];
	[remotePort setEnabled:NO];
	[remoteHost setEnabled:NO];
	[userName setEnabled:NO];
	[localPort setEnabled:NO];
	[password setEnabled:NO];
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

- (void) listernerForSSHTunnelDown
{
	int i;
	for(i = 0; i < [savedItems count]; i++)
	{
		SavedItemsObject *o = [savedItems objectAtIndex:i];
		if ( [[o sshTask] isRunning] == NO)
		{
			[o setIsStillRunning:0];
			[tv reloadData];
			if ([tv selectedRow] == i)
				[self enableInterface];
		}
	}
}



/**
 * This part is for the delegation of the NSTableView to
 * enable instant save when modified.
 **/
- (int)numberOfRowsInTableView:(NSTableView *)tv 
{ 
    return [savedItems count];
}

- (id)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row 
{
	if ([[tableColumn identifier] isEqual:@"session"] == YES)
	{
		NSString *v = [[savedItems objectAtIndex:row]sessionName];
		return v; 
	}
	else if ([[tableColumn identifier] isEqual:@"activity"] == YES)
	{
		NSImage *img;
		if ([[savedItems objectAtIndex:row] isStillRunning] == 1)
			img = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"statusGreen" 
																						  ofType:@"tif"]];
		else if ([[savedItems objectAtIndex:row] isStillRunning] == 0)
			img = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"statusRed" 
																						  ofType:@"tif"]];
		else if ([[savedItems objectAtIndex:row] isStillRunning] == 2)
			img = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"statusOrange" 
																						  ofType:@"tif"]];
		return img;
	}
	return nil;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification 
{ 
	NSLog(@"current row selected %d", [tv selectedRow]);
	[tunnelHost setStringValue:[[savedItems objectAtIndex:[tv selectedRow]] tunnelHost]];
	[userName setStringValue:[[savedItems objectAtIndex:[tv selectedRow]] userName]];
	[localPort setStringValue:[[savedItems objectAtIndex:[tv selectedRow]] localPort]];
	[remoteHost setStringValue:[[savedItems objectAtIndex:[tv selectedRow]] remoteHost]];
	[remotePort setStringValue:[[savedItems objectAtIndex:[tv selectedRow]] remotePort]];
	[password setStringValue:[[savedItems objectAtIndex:[tv selectedRow]] password]];
	currentSession = [savedItems objectAtIndex:[tv selectedRow]];
	
	if ([currentSession isStillRunning] == 2)
		[self startWheel];
	else
		[self stopWheel];
	if ([currentSession isStillRunning] == 1)
		[self disableInterface];
	else
		[self enableInterface];
}

-(void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	[[savedItems objectAtIndex:rowIndex] setSessionName:anObject];
	[NSKeyedArchiver archiveRootObject:savedItems toFile:[savePath stringByExpandingTildeInPath]];
}

-(BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
	
    [pboard declareTypes:[NSArray arrayWithObject:@"MyData"] owner:self];
    [pboard setData:data forType:@"MyData"];
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
	
    NSPasteboard* pboard = [info draggingPasteboard];
    NSData* rowData = [pboard dataForType:@"MyData"];
    NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
    int dragRow = [rowIndexes firstIndex];
	
	SavedItemsObject *o = [[savedItems objectAtIndex:dragRow] retain];
	[savedItems removeObject:o];
	
	
	if (row == [savedItems count])
	{
		[savedItems addObject:o];
	}
	else
	{
		if (row - 1 < 0)
			row++;
		[savedItems insertObject:o atIndex:(row - 1)];
		if (o == currentSession)
			[tv selectRow:(row - 1) byExtendingSelection:NO];
	}
	[tv reloadData];
	[o release];
	
	[NSKeyedArchiver archiveRootObject:savedItems toFile:[savePath stringByExpandingTildeInPath]];
	return YES;
	
}
 

/**
 * This part is for the delegation of the differents NSTextField, to
 * enable instant save when modified.
**/
- (void)controlTextDidChange:(NSNotification *)aNotification
{
	NSTextField *o  =[aNotification object];
	
	if ([o isEqual:tunnelHost])
		[currentSession setTunnelHost:[o stringValue]];
		 
	else if ([[aNotification object] isEqual:userName])
		[currentSession setUserName:[o stringValue]];
		 
	else if ([[aNotification object] isEqual:localPort])
		[currentSession setLocalPort:[o stringValue]];
		 
	else if ([[aNotification object] isEqual:remoteHost])
		[currentSession setRemoteHost:[o stringValue]];
	
	else if ([[aNotification object] isEqual:remotePort])
		 [currentSession setRemotePort:[o stringValue]];
	
	else if ([[aNotification object] isEqual:password])
		[currentSession setPassword:[o stringValue]];
		
	[NSKeyedArchiver archiveRootObject:savedItems toFile:[savePath stringByExpandingTildeInPath]];
}


/**
 * This part is for the delegation of the NSApplication to
 * allow closing all ssh session before terminating
 **/
- (void) applicationWillTerminate: (NSNotification *) notification
{
	for (int i = 0; i < [savedItems count]; i++)
		[[savedItems objectAtIndex:i] closeTunnel];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
	[self openMainWindow:nil];    
	return YES;
}
@end
