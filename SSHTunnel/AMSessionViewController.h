#import <Cocoa/Cocoa.h>
#import "AMSession.h"

@interface AMSessionViewController :NSObject {
	
	IBOutlet NSArrayController		*sessionsArrayController;
	
	NSMutableArray					*sessions;
	NSString						*sessionSavePath;
}
@property(readwrite, assign)	NSMutableArray		*sessions;

- (void) saveState;
- (void) handleDataNameChange:(NSNotification*)notif;
- (AMSession*) getSelectedSession;

@end
