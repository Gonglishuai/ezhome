//
//  NSArray+Vertex.m
//  CmyCasa
//
//  Created by Or Sharir on 12/30/12.
//
//

#import "NSArray+Vertex.h"
#define COORDS (3)
#define X (0)
#define Y (1)
#define Z (2)

@implementation NSArray (Vertex)
-(GLKVector3)getVectorForVertex:(NSUInteger)index {
	return GLKVector3Make([(NSNumber*)[self objectAtIndex:index*COORDS + X] floatValue], [(NSNumber*)[self objectAtIndex:index*COORDS + Y] floatValue], [(NSNumber*)[self objectAtIndex:index*COORDS + Z] floatValue]);
}
-(NSDictionary*)getDictionaryForVertex:(NSUInteger)index {
    GLKVector3 v = [self getVectorForVertex:index];
    return @{@"x": @(v.x), @"y": @(v.y), @"z": @(v.z)};
}
@end
