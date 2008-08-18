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
			[self pushOn];
		else
			[self pushOff];
	}
	
}

- (void) awakeFromNib
{
	[self addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
	
	[self bind:@"status" toObject:[sessionController sessionsArrayController]  withKeyPath:@"selection.connected" options:nil];
}
	
- (void)drawRect:(NSRect)rect 
{
	startingColor = [NSColor darkGrayColor];
	endingColor = [NSColor grayColor];
	if (endingColor == nil || [startingColor isEqual:endingColor]) {
		[startingColor set];
		NSRectFill(rect);
	}
	else {
		NSGradient* aGradient = [[[NSGradient alloc]
								  initWithStartingColor:startingColor
								  endingColor:endingColor] autorelease];
		[aGradient drawInRect:[self bounds] angle:270];
	}
}
	


- (void) pushOn
{
	NSRect newFrame = [switchView frame];
	newFrame.origin.x += [switchView frame].size.width;
	if (newFrame.origin.x > [self frame].size.width /2 )
		newFrame.origin.x = [self frame].size.width /2;
	[[switchView animator] setFrame:newFrame];
	[appController openTunnel:nil];
	[(NSButton*)switchView setTitle:@"Off"];
}

- (void) pushOff
{
	NSRect newFrame = [switchView frame];
	newFrame.origin.x -= [switchView frame].size.width;
	if (newFrame.origin.x < 0 )
		newFrame.origin.x = 0;

	[[switchView animator] setFrame:newFrame];
	[appController closeTunnel:nil];
	[(NSButton*)switchView setTitle:@"On"];
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
