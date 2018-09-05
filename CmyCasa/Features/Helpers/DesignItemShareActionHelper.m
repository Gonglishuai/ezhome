//
//  DesignItemShareActionHelper.m
//  Homestyler
//
//  Created by Dong Shuyu on 04/10/18.
//
//

#import "DesignItemShareActionHelper.h"

#import "ConfigManager.h"
#import "GalleryStreamManager.h"
#import "UserManager.h"

#import "HSSharingConstants.h"
#import "HSSharingLogic.h"
#import "WCSharingViewController.h"

//#import "HSFlurry.h"

#import "NSObject+MultiShare.h"

@interface DesignItemShareActionHelper () <HSSharingViewControllerDelegate, MFMailComposeViewControllerDelegate>
{
    BOOL _isShareViewDisplay;
}
@property (nonatomic, weak) DesignBaseClass * design;
@property (nonatomic, strong) HSSharingViewController *sharingViewController;
@property (nonatomic, weak) UIViewController * hostViewController;
@property (nonatomic, weak) id<HSSharingViewControllerDelegate> sharingDelegate;
@end

@implementation DesignItemShareActionHelper

- (void)shareDesign:(nonnull DesignBaseClass *)design withDesignImage:(nonnull UIImage *)designImage fromViewController:(nonnull UIViewController *)hostViewController withDelegate:(id <HSSharingViewControllerDelegate>)sharingDelegate loadOrigin:(NSString *)loadOrigin {
    if (![ConfigManager isAnyNetworkAvailable]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ConfigManager showMessageIfDisconnected];
        });
        return;
    }

    if (designImage == nil)
        return;

    self.hostViewController = hostViewController;
    self.sharingDelegate = sharingDelegate;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        dispatch_sync(dispatch_get_main_queue(), ^{

//            [HSFlurry logAnalyticEvent:EVENT_NAME_SHARE_UI_OPEN withParameters:@{EVENT_PARAM_UI_ORIGIN:loadOrigin}];

            DesignBaseClass* designData = design;
            NSLog(@"current sharing item id %@", designData._id);
            GalleryItemDO *item = [[[AppCore sharedInstance] getGalleryManager] getGalleryItemByItemID:designData._id];
            NSString *strType = [self stringFromItemType:[item type]];
            NSString *linkUrl = [[ConfigManager sharedInstance] generateShareUrl:strType:designData._id];
            NSString *shareMessage = designData.title;

            NSLog(@"current sharing link url %@", linkUrl);

            HSShareObject * obj = [HSSharingLogic generateShareObject:designImage andDesignUrl:linkUrl andMessage:shareMessage withHashTags:[NSMutableArray array]];

            //provide image url from server
            if (designData.url) {
                obj.pictureURL = [NSURL URLWithString:designData.url];
            }
            if (designData._description) {
                obj._description = designData._description;
            }
            [self startSharingProccessWithMessage:obj];
        });
    });
}

#pragma mark NSObject + MultiShare Override
- (void)doShareWithText:(HSShareObject*)shareObj {
    if ([ConfigManager isWhiteLabel]) {
        [self shareByEmail:shareObj];
    } else if ([ConfigManager isWeChatActive]) {
        WCSharingViewController* wcController = [[WCSharingViewController alloc] initWithShareData:shareObj];
        [wcController enterSharingView:self.hostViewController];
    } else {
        if (IS_IPAD) {
            if (!_isShareViewDisplay) {
                self.sharingViewController = [[HSSharingViewController alloc] initWithShareText:shareObj];
                self.sharingViewController.delegate = self;

                _isShareViewDisplay = YES;
                [self.hostViewController.view addSubview:self.sharingViewController.view];
                [self.hostViewController addChildViewController:self.sharingViewController];
            }
        } else {
            if (!self.hostViewController.presentedViewController) {
                self.sharingViewController = [[HSSharingViewController alloc] initWithShareText:shareObj];
                self.sharingViewController.delegate = self;

                [self.hostViewController presentViewController:self.sharingViewController animated:YES completion:nil];
            }
        }
    }
}

- (void)shareByEmail:(HSShareObject*)shareObj {
    if ([MFMailComposeViewController canSendMail]) {
        HSSharingLogic *logic = [[HSSharingLogic alloc] initWithText:shareObj];
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
        [composeViewController setMailComposeDelegate:self];
        [composeViewController setSubject:[NSString stringWithFormat:NSLocalizedString(kHSSharingViewControllerMailSubject, nil), [ConfigManager getAppName]]];
        [composeViewController setMessageBody:[NSString stringWithFormat:@"%@", [logic getSharingTextForEmail]] isHTML:NO];
        [composeViewController addAttachmentData:UIImagePNGRepresentation(shareObj.picture) mimeType:@"image/png" fileName:[shareObj.pictureURL absoluteString]];
        [self.hostViewController presentViewController:composeViewController animated:YES completion:nil];
    } else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"Failed to send mail" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    BOOL isSharing = NO;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            isSharing = YES;
            break;
        case MFMailComposeResultFailed:
            break;
    }

    [self.hostViewController dismissViewControllerAnimated:YES completion:^{
        if (isSharing) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"Mail has been sent" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        } else {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"Failed to send mail" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
    }];
}

- (void)removeSharingViewController {
    if (IS_IPAD) {
        [self.sharingViewController.view removeFromSuperview];
        [self.sharingViewController removeFromParentViewController];
    } else {
        [self.hostViewController dismissViewControllerAnimated:YES completion:nil];
    }
    self.sharingViewController = nil;
    _isShareViewDisplay = NO;
}


#pragma mark - NSObject + MultiShare override

- (void)didStartPreparingForShare {
}

- (void)didFinishPreparingForShare {
}


#pragma mark - HSSharingViewControllerDelegate

- (void)didCancelSharingViewController {
    [self removeSharingViewController];
    if (self.sharingDelegate != nil && [self.sharingDelegate respondsToSelector:@selector(didCancelSharingViewController)]) {
        [self.sharingDelegate didCancelSharingViewController];
    }
}

- (void)didFinishSharingViewController {
    [self removeSharingViewController];
    if (self.sharingDelegate != nil && [self.sharingDelegate respondsToSelector:@selector(didFinishSharingViewController)]) {
        [self.sharingDelegate didFinishSharingViewController];
    }
}

@end

