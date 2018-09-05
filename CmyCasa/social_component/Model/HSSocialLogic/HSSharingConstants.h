//
//  HSSharingConstants.h
//  ADSharingComponent
//
//  Created by Ma'ayan on 10/10/13.
//  Copyright (c) 2013 Ma'ayan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
	HSSocialNetworkTypeTwitter = 4100,
    HSSocialNetworkTypeFacebook = 4101,
} HSSocialNetworkType;

typedef enum
{
    HSSharingIntentTypeNone         = 3101,
    HSSharingIntentTypeFacebook     = 3102,
	HSSharingIntentTypeTwitter      = 3103,
    HSSharingIntentTypeEmail        = 3104,
} HSSharingIntentType;


typedef enum
{
    HSSharingFailNoEmailAccount = 5101,
    HSSharingFail               = 5102,
	HSSharingFailEmailCancelled = 5103,
} HSSharingErrorType;

//Comfort
#define IS_IPHONE_5                                 (!IS_IPAD && [UIScreen currentScreenBoundsDependOnOrientation].size.height == 568.0f)

//Xib
#define kHSSharingViewControllerXibNameiPhone       @"HSSharingViewController_iPhone"
#define kHSSharingViewControllerXibNameiPad         @"HSSharingViewController_iPad"

#pragma mark - View Controllers
//HSSHaringViewController
#define kHSSharingViewControlleriPhone5BackgroundImage      @"iph_5_multi_share_bg_new@2x.png"

#define kHSSharingViewControllerTitleButtonCancel           @"multi_share_cancel_btn"
#define kHSSharingViewControllerTitleButtonShare            @"multi_share_share_btn"
#define kHSSharingViewControllerTitleLabelTitle             @"multi_share_share_title"

#define kHSSharingViewControllerAlertNoData                 @"failed_action_no_network_found_start"
#define kHSSharingViewControllerAlertNoPhoto                @"multi_share_nophoto_msg"
#define kHSSharingViewControllerAlertTooMuchCharacters      @"multi_share_charlimit_msg"
#define kHSSharingViewControllerAlertSharingFailedGeneric   @"multi_share_fail_msg_first_part"
#define kHSSharingViewControllerAlertSharingFailedEmail     @"multi_share_fail_email_msg"
#define kHSSharingViewControllerAlertConfigureEmail         @"multi_share_configure_email_msg"
#define kHSSharingViewControllerMailSubject                 @"multi_share_email_subject"

#define kHSSharingViewControllerAlertTwitterLogin           @"multi_share_twitter_login_msg"

//HSSHaringLogic
#define kHSSharingLogicSNTypeDescriptionNone                @"multi_share_fail_msg_part_2_none"
#define kHSSharingLogicSNTypeDescriptionFacebook            @"multi_share_fail_msg_part_2_fb"
#define kHSSharingLogicSNTypeDescriptionTwitter             @"multi_share_fail_msg_part_2_twitter"









