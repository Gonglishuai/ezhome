//
//  SaveDesignBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/6/13.
//
//

#import <UIKit/UIKit.h>

@class RoomTypeDO;

@interface SaveDesignBaseViewController : UIViewController<PopoverDelegate, UITextViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>
{
    @protected
    NSString*             _selectedRoomTypeKey;
    NSString*             _descriptionInitText;
    UIColor*              _descriptionTextColor;
}

- (IBAction)savePressed:(id)sender;
- (IBAction)cancelPressed:(id)sender;
- (void)refreshSaveDialog;
- (void)handleMissingRoomType;
- (void)changeRoomTypeBtnTitle:(NSString*)newTitle;
- (void)updateRoomTypeBtnTitle:(SavedDesign*)savedDesign;


@property (strong, nonatomic) NSArray* roomTypesArr;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UILabel *lblSaveDesignTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UILabel *lblSwitchTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblRoomType;
@property (weak, nonatomic) IBOutlet UITextView *descriptionView;
@property (weak, nonatomic) IBOutlet UISwitch *publicSwitch;
@property (weak, nonatomic) IBOutlet UILabel *publicLabel;
@property (weak, nonatomic) IBOutlet UITextField *titleText;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (nonatomic, weak) IBOutlet UILabel *errorLabelSelectRoom;
@property (weak, nonatomic) IBOutlet UIButton *selectRoomBtn;

@property(nonatomic, weak) id<SaveDesignPopupDelegate> designDelegate;

@end
