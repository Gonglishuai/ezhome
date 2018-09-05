//
//  HSSharingLogic.m
//  ADSharingComponent
//
//  Created by Ma'ayan on 10/10/13.
//  Copyright (c) 2013 Ma'ayan. All rights reserved.
//

#import "HSSharingLogic.h"

#import "HSSharingPreferencesManager.h"

#import "HSSharingConstants.h"
#import "HSHashtag.h"

@interface HSSharingLogic ()

@property (nonatomic, strong) HSShareObject * shareObject;

//sharing queue
@property (nonatomic, strong) NSMutableDictionary *dicGeneralSharingIntents; //dic of NSNumber(HSSharingIntentType)
@property (nonatomic, strong) NSMutableDictionary *dicCurrentSharingIntents; //dic of NSNumber(HSSharingIntentType)

@end


@implementation HSSharingLogic

- (id)initWithText:(HSShareObject*)shareObj{
    self = [super init];
    
    if (self)
    {
        self.shareObject=shareObj;
        self.dicGeneralSharingIntents = [NSMutableDictionary dictionaryWithCapacity:4];
    }
    
    return self;
}

- (HSSocialNetworkType)getSocialNetworkTypeFromHashtagType:(HSHashtagType)hashtype{
    switch (hashtype)
    {
        case HSHashtagTypeFacebook:
            return HSSocialNetworkTypeFacebook;
            break;
        case HSHashtagTypeTwitter:
            return HSSocialNetworkTypeTwitter;
            break;
    }
}

#pragma mark - Sharing Texts
- (NSString *)getSharingText{
    return [self.shareObject getSharingMessage];
}

- (void)setSharingText:(NSString *)modifiedText{
    self.shareObject.message = modifiedText;
    self.shareObject.canComposeMessage=NO;
}

- (NSString *)getSharingTextWithHashtags
{
    //create hashtag prefix & suffix strings
    NSMutableString *strPrefix = [NSMutableString string];
    NSMutableString *strSuffix = [NSMutableString string];
    NSMutableArray *arrHashtagsProccessed = [NSMutableArray array];

    for (HSHashtag *hash in [self.shareObject.hashtags sortedArrayUsingSelector:@selector(compare:)])
    {
        BOOL isHashBeenProccessedBefore = NO;
        
        for (HSHashtag *prevHash in arrHashtagsProccessed)
        {
            if ([hash isEqual:prevHash])
            {
                isHashBeenProccessedBefore = YES;
                break;
            }
        }
        if (isHashBeenProccessedBefore)
        {
            continue;
        }
        else
        {
            [arrHashtagsProccessed addObject:hash];
        }
        
        if (hash.location == HSHashtagLocationStart  && [hash.text length]>0)
        {
            [strPrefix appendString:[NSString stringWithFormat:@" %@",hash.text]];
        }
        else if (hash.location == HSHashtagLocationEnd && [hash.text length]>0)
        {
            [strSuffix appendString:[NSString stringWithFormat:@" %@",hash.text]];
        }
    }
    
    NSString *strFull = [NSString stringWithFormat:@"%@%@%@",
                         ([strPrefix length]>0)?[NSString stringWithFormat:@"%@ ",strPrefix]:@"",
                         [self.shareObject getSharingMessage],
                         ([strSuffix length]>0)?[NSString stringWithFormat:@" %@",strSuffix]:@""];
    
    return strFull;
}

- (NSString *)getSharingTextForEmail{
    return [self getSharingText];
}

#pragma mark - User Sharing Preferences

- (NSDictionary *)getUserSharingPreferences
{
    return [[HSSharingPreferencesManager sharedSharingPreferencesManager] getSharingPreferences];
}

- (void)saveUserSharingPreferences
{
    [[HSSharingPreferencesManager sharedSharingPreferencesManager] saveSharingPreferences:[self.dicGeneralSharingIntents copy]];
}

#pragma mark - Sharing Queue

- (void)initCurrentSharingQueue
{
    self.dicCurrentSharingIntents = [self.dicGeneralSharingIntents mutableCopy];
}

- (void)clearSharingIntentQueue
{
    [self.dicCurrentSharingIntents removeAllObjects];
}

- (void)removeSharingIntentTypeFromQueue:(HSSharingIntentType)type
{
    [self.dicCurrentSharingIntents removeObjectForKey:[self keyForSharingIntentType:type]];
}

- (BOOL)hasSharingIntentsPending
{
    BOOL isPending = ([[self.dicCurrentSharingIntents allKeys] count] > 0);
    return isPending;
}

- (HSSharingIntentType)getNextSharingIntentType
{
    NSArray *arrIntents = [[self.dicCurrentSharingIntents allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    if (arrIntents.count > 0)
    {
        NSNumber *numIntent = [arrIntents objectAtIndex:0];
        return [numIntent intValue];
    }
    
    return HSSharingIntentTypeNone;
}

- (void)clearGeneralSharingIntentQueue
{
    [self.dicGeneralSharingIntents removeAllObjects];
}

- (void)addGeneralSharingIntentType:(HSSharingIntentType)type
{
    [self.dicGeneralSharingIntents setObject:@(YES) forKey:[self keyForSharingIntentType:type]];

    if (self.dicGeneralSharingIntents.count > 0) {
        self.isNoSelection = NO;
    }
}

- (void)removeGeneralSharingIntentType:(HSSharingIntentType)type
{
    [self.dicGeneralSharingIntents removeObjectForKey:[self keyForSharingIntentType:type]];
    
    if (self.dicGeneralSharingIntents.count == 0) {
        self.isNoSelection = YES;
    }
}

- (NSString *)keyForSharingIntentType:(HSSharingIntentType)type
{
    return [NSString stringWithFormat:@"%d", type];
}

- (HSSharingIntentType)getSharingIntentTypeFromSocialNetworkType:(HSSocialNetworkType)socialType
{
    HSSharingIntentType sharingType = HSSharingIntentTypeNone;
    
    switch (socialType) {
        case HSSocialNetworkTypeFacebook:
            sharingType = HSSharingIntentTypeFacebook;
            break;
        case HSSocialNetworkTypeTwitter:
            sharingType = HSSharingIntentTypeTwitter;
            break;
    }
    
    return sharingType;
}

#pragma mark - Logging
- (NSString *)getDescriptionFromSocialNetworkType:(HSSocialNetworkType)socialType
{
    NSString *sharingDescription = NSLocalizedString(kHSSharingLogicSNTypeDescriptionNone, nil);
    
    switch (socialType) {
        case HSSocialNetworkTypeFacebook:
            sharingDescription = NSLocalizedString(kHSSharingLogicSNTypeDescriptionFacebook, nil);
            break;
        case HSSocialNetworkTypeTwitter:
            sharingDescription = NSLocalizedString(kHSSharingLogicSNTypeDescriptionTwitter, nil);
            break;
    }
    
    return sharingDescription;
}

#pragma mark- SharingObjects
-(HSShareObject*)getCurrentShareObject{
    return self.shareObject;
}

+(HSShareObject*)generateShareObject:(UIImage*)picture
                        andDesignUrl:(NSString*)designUrl
                          andMessage:(NSString*)message
                        withHashTags:(NSArray*)hashtags
{
    HSShareObject * obj=[[HSShareObject alloc] init];
    obj.message=message;
    obj.picture=picture;
    obj.designShareLink=designUrl;
    obj.designShareLinkOriginal=designUrl;
    obj.hashtags=hashtags;
    return obj;
}


@end
