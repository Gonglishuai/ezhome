//
//  NSObject+Flurry.m
//  Homestyler
//
//  Created by Yiftach Ringel on 23/06/13.
//
//

#import "NSObject+Flurry.h"

@implementation NSObject (Flurry)

- (void)logFlurryEvent:(NSString*)event
{
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
        
//            [HSFlurry logEvent:event];
        
    }
#endif
}

- (void)logFlurryEvent:(NSString*)event withParams:(NSDictionary*)params
{
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
        
//        [HSFlurry logEvent:event withParameters:params];
        
    }
#endif
}

@end
