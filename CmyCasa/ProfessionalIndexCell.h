//
//  ProfessionalIndexCell.h
//  Homestyler
//
//  Created by Berenson Sergei on 7/8/13.
//
//

#import <UIKit/UIKit.h>

@interface ProfessionalIndexCell : UITableViewCell

- (void) setProfessional:(ProfessionalDO*) professional;

@property (nonatomic, assign) id<ProfessionalDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *professionLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;

@property(nonatomic) ProfessionalDO * myProfessional;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@end
