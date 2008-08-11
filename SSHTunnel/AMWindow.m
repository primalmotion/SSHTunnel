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

#import "AMWindow.h"

@implementation AMWindow

- (void) awakeFromNib
{	
    transition = [CATransition animation];
    [transition setType:kCATransitionPush];
    [transition setSubtype:kCATransitionFromBottom];
	[transition setDelegate:self];
	
    NSDictionary *ani = [NSDictionary dictionaryWithObject:transition 
                                                    forKey:@"subviews"];
	
	[[self contentView] setAnimations:ani];
	[[self contentView] setWantsLayer:YES];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	NSLog(@"Removing Core Layer.");
	//[[self contentView] setWantsLayer:NO];
}


- (void) runSheetAlertTitle:(NSString*)title 
				   message:(NSString*)message 
			   firstButton:(NSString*)button1 
			  secondButton:(NSString*)button2 
					  from:(id)sender
				   selector:(NSString*)sel
{
	NSAlert *alert = [[NSAlert alloc] init];
	
	if (button1 != nil)
		[alert addButtonWithTitle:button1];
	
	if (button2 != nil)
		[alert addButtonWithTitle:button2];
	
	[alert setMessageText:title];
	[alert setInformativeText:message];
	[alert setAlertStyle:NSWarningAlertStyle];
	
	[alert beginSheetModalForWindow:self 
					  modalDelegate:sender 
					 didEndSelector:NSSelectorFromString(sel) 
						contextInfo:nil];
}
@end
