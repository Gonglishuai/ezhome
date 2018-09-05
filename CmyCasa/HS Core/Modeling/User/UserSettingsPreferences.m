//
//  UserSettingsPreferences.m
//  Homestyler
//
//  Created by Berenson Sergei on 10/16/13.
//
// updated by Dan Baharir on 07/12/14. (updated for general use)

#import "UserSettingsPreferences.h"



//////////////////////////////////////////////////
//                  IMPLEMENTATION              //
//////////////////////////////////////////////////

@implementation UserSettingsPreferences




//////////////////////////////////////////////////
//                  STATIC METHODS              //
//////////////////////////////////////////////////

+(void)initPreferences
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:kUserPreferenceAnalytics] == nil){
        [standardUserDefaults setObject:@YES forKey:kUserPreferenceAnalytics];
    }
    if([[NSUserDefaults standardUserDefaults] objectForKey:kUserPreferenceFacebookLike] == nil){
        [standardUserDefaults setObject:@([[ConfigManager sharedInstance] canFacebookLikeFlag]) forKey:kUserPreferenceFacebookLike];
    }
    if([[NSUserDefaults standardUserDefaults] objectForKey:kUserPreferenceSendNewsletter] == nil){
        [standardUserDefaults setObject:@NO forKey:kUserPreferenceSendNewsletter];
    }
    
    // Redesign - grid options settings
    if([[NSUserDefaults standardUserDefaults] objectForKey:kUserPreferenceGridOptionsShowGrid] == nil){
        [standardUserDefaults setObject:@NO forKey:kUserPreferenceGridOptionsShowGrid];
    }
    if([[NSUserDefaults standardUserDefaults] objectForKey:kUserPreferenceGridOptionsSnapToGrid] == nil){
        [standardUserDefaults setObject:@NO forKey:kUserPreferenceGridOptionsSnapToGrid];
    }
    
    [standardUserDefaults synchronize];
}

//////////////////////////////////////////////////////////////////////////////////

+(BOOL)isUserForcedToDisablePushNotifications:(NSString*)useremail{
    
    
    if (useremail==nil) {
        return NO;
    }
    
    NSString * strkey=[NSString stringWithFormat:@"%@_%@",kUserPreferenceReceivePushesDisabled,useremail];
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber * num=  [standardUserDefaults objectForKey:strkey];
    if (!num) {
        return NO;
    }
    
    return YES;
    
}

//////////////////////////////////////////////////////////////////////////////////

+(BOOL)isParamEnabledWithKey:(NSString *)paramKey
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber * num=  [standardUserDefaults objectForKey:paramKey];
    if ([num intValue] == 0) {
        return NO;
    }
    
    return YES;
}

//////////////////////////////////////////////////////////////////////////////////

+(void)setEnabledToParamWithKey:(BOOL)isEnabled andKey:(NSString *)paramKey
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:@(isEnabled) forKey:paramKey];
    [standardUserDefaults synchronize];
}


//////////////////////////////////////////////////
//                  PUBLIC METHODS              //
//////////////////////////////////////////////////
-(void)clearUserInfo{
    [UserSettingsPreferences setEnabledToParamWithKey:NO andKey:kUserPreferenceSendNewsletter];
}

//////////////////////////////////////////////////////////////////////////////////

-(void)setSendingAnalyticsEnabled:(BOOL)isEnabled{
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:@(isEnabled) forKey:kUserPreferenceAnalytics];
    [standardUserDefaults synchronize];
    
#ifdef USE_FLURRY    
    if (isEnabled==false && ANALYTICS_ENABLED) {
//            [HSFlurry logEvent: FLURRY_SETTING_DATA_COLLECTION_OFF]; 
        }
#endif
    
}


//////////////////////////////////////////////////////////////////////////////////

-(void)setReceiveingPushNotificationsEnabled:(BOOL)isEnabled forEmail:(NSString*)userEmail{
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:@(isEnabled) forKey:kUserPreferenceReceivePushes];
    
    if (userEmail) {
        NSString * strkey=[NSString stringWithFormat:@"%@_%@",kUserPreferenceReceivePushesDisabled,userEmail];
    
        if (isEnabled) {
            [standardUserDefaults removeObjectForKey:strkey];
        }else{
            [standardUserDefaults setObject:@"" forKey:strkey];
        }
    }
    
    [standardUserDefaults synchronize];
}

@end


