//
//  AMNEtworkServicesChooser.m
//  SSHTunnel
//
//  Created by Antoine Mercadal on 23/08/08.
//  Copyright 2008 Capgemini. All rights reserved.
//

#import "AMNetworkServicesChooser.h"


@implementation AMNetworkServicesChooser
@synthesize content;

- (id) init
{
	if (self = [super init])
	{
		[self setContent:[NSMutableArray array]];
		[self getSystemNetworkServices];
		return self;
	}
	return nil;
}

- (void) getSystemNetworkServices
{
	task 			= [[NSTask alloc] init];
	stdOut			= [NSPipe pipe];
	
	[task setLaunchPath:@"/usr/sbin/networksetup"];
	[task setArguments:[NSArray arrayWithObjects:@"-listallnetworkservices", nil]];
	[task setStandardOutput:stdOut];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(handleEndOfTask:)
												 name:NSFileHandleReadToEndOfFileCompletionNotification
											   object:[[task standardOutput] fileHandleForReading]];
	
	
	[[stdOut fileHandleForReading] readToEndOfFileInBackgroundAndNotify];
	[task launch];
	
}

- (void) handleEndOfTask:(NSNotification *) aNotification
{
	NSData		*data;
	NSString	*outputContent;
	NSPredicate *checkSuccess;
	
	data = [[aNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];

	outputContent		= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	NSMutableArray *a = [NSMutableArray arrayWithArray:[outputContent componentsSeparatedByString:@"\n"]];
	[a removeLastObject];
	[a removeObjectAtIndex:0];
	[self setContent:a];

	[[NSNotificationCenter defaultCenter]  removeObserver:self name:NSFileHandleReadCompletionNotification object:[stdOut fileHandleForReading]];
	[task terminate];
	data = nil;
	outputContent = nil;
	checkSuccess = nil;
	task = nil;
}
@end
