#import "AMWindow.h"

//typedef struct s_AMContextInfo {
//	id			object;
//	NSString	*selector;
//} AMContextInfo;

@implementation AMWindow

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
	
//	AMContextInfo *context = malloc(sizeof(AMContextInfo));
//	context->object = sender;
//	context->selector = sel;
	
	[alert beginSheetModalForWindow:self 
					  modalDelegate:sender 
					 didEndSelector:NSSelectorFromString(sel) 
						contextInfo:nil];
}

//- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
//{
//	alert = nil;
//	AMContextInfo *context = (AMContextInfo *)contextInfo;
//	
//	if (context->selector != nil)
//		[context->object performSelector:NSSelectorFromString(context->selector)];
//
//	free(context);
//}

@end
