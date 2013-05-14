#import "AMService.h"

@implementation AMService

@synthesize serviceName;
@synthesize serviceLocalPorts;
@synthesize serviceRemotePorts;
@synthesize serviceDescription;
@synthesize inputService;

#pragma mark -
#pragma mark Initializations

- (id) init
{
	self = [super init];
	
	return self;
}

- (id) initWithName:(NSString*)name localPorts:(NSString*)localports remotePorts:(NSString*)remoteports description:(NSString*)desc input:(BOOL)isInput
{
	self = [super init];
	
	[self setServiceName:name];
	[self setServiceLocalPorts:localports];
	[self setServiceRemotePorts:remoteports];
	[self setServiceDescription:desc];
	[self setServiceDescription:desc];
	[self setInputService:isInput];
	
	return self;
}

- (void) dealloc
{
	serviceName = nil;
	serviceRemotePorts = nil;
	serviceLocalPorts = nil;
	serviceDescription = nil;
	
}

- (id) initWithCoder:(NSCoder *)coder
{
	self = [super init];
	
	serviceName			= [coder decodeObjectForKey:@"serviceName"];
	serviceLocalPorts	= [coder decodeObjectForKey:@"serviceLocalPorts"];
	serviceRemotePorts	= [coder decodeObjectForKey:@"serviceRemotePorts"];
	serviceDescription	= [coder decodeObjectForKey:@"serviceDescription"];
	
	return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{	
	[coder encodeObject:serviceName forKey:@"serviceName"];
	[coder encodeObject:serviceRemotePorts forKey:@"serviceRemotePorts"];
	[coder encodeObject:serviceLocalPorts forKey:@"serviceLocalPorts"];
	[coder encodeObject:serviceDescription forKey:@"serviceDescription"];
}


#pragma mark -
#pragma mark Overloaded accessors

- (NSString *) description
{
	return serviceName;
}


@end
