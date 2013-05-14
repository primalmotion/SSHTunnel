//
//  AMSwitchButton.m
//  SSHTunnel
//
//  Created by Antoine Mercadal on 18/08/08.
//  Copyright 2008 Capgemini. All rights reserved.
//

#import "AMSwitchButton.h"


@implementation AMSwitchButton

@synthesize status;

- (id) init
{
	self = [super init];
	if (self)
	{
		[self setStatus:NO];
		return self;
		
	}
	return nil;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqual:@"status"])
	{
		if ([self status] == YES)
		{
			[self pushOn];
		}
		else
		{	
			[self pushOff];
		}
	}
	
}

- (void) awakeFromNib
{	
	[self addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
	[self bind:@"status" toObject:[sessionController sessionsTreeController]  withKeyPath:@"selection.connected" options:nil];
}
	
- (void)drawRect:(NSRect)rect 
{
	if ([self status] == NO)
	{
		startingColor = [NSColor colorWithCalibratedRed:0.23 green:0.26 blue:0.29 alpha:1.0];
		endingColor = [NSColor colorWithCalibratedRed:0.53 green:0.56 blue:0.59 alpha:1.0];	
	}
	else
	{
		startingColor = [NSColor colorWithCalibratedRed:0.31 green:0.75 blue:0.40 alpha:1.0];
		endingColor = [NSColor colorWithCalibratedRed:0.21 green:0.65 blue:0.30 alpha:1.0];
	}
	if (endingColor == nil || [startingColor isEqual:endingColor]) {
		[startingColor set];
		NSRectFill(rect);
	}
	else {
		NSGradient* aGradient = [[NSGradient alloc]
								  initWithStartingColor:startingColor
								  endingColor:endingColor];
		[aGradient drawInRect:[self bounds] angle:270];
	}
}

- (void) pushOn
{
	NSRect newFrame = [switchView frame]; 
	newFrame.origin.x += [switchView frame].size.width;
	if (newFrame.origin.x > [self frame].size.width / 2 )
		newFrame.origin.x = [self frame].size.width / 2;
	[[switchView animator] setFrame:newFrame];
	
	
	newFrame = [offLabel frame];
	newFrame.origin.x += ([offLabel frame].size.width) + 5;
	[[offLabel animator] setFrame:newFrame];

	newFrame = [onLabel frame];
	newFrame.origin.x = 7;
	[[onLabel animator] setFrame:newFrame];

	[appController openSession:nil];
	//[NSTimer scheduledTimerWithTimeInterval:0.35 target:self selector:@selector(display) userInfo:nil repeats:NO];
}

- (void) pushOff
{
	NSRect newFrame = [switchView frame];
	newFrame.origin.x -= [switchView frame].size.width;
	if (newFrame.origin.x < 0 )
		newFrame.origin.x = 0;
	[[switchView animator] setFrame:newFrame];
	
	newFrame = [offLabel frame];
	newFrame.origin.x = 35;
	[[offLabel animator] setFrame:newFrame];
	
	newFrame = [onLabel frame];
	newFrame.origin.x -= [onLabel frame].size.width + 7;
	[[onLabel animator] setFrame:newFrame];
	
	[appController closeSession:nil];
	//[NSTimer scheduledTimerWithTimeInterval:0.35 target:self selector:@selector(display) userInfo:nil repeats:NO];
}


- (IBAction) switchStatus:(id)sender
{
	[self setStatus:![self status]];
	
	if ([self status] == YES)
		[self pushOn];
	else
		[self pushOff];
}

@end
