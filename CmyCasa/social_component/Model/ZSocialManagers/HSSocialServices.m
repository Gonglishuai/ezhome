//
//  HSSocialServices.m
//
//  Created by Stav Ashuri on 12/2/12.
//  Copyright (c) 2012 Stav Ashuri. All rights reserved.
//

#import "HSSocialServices.h"


//#import "FBSBJSON.h"
//#import "FBFriend.h"

#import <Social/Social.h>
#import <Accounts/Accounts.h>



#define kFacebookSDKJsonResponseKey @"com.facebook.sdk:ParsedJSONResponseKey"
#define KFacebookLoginRetriesMax 2

//Error handling
//Taken from https://developers.facebook.com/docs/reference/api/errors/
#define kFacebookSDKErrorCodeOAuthError 190
#define kFacebookSDKErrorSubcodeAppNotInstalled 458
#define kFacebookSDKErrorSubcodeUserCheckpointed 459
#define kFacebookSDKErrorSubcodePasswordChanged 460
#define kFacebookSDKErrorSubcodeExpired 463
#define kFacebookSDKErrorSubcodeUnconfirmedUser 464
#define kFacebookErrorUserInfoKeyBody    @"body"
#define kFacebookErrorUserInfoKeyError   @"error"
#define kFacebookErrorUserInfoKeyCode    @"code"
#define kFacebookErrorUserInfoKeySubCode @"error_subcode"

//Dialogs
#define kFacebookDialogURLReturnKeyPostId @"post_id"

//Post dialog
#define kFacebookPostParamLink          @"link"
#define kFacebookPostParamPictureUrl    @"picture"
#define kFacebookPostParamName          @"name"
#define kFacebookPostParamCaption       @"caption"
#define kFacebookPostParamDescription   @"description"
#define kFacebookPostParamMessage       @"message"

//Feed dialog
#define kFacebookFeedDialogParamName @"name"
#define kFacebookFeedDialogParamCaption @"caption"
#define kFacebookFeedDialogParamDescription @"description"
#define kFacebookFeedDialogParamLink @"link"
#define kFacebookFeedDialogParamPicture @"picture"
#define kFacebookFeedDialogParamTo @"to"
#define kFacebookFeedDialogName @"feed"
#define kFacebookFeedDialogAppId @"app_id"

//Invite Parameters
#define kFacebookInviteParamMessage     @"message"
#define kFacebookInviteParamTo          @"to"
#define kFacebookInviteDialogName       @"apprequests"

//FQL
#define kFacebookFQLGetFriendsQuery @"SELECT uid, name, pic_square FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me())"
#define kFacebookFQLGetFriendQuery @"SELECT uid, name, pic_square FROM user WHERE uid = %@"
#define kFacebookFQLGetProfileImageUrlQuery @"SELECT uid, pic_big FROM user WHERE uid = me()"
#define kFacebookFQLResponseKeyData @"data"
#define kFacebookFQLResponseKeyLargePic @"pic_big"

@interface HSSocialServices() <NSCoding>
{
    FacebookInviteCompletionBlock inviteCompletionBlock;
    SocialPostFailBlock inviteFailBlock;
    FBGraphUser *userinfo;
    
    dispatch_queue_t backgroundQueue;
}

@property (strong, nonatomic) NSArray *cachedFacebookFriends;
@property (strong, nonatomic) NSArray *cachedFBFriends;
@property (strong, nonatomic) FacebookFeedDialogPostCompletionBlock pendingFacebookPostCompletionBlock;
@property (strong, nonatomic) SocialPostFailBlock pendingFacebookPostFailBlock;

@property (assign ,nonatomic) int numberOfFacebookRetries;

@end

@implementation HSSocialServices

@synthesize numberOfFacebookRetries;

#pragma mark - NSObject

- (id)init
{
    self = [super init];
    if (self)
    {        
        backgroundQueue = dispatch_queue_create(kSocialManagerBackgroundQueueName, NULL);
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setters

-(void) setTwitterEnabled:(BOOL)twitterEnabled
{
    [self saveToDisk];
}

#pragma mark - Private

- (BOOL)validBlocks:(id)block1 :(id)block2 {
    if (block1 && block2) {
        return YES;
    }
    return NO;
}


#pragma mark - Private (Facebook)
/**
 * Helper method for parsing URL parameters.
 */
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [[kv objectAtIndex:1]
         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}

-(BOOL)isValidString:(NSString*)stringToValidate {
    if (stringToValidate && !([stringToValidate isEqualToString:@""]) ) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Public (Facebook)
- (void)showFacebookError:(BOOL) shouldNotify andMessage:(NSString*) message
{
    NSString *localMessage;
    if(message != nil)
    {
        localMessage = message;
    }
    else
    {
        localMessage = NSLocalizedString(@"facebook_login_general_error", @"");
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                        message:localMessage
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
    [alertView show];
}

- (ACAccount*)ios6AccountFacebookAccount
{
    return nil;
}

-(void)fbResyncWithPermissions:(NSArray*)permissions WithComplition:(void (^)(BOOL granted, NSError *e))complitionBlock;
{
    ACAccountStore *accountStore;
    ACAccountType *accountTypeFB;
    if ((accountStore = [[ACAccountStore alloc] init]) && (accountTypeFB = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook] ) ){
        
        NSArray *fbAccounts = [accountStore accountsWithAccountType:accountTypeFB];
        id account;
        if (fbAccounts && [fbAccounts count] > 0 && (account = [fbAccounts objectAtIndex:0]))
        {
            [accountStore renewCredentialsForAccount:account completion:^(ACAccountCredentialRenewResult renewResult, NSError *error)
             {
                
             //try to request permisisons again
             NSDictionary *options = @{
                                  ACFacebookAppIdKey: @"303518951099",
                            ACFacebookPermissionsKey: permissions,
                               ACFacebookAudienceKey: ACFacebookAudienceFriends
             };
             
             [accountStore requestAccessToAccountsWithType:accountTypeFB
                                                   options:options completion:^(BOOL granted, NSError *e)
              {
                  if(complitionBlock != nil)
                  {
                      dispatch_async(dispatch_get_main_queue(), ^
                                     {
                                            complitionBlock(granted ,e);
                                     });
                  }
              }];
             
            }];
        }
    }
}

- (void)cleanCache
{
    self.cachedFacebookFriends = nil;
}

#pragma mark - NSCoding
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (self)
    {
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
}

#define kSocialManagerFileName @"socialManagerData"
+ (NSString *) socialNetworkFilePath
{
    return [NSString stringWithFormat:@"%@/%@", [HSSocialServices getPrivateDocsDir], kSocialManagerFileName];
}

+ (BOOL) socialFileExists
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[HSSocialServices socialNetworkFilePath]];
}

+ (NSString *)getPrivateDocsDir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"Private Documents"];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    
    //Handle Error?
    if (error == nil)
        return documentsDirectory;
    else
        return nil;
}

- (void) saveToDisk
{
    NSString * filePath = [HSSocialServices socialNetworkFilePath];
    
    if (![HSSocialServices socialFileExists])
    {
        if (![[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil])
        {
        }
    }
    
    if ([NSKeyedArchiver archiveRootObject:self toFile:filePath]== NO)
    {
    }
}


@end
