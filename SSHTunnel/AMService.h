#import <Cocoa/Cocoa.h>

@interface AMService : NSObject <NSCoding> {
	NSString	*serviceName;
	NSString	*serviceLocalPorts;
	NSString	*serviceRemotePorts;
	NSString	*serviceDescription;
	BOOL		inputService;
}
@property(readwrite, assign)	NSString	*serviceName;
@property(readwrite, assign)	NSString	*serviceLocalPorts;
@property(readwrite, assign)	NSString	*serviceRemotePorts;
@property(readwrite, assign)	NSString	*serviceDescription;
@property(readwrite)			BOOL		inputService;

- (id) initWithName:(NSString*)name localPorts:(NSString*)localports remotePorts:(NSString*)remoteports description:(NSString*)desc input:(BOOL)isInput;

@end