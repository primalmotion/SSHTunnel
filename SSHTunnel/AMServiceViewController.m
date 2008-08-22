#import "AMServiceViewController.h"

@implementation AMServiceViewController

@synthesize services;

#pragma mark -
#pragma mark Initilisations
- (id) init
{
	self = [super init];
	
	
	NSFileManager *f = [NSFileManager defaultManager];
	serviceSavePath	=  @"~/Library/Application Support/SSHTunnel/services.sst";
	
	if ([f fileExistsAtPath:[serviceSavePath stringByExpandingTildeInPath]] == YES)
	{
		@try
		{
			[self setServices:[NSKeyedUnarchiver unarchiveObjectWithFile:[serviceSavePath stringByExpandingTildeInPath]]];
			NSLog(@"Services state recovered");
		}
		@catch (NSException *e) 
		{
			int rep = NSRunAlertPanel(@"Error while loading datas", @"SSHTunnel was unable to load its saved state. Would you like to revert to the factory presets ? ", @"Yes", @"No", nil);
			if (rep == NSAlertDefaultReturn)
				[[NSNotificationCenter defaultCenter] postNotificationName:AMErrorLoadingSavedState object:nil];
			else
				exit(0);
		}
	}
	else
	{
		NSMutableArray *tmp = [[NSMutableArray alloc] init];
		[tmp addObject:[[AMService alloc] initWithName:@"Web"	localPorts:@"4280" remotePorts:@"80" description:@"Connexion aux serveurs web" input:YES]];
		[tmp addObject:[[AMService alloc] initWithName:@"FTP"	localPorts:@"4221" remotePorts:@"21" description:@"Transfert de fichiers" input:YES]];
		[tmp addObject:[[AMService alloc] initWithName:@"AFP"	localPorts:@"42548" remotePorts:@"458" description:@"Connexion au partage de fichiers d'autres Macs" input:YES]];
		[tmp addObject:[[AMService alloc] initWithName:@"Samba" localPorts:@"42169" remotePorts:@"169" description:@"Connexion au partage de fichiers d'ordinateurs Windows" input:YES]];
		[tmp addObject:[[AMService alloc] initWithName:@"SSH"	localPorts:@"4222" remotePorts:@"22" description:@"Connexion aux shells sécurisés" input:YES]];
		
		[self setServices:tmp];
	}
	f = nil;
	return self;
}

- (void) awakeFromNib
{
	[self createObservers];
}

- (void) createObservers
{
	
	[serviceArrayController addObserver:self 
							 forKeyPath:@"selection.serviceName" 
								options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								context:nil];
	
	[serviceArrayController addObserver:self 
							 forKeyPath:@"selection.servicePort" 
								options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								context:nil];
	
	[serviceArrayController addObserver:self 
							 forKeyPath:@"selection.serviceDescription" 
								options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
								context:nil];
}


#pragma mark -
#pragma mark Obeservers and delegates

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[self saveState];
}


#pragma mark -
#pragma mark Saveing processes
- (void) saveState
{
	if (pingDelayer != nil)
		[pingDelayer invalidate];
	
	NSLog(@"Service saving processes programmed.");
	pingDelayer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(performSaveProcess:) userInfo:nil repeats:NO];
	
}

- (void) performSaveProcess:(NSTimer *)theTimer
{
	NSLog(@"Services status saved.");
	[NSKeyedArchiver archiveRootObject:[self services] toFile:[serviceSavePath stringByExpandingTildeInPath]];
}

@end
