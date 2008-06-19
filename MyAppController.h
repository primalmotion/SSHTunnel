

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/CoreImage.h>
#import "SavedItemsObject.h"
#import "AMAuth.h"
#import "cgsPrivate.h"

/*!
 @class
 @abstract    <#(brief description)#>
 @discussion  <#(comprehensive description)#>
 */
@interface MyAppController : NSObject {
   	IBOutlet NSButton				*bToggleTunnel;
	IBOutlet NSProgressIndicator	*wheel;
	IBOutlet NSSecureTextField		*password;
	IBOutlet NSTableView			*tv;
	IBOutlet NSTextField			*errorMessage;
	IBOutlet NSTextField			*userName;
	IBOutlet NSButton				*quickLink;
	IBOutlet NSView					*errorPanel;
	IBOutlet NSWindow				*aboutWindow;
	IBOutlet NSWindow				*mainWindow;
	IBOutlet NSView					*serverView;
	IBOutlet NSView					*mainView;
	IBOutlet NSView					*aboutView;
    IBOutlet NSTextField			*remoteHost;
    IBOutlet NSTextField			*remotePort;
    IBOutlet NSTextField			*tunnelHost;
	IBOutlet NSTextField			*localPort;
	IBOutlet NSButton				*removeKey;
	IBOutlet NSToolbarItem			*toolbarSendKeyBouton;
	IBOutlet NSToolbarItem			*switcher;
	
	
	NSString						*sessionSavePath;
	NSString						*serverSavePath;
	SavedItemsObject				*currentSession;
	NSMutableArray					*sessions;
	NSMutableArray					*servers;

}
@property(readwrite,assign)	NSMutableArray *sessions;
@property(readwrite,assign)	NSMutableArray *servers;
@property(readwrite,assign)	SavedItemsObject *currentSession;

- (IBAction) toggleTunnel:(id)sender;
- (IBAction) addSession:(id)sender;
- (IBAction) deleteSession:(id)sender;
- (IBAction) openAboutWindow:(id)sender;
- (IBAction) displayAbout:(id)sender;
- (IBAction) openMainWindow:(id)sender;
- (IBAction) closeMainWindow:(id)sender;
- (IBAction) switchWin:(id)sender;
- (IBAction) openAllSession:(id)sender;
- (IBAction) closeAllSession:(id)sender;
- (IBAction) openUrl:(id)sender;
- (IBAction) killAllSSH:(id)sender;

- (void) errorPanelDisplaywithMessage:(NSString *)message;
- (void) errorPanelClose:(NSTimer *)theTimer;
- (void) enableInterface;
- (void) disableInterface;
- (void) updateList;
- (void) startWheel;
- (void) stopWheel;
- (void) saveState;
- (void)animateWindow:(NSWindow*)win effect:(CGSTransitionType)fx direction:(CGSTransitionOption)dir duration:(float)dur;
- (void) formatQuickLink:(BOOL)enabled;





/// TMP ZONE




/// TMP ZONE
@end
