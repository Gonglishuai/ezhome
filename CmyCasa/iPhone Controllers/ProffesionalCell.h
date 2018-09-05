//
//  ProffesionalCell.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/25/13.
//
//

#import <UIKit/UIKit.h>

@interface ProffesionalCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profImage;
@property (weak, nonatomic) IBOutlet UILabel *profDescription;
@property (weak, nonatomic) IBOutlet UILabel *profProfessions;
@property (weak, nonatomic) IBOutlet UILabel *LikesCount;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property(nonatomic)ProfessionalDO * myProf;
-(void)initWithProf:(ProfessionalDO*)prof;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;


@end
