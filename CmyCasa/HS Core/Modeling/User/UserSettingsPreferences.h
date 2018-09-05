//
//  UserSettingsPreferences.h
//  Homestyler
//
//  Created by Berenson Sergei on 10/16/13.
//
//  updated by Dan Baharir on 07/12/14. (implementation for more general use)


/*
 This file will be responsible for managing all of the user settings data saved to the NSUserDefaults.
 will be used by UserManager and throughout the app using the corresponding keys.
 */


#import <Foundation/Foundation.h>

#define ANALYTICS_ENABLED               [UserSettingsPreferences isParamEnabledWithKey:kUserPreferenceAnalytics]
#define FACEBOOK_LIKE_ENABLED           ([UserSettingsPreferences isParamEnabledWithKey:kUserPreferenceFacebookLike] && [[ConfigManager sharedInstance] canFacebookLikeFlag] \
                                        && [[UserManager sharedInstance] isLoggedIn] \
                                        && [ConfigManager isFaceBookActive])
#define NEWSLETTER_ENABLED              ([UserSettingsPreferences isParamEnabledWithKey:kUserPreferenceSendNewsletter] && [[UserManager sharedInstance] isLoggedIn])
#define PUSHNOTIFICATIONS_ENABLED       ([UserSettingsPreferences isParamEnabledWithKey:kUserPreferenceReceivePushes] && [[UserManager sharedInstance] isLoggedIn])


// ?User settings keys
#define kUserPreferenceAnalytics @"SendFlurryInfo"
#define kUserPreferenceFacebookLike @"SendFacebookLikeOnHSLike"
#define kUserPreferenceSendNewsletter @"SendNewslettters"
#define kUserPreferenceReceivePushes @"ReceivePushNotifications"
#define kUserPreferenceReceivePushesDisabled @"ReceivePushNotificationsUserDisabled"
#define kUserPreferenceGridOptionsShowGrid @"kUserPreferenceGridOptionsShowGrid"
#define kUserPreferenceGridOptionsSnapToGrid @"kUserPreferenceGridOptionsSnapToGrid"



typedef enum SettingsCellTypes {
	kPushCell = 0,
    kEmailsSend = 1,
    kDataCollect = 2,
    kFBLikes=3
} SettingsCellType;


@interface UserSettingsPreferences : NSObject

-(void)setSendingAnalyticsEnabled:(BOOL)isEnabled;
-(void)setReceiveingPushNotificationsEnabled:(BOOL)isEnabled forEmail:(NSString*)userEmail;
-(void)clearUserInfo;

// general setter ,uses a given string key and bool value.
+(void)setEnabledToParamWithKey:(BOOL)isEnabled andKey:(NSString *)paramKey;

// a general method to get the bool value of a given key from the userSettings
+(BOOL)isParamEnabledWithKey:(NSString *)paramKey;

+(BOOL)isUserForcedToDisablePushNotifications:(NSString*)useremail;
+(void)initPreferences;

@end
