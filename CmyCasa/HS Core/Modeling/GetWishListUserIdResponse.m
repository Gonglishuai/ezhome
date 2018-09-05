//
//  GetWishListUserIdResponse.m
//  Homestyler
//
//  Created by Tomer Har Yoffi on 12/10/14.
//
//

#import "GetWishListUserIdResponse.h"

@implementation GetWishListUserIdResponse

+ (RKObjectMapping*)jsonMapping
{
    RKObjectMapping* entityMapping = [super jsonMapping];
    
    [entityMapping addAttributeMappingsFromDictionary:
     @{
       @"uid" : @"wishlistUserId",
       }];
    
    return entityMapping;
}

-(void)applyPostServerActions
{
}


@end
