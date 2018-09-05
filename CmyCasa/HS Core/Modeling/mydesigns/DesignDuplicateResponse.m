//
//  DesignDuplicateResponse.m
//  Homestyler
//
//  Created by Berenson Sergei on 8/4/13.
//
//

#import "DesignDuplicateResponse.h"

@implementation DesignDuplicateResponse

+ (RKObjectMapping*)jsonMapping{
    

    
    RKObjectMapping* entityMapping = [super jsonMapping];
    
    [entityMapping addAttributeMappingsFromDictionary:
     @{
     @"id" : @"designIDnew"
     
     }];
    
    
    
    return entityMapping;
}

- (void)applyPostServerActions{
    

}

@end
