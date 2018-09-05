//
//  FindFriendCell.h
//  Homestyler
//
//  Created by Berenson Sergei on 8/7/13.
//
//

#import <UIKit/UIKit.h>
#import "HSNUIIconLabelButton.h"

@class UserBaseFriendDO;

@protocol FindFriendActionsDelegate <NSObject>

-(void)findFriendPerfomAction:(UserBaseFriendDO*)bfriend;
-(void)findFriendProfileClickAction:(UserBaseFriendDO*)bfriend;

@end

@interface FindFriendCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *fullName;
@property (weak, nonatomic) IBOutlet UILabel *notHsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (strong, nonatomic) HSNUIIconLabelButton *actionButton;
@property (nonatomic,strong) UserBaseFriendDO * mfriend;
@property (nonatomic, weak) id<FindFriendActionsDelegate> delegate;

-(IBAction)activatedAction:(id)sender;
-(IBAction)profileImageClicked:(id)sender;
-(void)initWithFriendData:(UserBaseFriendDO*)bfriend;

@end
