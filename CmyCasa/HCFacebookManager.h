//
//  HCFacebookManager.h
//  CmyCasa
//
//  Created by Berenson Sergei on 1/31/13.
//
//

#import <Foundation/Foundation.h>
#import "SocialFriendDO.h"
#import "UIManager.h"
#import "HSSocialServices.h"
//#import <FBSDKCoreKit/FBSDKCoreKit.h>
//#import <FBSDKLoginKit/FBSDKLoginKit.h>

typedef void(^LoginBlock)(BOOL status);

@interface HCFacebookManager : NSObject


@property (nonatomic)BOOL isFacebookSignup;
@property (nonatomic,strong) NSMutableArray * facebookFriendsList;

+ (instancetype)sharedInstance;

-(void)populateUserDetails;

-(void)loginWithHomestylerAfterFBLogin;

-(BOOL)isFacebookSessionOpen;

-(void)clearUserInfo;

-(void)facebookLikeDesign:(NSString*)designId
                  andType:(NSString*)dtype
      withCompletionBlock:(HSCompletionBlock)completion
                    queue:(dispatch_queue_t)queue;




@end
