

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/CoreImage.h>
#import "SavedItemsObject.h"
#import "AMAuth.h"
#import "cgsPrivate.h"
#import "AccountView.h"

/*!
 @class
 @abstract    <#(brief description)#>
 @discussion  <#(comprehensive description)#>
 */
@interface MyAppController : NSObject {
   	IBOutlet NSButton				*bToggleTunnel;
	IBOutlet NSProgressIndicator	*wheel;
	IBOutlet NSTableView			*tv;
	IBOutlet NSTextField			*errorMessage;
	IBOutlet NSButton				*quickLink;
	IBOutlet NSView					*errorPanel;
	IBOutlet NSWindow				*aboutWindow;
	IBOutlet NSWindow				*mainWindow;
	IBOutlet NSView					*serverView;
	IBOutlet NSView					*mainView;
	IBOutlet NSView					*aboutView;
	IBOutlet AccountView			*registerView;
    IBOutlet NSTextField			*remoteHost;
    IBOutlet NSTextField			*remotePort;
	IBOutlet NSTextField			*localPort;
	IBOutlet NSButton				*removeKey;
	IBOutlet NSToolbarItem			*toolbarSendKeyBouton;
	IBOutlet NSToolbarItem			*switcher;
	IBOutlet NSToolbarItem			*AccountSwitcher;

	NSView							*backViewReminder;
	NSString						*sessionSavePath;
	NSString						*serverSavePath;
	SavedItemsObject				*currentSession;
	NSMutableArray					*sessions;
	NSMutableArray					*servers;
	AMAuth							*currentServer;
}
@property(readwrite,assign)	NSMutableArray		*sessions;
@property(readwrite,assign)	NSMutableArray		*servers;
@property(readwrite,assign)	SavedItemsObject	*currentSession;
@property(readwrite,assign)	AMAuth				*currentServer;

- (IBAction) toggleTunnel:(id)sender;
- (IBAction) addSession:(id)sender;
- (IBAction) deleteSession:(id)sender;
- (IBAction) openAllSession:(id)sender;

- (IBAction) closeAllSession:(id)sender;
- (IBAction) openUrl:(id)sender;
- (IBAction) killAllSSH:(id)sender;


- (IBAction) displayServerView:(id)sender;
- (IBAction) displayAboutView:(id)sender;
- (IBAction) displayRegisterView:(id)sender;
- (IBAction) displayMainView:(id)sender;

- (IBAction) openMainWindow:(id)sender;
- (IBAction) closeMainWindow:(id)sender;



- (IBAction) registerNewAccount:(id)sender;

- (void) errorPanelDisplaywithMessage:(NSString *)message;
- (void) errorPanelClose:(NSTimer *)theTimer;
- (void) enableInterface;
- (void) disableInterface;
- (void) updateList;
- (void) startWheel;
- (void) stopWheel;
- (void) saveState;
- (void) animateWindow:(NSWindow*)win effect:(CGSTransitionType)fx direction:(CGSTransitionOption)dir duration:(float)dur;
- (void) formatQuickLink:(BOOL)enabled;





/// TMP ZONE




/// TMP ZONE
@end
