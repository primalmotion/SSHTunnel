#import <Cocoa/Cocoa.h>
#import "AMService.h"

@interface AMServiceViewController : NSObject{

	IBOutlet NSArrayController		*serviceArrayController;
	
	NSMutableArray					*services;
	NSString						*serviceSavePath;
	NSTimer							*pingDelayer;
}

@property(readwrite, assign) NSMutableArray *services;

- (void) createObservers;
- (void) saveState;
- (void) performSaveProcess:(NSTimer *)theTimer;

@end
