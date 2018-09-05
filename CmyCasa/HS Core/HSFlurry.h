//
//  HSFlurry.h
//  Homestyler
//
//  Created by Berenson Sergei on 7/7/13.
//
//

//#import "Flurry.h"
#import "FlurryDefs.h"


@interface HSFlurry : Flurry

+(void)logAnalyticEvent:(NSString *)eventName;
+(void)logAnalyticEvent:(NSString *)eventName withParameters:(NSDictionary *)parameters;
+(void)loggedInUserSetIdentity:(NSString*)identity;

+(void)segmentTrack:(NSString*)eventName;
+(void)segmentTrack:(NSString *)eventName withParameters:(NSDictionary *)parameters;
+(void)segmentIdentify:(UserDO *)user isRegister:(BOOL)isRegister;
@end
