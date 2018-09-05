//
//  HSSharingPreferencesManager.h
//  ADSharingComponent
//
//  Created by Ma'ayan on 10/14/13.
//  Copyright (c) 2013 Ma'ayan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HSSharingPreferencesManager : NSObject

+ (id)sharedSharingPreferencesManager;

//a dic of NSNumber(HSSharingIntentType)
- (void)saveSharingPreferences:(NSDictionary *)preferences;
- (NSDictionary *)getSharingPreferences;

@end
