#import <Cocoa/Cocoa.h>

@interface AMPopUpButton : NSPopUpButton {

	NSMutableArray *accountServers;
}

- (NSString *) getCurrentServerName;
- (NSString *) getCurrentServerUrl;
- (NSString *) getCurrentServerPort;
- (NSString *) getCurrentServerShScriptName;
@end
