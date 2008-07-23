#import "AMService.h"

@implementation AMService

@synthesize serviceName;
@synthesize serviceLocalPorts;
@synthesize serviceRemotePorts;
@synthesize serviceDescription;
@synthesize inputService;

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
	
	[super dealloc];
}

- (id) initWithCoder:(NSCoder *)coder
{
	self = [super init];
	
	serviceName			= [[coder decodeObjectForKey:@"serviceName"] retain];
	serviceLocalPorts	= [[coder decodeObjectForKey:@"serviceLocalPorts"] retain];
	serviceRemotePorts	= [[coder decodeObjectForKey:@"serviceRemotePorts"] retain];
	serviceDescription	= [[coder decodeObjectForKey:@"serviceDescription"] retain];
	
	return self;
}


- (void) encodeWithCoder:(NSCoder *) coder
{	
	[coder encodeObject:serviceName forKey:@"serviceName"];
	[coder encodeObject:serviceRemotePorts forKey:@"serviceRemotePorts"];
	[coder encodeObject:serviceLocalPorts forKey:@"serviceLocalPorts"];
	[coder encodeObject:serviceDescription forKey:@"serviceDescription"];
}

- (NSString *) description
{
	return serviceName;
}


@end
