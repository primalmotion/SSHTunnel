#import "AMSessionViewController.h"

@implementation AMSessionViewController

@synthesize	sessions;


- (id) init
{
	self = [super init];
	
	NSFileManager *f = [NSFileManager defaultManager];
	
	sessionSavePath			=  @"~/Library/Application Support/SSHTunnel/sessions.sst";
	
	if ([f fileExistsAtPath:[sessionSavePath stringByExpandingTildeInPath]] == YES)
		[self setSessions:[NSKeyedUnarchiver unarchiveObjectWithFile:[sessionSavePath stringByExpandingTildeInPath]]];
	else
		[self setSessions:[[NSMutableArray alloc] init]];
	
	[sessionsArrayController addObserver:self 
							  forKeyPath:@"arrangedObjects" 
								 options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								 context:NULL];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(handleDataNameChange:) 
												 name:@"AMSessionNameHasChange" 
											   object:nil];
	
	return self;
	
}

- (void) handleDataNameChange:(NSNotification*)notif
{
	[self saveState];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[self saveState];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	[self saveState];
}

- (void) saveState
{
	NSLog(@"Sessions status saved.");
	[NSKeyedArchiver archiveRootObject:[self sessions] toFile:[sessionSavePath stringByExpandingTildeInPath]];
}

- (AMSession*) getSelectedSession
{
	return (AMSession*)[[sessionsArrayController selectedObjects] objectAtIndex:0];
}

@end
