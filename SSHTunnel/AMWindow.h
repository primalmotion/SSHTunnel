#import <Cocoa/Cocoa.h>

@interface AMWindow : NSWindow {

}

- (void) runSheetAlertTitle:(NSString*)title message:(NSString*)message firstButton:(NSString*)button1 secondButton:(NSString*)button2 from:(id)sender selector:(NSString*)sel;

@end
