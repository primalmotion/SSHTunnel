#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "SavedItemsObject.h"

@interface MyAppController : NSObject {
    IBOutlet NSTextField			*localPort;
	IBOutlet NSTextField			*userName;
    IBOutlet NSTextField			*remoteHost;
    IBOutlet NSTextField			*remotePort;
    IBOutlet NSTextField			*tunnelHost;
	IBOutlet NSSecureTextField		*password;
	IBOutlet NSButton				*bToggleTunnel;
	IBOutlet NSTableView			*tv;
	IBOutlet NSWindow				*aboutWindow;
	IBOutlet NSImageView			*coreAnimatedImage;
	IBOutlet NSWindow				*mainWindow;
	IBOutlet NSView					*errorPanel;
	IBOutlet NSTextField			*errorMessage;
	IBOutlet NSProgressIndicator	*wheel;
	
	NSMutableArray					*savedItems;
	SavedItemsObject				*currentSession;
	NSString						*savePath;

}
@property(readwrite,assign)	NSMutableArray *savedItems;
@property(readwrite,assign)	SavedItemsObject *currentSession;

- (IBAction)toggleTunnel:(id)sender;
- (IBAction)addSession:(id)sender;
- (IBAction)deleteSession:(id)sender;
- (IBAction)openAboutWindow:(id)sender;
- (IBAction)openMainWindow:(id)sender;
- (IBAction)closeMainWindow:(id)sender;


- (void) listernerForSSHTunnelDown;
- (void) errorPanelDisplaywithMessage:(NSString *)message;
- (void) errorPanelClose:(NSTimer *)theTimer;
- (void) enableInterface;
- (void) disableInterface;
- (void) updateList;
- (void) startWheel;
- (void) stopWheel;
- (void)setWheelValue:(NSNumber *)value;
- (void) incrementWheelValue;

@end
