//
//  NSDictionary+Helpers.m
//  Homestyler
//
//  Created by Or Sharir on 2/26/13.
//
//

#import "NSDictionary+Helpers.h"

@implementation NSDictionary (Helpers)

+ (NSDictionary *)dictionaryWithData:(NSData *)data
{
    if (!data) return nil;
    NSString* string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [string propertyList];
}
@end