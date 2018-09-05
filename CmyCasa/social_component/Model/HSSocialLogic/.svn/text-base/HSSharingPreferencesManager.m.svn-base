//
//  HSSharingPreferencesManager.m
//  ADSharingComponent
//
//  Created by Ma'ayan on 10/14/13.
//  Copyright (c) 2013 Ma'ayan. All rights reserved.
//

#import "HSSharingPreferencesManager.h"

#define kUDHSSHaringPreferences @"UDHSSHaringPreferences_preferences"

@implementation HSSharingPreferencesManager

+ (id)sharedSharingPreferencesManager
{
    static dispatch_once_t onceToken;
    static HSSharingPreferencesManager *sharedSharingPreferencesManager = nil;
    
    dispatch_once(&onceToken, ^
                  {
                      sharedSharingPreferencesManager = [[HSSharingPreferencesManager alloc] init];
                  });
    
    return sharedSharingPreferencesManager;
}

- (id) init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

//dic of NSNumber(HSSharingIntentType)
- (void)saveSharingPreferences:(NSDictionary *)preferences
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:preferences forKey:kUDHSSHaringPreferences];
    [defaults synchronize];
}

- (NSDictionary *)getSharingPreferences
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [defaults objectForKey:kUDHSSHaringPreferences];
    
    if (dic == nil)
    {
        dic = [NSDictionary dictionary];
        [self saveSharingPreferences:dic];
        [defaults synchronize];
    }
    
    return dic;
}

@end
