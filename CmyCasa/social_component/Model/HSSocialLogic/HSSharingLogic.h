//
//  HSSharingLogic.h
//  ADSharingComponent
//
//  Created by Ma'ayan on 10/10/13.
//  Copyright (c) 2013 Ma'ayan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HSSharingConstants.h"
#import "HSShareObject.h"

@interface HSSharingLogic : NSObject

- (id)initWithText:(HSShareObject*)shareObj;

/*shaer object generation*/

+(HSShareObject*)generateShareObject:(UIImage*)picture
                        andDesignUrl:(NSString*)designUrl
                          andMessage:(NSString*)message
                        withHashTags:(NSArray*)hashtags;


-(HSShareObject*)getCurrentShareObject;
/* sharing text */
- (NSString *)getSharingText;
- (void)setSharingText:(NSString *)modifiedText;
- (NSString *)getSharingTextWithHashtags;
- (NSString *)getSharingTextForEmail;

/* user sharing preferences */
//dic of NSNumber(HSSharingIntentType)
- (NSDictionary *)getUserSharingPreferences;
- (void)saveUserSharingPreferences;

/* sharing queue */
- (void)initCurrentSharingQueue;
- (void)clearSharingIntentQueue;
- (void)clearGeneralSharingIntentQueue;
- (void)removeSharingIntentTypeFromQueue:(HSSharingIntentType)type;
- (BOOL)hasSharingIntentsPending;
- (HSSharingIntentType)getNextSharingIntentType;

- (void)addGeneralSharingIntentType:(HSSharingIntentType)type;
- (void)removeGeneralSharingIntentType:(HSSharingIntentType)type;

- (NSString *)keyForSharingIntentType:(HSSharingIntentType)type;
- (HSSharingIntentType)getSharingIntentTypeFromSocialNetworkType:(HSSocialNetworkType)socialType;

/* logging */
- (NSString *)getDescriptionFromSocialNetworkType:(HSSocialNetworkType)socialType;

@property (nonatomic, assign) BOOL isNoSelection;

@end
