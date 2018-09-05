//
//  ProfessionalInfoCell.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/2/13.
//
//

#import <UIKit/UIKit.h>
#import "ProtocolsDef.h"

@interface ProfessionalInfoCell : UITableViewCell

@property (strong, nonatomic)ProfessionalDO * professional;
@property (weak, nonatomic) id<ProfessionalInfoCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *contactDetailsContainer;
@property (weak, nonatomic) IBOutlet UIImageView *profCoverImage;
@property (weak, nonatomic) IBOutlet UIImageView *profAvatarImage;
@property (weak, nonatomic) IBOutlet UILabel *profName;
@property (weak, nonatomic) IBOutlet UILabel *profProfessions;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButtonLiked;
@property (weak, nonatomic) IBOutlet UILabel *followsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *profDescription;
@property (weak, nonatomic) IBOutlet UIButton *moreDescriptionButton;
@property (weak, nonatomic) IBOutlet UIView *descriptionContainer;
@property (weak, nonatomic) UIButton *clickMoreButton;
@property (weak, nonatomic) IBOutlet UIButton *contactDetailsButton;
@property (strong, nonatomic) IBOutlet UIView *profInfoView;
@property (nonatomic, assign) BOOL isLiked;

- (void)initWithProf:(ProfessionalDO*)prof;
- (IBAction)followProfessionalAction:(id)sender;
- (IBAction)getFullDescriptionAction:(id)sender;
- (IBAction)getProfContactDetails:(id)sender;
- (void)toggleLikeBtn;

@end
