#import <Cocoa/Cocoa.h>
#import "AMAuth.h"

@interface AccountView : NSView {
	IBOutlet NSTextField			*login;
	IBOutlet NSTextField			*password;
	IBOutlet NSTextField			*confirmPassword;
	IBOutlet NSProgressIndicator	*progressor;
	IBOutlet NSButton				*createButton;
	
	id			delegate;
	NSTask		*sshTask;
	NSPipe		*stdOut;
	NSString	*outputContent;
}

@property(readwrite, assign) id delegate;

- (IBAction) createAccount:(id)sender;

@end
