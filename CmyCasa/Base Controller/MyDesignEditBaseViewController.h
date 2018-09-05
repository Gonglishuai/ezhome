//
//  MyDesignEditBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/14/13.
//
//

#import <UIKit/UIKit.h>
#import "ProfileProtocols.h"



#import "ProtocolsDef.h"



typedef void (^ editDesignCompletionBlock)(NSString * designId, BOOL status);
typedef void (^ editDesignMetadataCompletionBlock)(DesignMetadata* metadata, BOOL status);

@interface MyDesignEditBaseViewController : UIViewController<UIAlertViewDelegate,UITextFieldDelegate,UITextViewDelegate>
{
    BOOL            bTextWasTouched;

    @protected
    NSCharacterSet *blockedCharacters;
}


@property(nonatomic) MyDesignDO * design;
@property (nonatomic, assign) id<MyDesignEditDelegate, ProfileCountersDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *designTitle;
@property (weak, nonatomic) IBOutlet UITextView *designDescription;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *notificationView;
@property (weak, nonatomic) IBOutlet UIImageView *errorIcon;
@property (weak, nonatomic) IBOutlet UIImageView *checkIcon;
@property (weak, nonatomic) IBOutlet UILabel *notificationLabel;
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *editDesignView;
@property (weak, nonatomic) IBOutlet UISwitch *designStatusSwith;
@property (weak, nonatomic) IBOutlet UILabel *isPublicLabel;

- (void)presentByParentViewController:(UIViewController*)parentViewController animated:(BOOL)animated completion:(void (^ __nullable)(void))completion;

- (void)setUserInteraction:(BOOL)isEnabled;
- (void)displayNotification:(BOOL)isError text:(NSString*)text;
- (void)deleteDesign;
- (void)finishDesignDuplicateAction:(NSString *)designId withStatus:(BOOL)status sender:(id)sender;
- (void)duplicateDesignInternal:(editDesignCompletionBlock)completion;
- (void)deleteDesignInternal:(editDesignCompletionBlock)completion;
- (void)saveDesignInternal:(editDesignMetadataCompletionBlock)completion;
- (void)loadDesignImage;
- (void)updateDesignStatus:(DesignStatus)status withCompletionBlock:(void(^)())completionBlock;
- (IBAction)duplicatePressed:(id)sender;
- (IBAction)deletePressed:(id)sender;
- (IBAction)savePressed:(id)sender;
- (IBAction)redesignPressed:(id)sender;
- (IBAction)cancelPressed:(id)sender;
- (void)startRedesignTool;

@end




