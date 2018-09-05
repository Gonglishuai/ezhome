//
//  TableRecordBaseCell.h
//  Homestyler
//
//  Created by Berenson Sergei on 12/18/13.
//
//

#import <UIKit/UIKit.h>
#import "ProfilePageBaseViewController.h"

#define NAME_CHAR_LIMIT 18
#define WEB_SITE_LINK_LIMIT 255
#define LOCATION_LINK_LIMIT 255
#define DESCRIPTION_LIMIT 140
#define RECORD_TITLE_COLOR ([UIColor colorWithRed:113.0f/255.f green:113.0f/255.f blue:113.0f/255.f alpha:1.0f])
#define RECORD_TITLE_COLOR_IPHONE ([UIColor colorWithRed:114.0f/255.f green:114.0f/255.f blue:114.0f/255.f alpha:1.0f])

#define RECORD_PLACEHOLDER_TITLE_COLOR ([UIColor colorWithRed:188.0f/255.f green:187.0f/255.f blue:193.0f/255.f alpha:1.0f])

@class UserDO;
@protocol ProfileUserDetailsDelegate;

@interface TableRecordBaseCell : UITableViewCell<ProfileCellUnifiedInitProtocol,UITextFieldDelegate,UITextViewDelegate, UIAlertViewDelegate>


@property(nonatomic, weak) id<ProfileUserDetailsDelegate> profileDetailsDelegate ;

@property (weak, nonatomic) IBOutlet UILabel *recordTitle;
@property (weak, nonatomic) IBOutlet UIImageView *recordIcon;
@property(nonatomic,retain) id inputValue;
@property(nonatomic,readwrite) UserDetailFieldType inputType;

@property(nonatomic,readonly)BOOL canPeformAction;
@property(nonatomic,readonly) BOOL isEditing;

@property(nonatomic) UserViewField comboType;

@property(nonatomic, strong) NSDictionary *dictData;

-(void)initCellWithData:(NSDictionary*)data;
-(void)startEditMode;
-(void)stopEditMode;
-(void)performAction;

- (NSString *)getPlaceHolderMessageForField;

- (NSString *)cutTextToReachLimitForField:(NSString *)text andType:(UserViewField)type;

-(void)configEditMode:(BOOL)status;

-(BOOL)validateInputLimitForField:(NSString *)field andType:(UserViewField)type;
@end
