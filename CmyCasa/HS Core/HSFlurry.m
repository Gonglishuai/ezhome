//
//  HSFlurry.m
//  Homestyler
//
//  Created by Berenson Sergei on 7/7/13.
//
//

#import "HSFlurry.h"
#import "GAI.h"
#import <Analytics/SEGAnalytics.h>
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "ServerUtils.h"

@implementation HSFlurry

+(void)logAnalyticEvent:(NSString *)eventName {
    if(ANALYTICS_ENABLED){
        
#ifdef USE_FLURRY
      
        [self logEvent:eventName];
#endif
         }
}

+(void)logAnalyticEvent:(NSString *)eventName withParameters:(NSDictionary *)parameters{
    if(ANALYTICS_ENABLED){
        
#ifdef USE_FLURRY
        [self logEvent:eventName withParameters:parameters];
#endif
    }
}

#pragma mark- Flurry Tracking methods
+ (void)logEvent:(NSString *)eventName withParameters:(NSDictionary *)parameters{

    if (!eventName && !parameters) {
        //bug fix
        return;
    }
    
    NSMutableDictionary *params=[parameters mutableCopy];
    
    //add device type
    UIDevice* thisDevice = [UIDevice currentDevice];
    if(thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        [params setObject:@"iPad" forKey:@"device_type"];
    }else{
        [params setObject:@"iPhone" forKey:@"device_type"];
    }
    
    [params setObject:thisDevice.model forKey:@"model"];
    [params setObject:thisDevice.systemVersion forKey:@"ios_version"];
    
    if ([ConfigManager isFlurryActive]){
        [super logEvent:eventName withParameters:[params copy]];
    }
    
    //google analytics
    [self logGAEvent:eventName withParameters:parameters];
}

+ (void)logEvent:(NSString *)eventName{
    if ([[UserManager sharedInstance] isLoggedIn]) {
        [HSFlurry logEvent:eventName withParameters:[NSDictionary dictionary]];
    }
    else{
        if ([ConfigManager isFlurryActive]){
             [super logEvent:eventName];
        } else {
            //google analytics
            [self logGAEvent:eventName ];
        }
    }
}

+ (void)logError:(NSString *)errorID message:(NSString *)message exception:(NSException *)exception
{
    if ([ConfigManager isFlurryActive]){
        [super logError:errorID message:message exception:exception ];
    }
}

#pragma mark- Google Analytics tracking methods
+(void)logGAEvent:(NSString *)eventName withParameters:(NSDictionary *)parameters
{
    id <GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    id key = nil; // Assumes 'message' is not empty
    NSString* value = @"";
      if([parameters count] > 0)
    {
        key = [[parameters allKeys] objectAtIndex:0]; // Assumes 'message' is not empty
        value = [parameters objectForKey:key];
    }
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:eventName    // Event category (required)
                                                          action:key  // Event action (required)
                                                           label:value          // Event label
                                                           value:nil] build]];    // Event value
}

+(void)logGAEvent:(NSString *)eventName
{
    id <GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:eventName    // Event category (required)
                                                          action:nil  // Event action (required)
                                                           label:nil          // Event label
                                                        value:nil] build]];    // Event value
}


#pragma mark- Segment
+(void)segmentTrack:(NSString*)eventName{
    if ([ConfigManager isSegmentActive]) {
        [[SEGAnalytics sharedAnalytics] track:eventName properties:nil];
    }
}

+ (void)segmentTrack:(NSString *)eventName withParameters:(NSDictionary *)parameters{
    if ([ConfigManager isSegmentActive]) {
        [[SEGAnalytics sharedAnalytics] track:eventName properties: parameters];
    }
}

+(void)loggedInUserSetIdentity:(NSString*)identity{
    if ([ConfigManager isSegmentActive]) {
        
        if (identity) {
            [[SEGAnalytics sharedAnalytics] identify:identity];
        }else{
            [[SEGAnalytics sharedAnalytics] identify:[[ServerUtils sharedInstance] generateGuid]];
        }
    }
}

+(void)segmentIdentify:(UserDO *)user isRegister:(BOOL)isRegister{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    if (user.userEmail) {
        [dict setObject:user.userEmail forKey:@"email"];
    }
    
    if (user.firstName) {
        [dict setObject:user.firstName forKey:@"firstName"];
    }
    
    if (user.lastName) {
        [dict setObject:user.lastName forKey:@"lastName"];
    }
    
    if (isRegister) {
        NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                              dateStyle:NSDateFormatterShortStyle
                                                              timeStyle:NSDateFormatterFullStyle];
        [dict setObject:dateString forKey:@"createAt"];
    }
    
    [[SEGAnalytics sharedAnalytics] identify:user.userID traits:dict];
}
@end
