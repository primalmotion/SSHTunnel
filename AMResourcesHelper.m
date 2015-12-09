//
//  AMResourcesHelper.m
//  SSHTunnel
//
//  Created by Guilherme Rambo on 09/12/15.
//
//

#import "AMResourcesHelper.h"

@implementation AMResourcesHelper

+ (NSString *)pathForImageNamed:(NSString *)name
{
    CGFloat scaleFactor = [NSScreen mainScreen].backingScaleFactor;
    NSString *scaleFactorString = @"";
    
    if (scaleFactor > 1.0) scaleFactorString = [NSString stringWithFormat:@"@%.0fx", scaleFactor];
    
    NSString *resourceName = [NSString stringWithFormat:@"%@%@", name, scaleFactorString];
    return [[NSBundle mainBundle] pathForResource:resourceName ofType:@"png"];
}

@end
