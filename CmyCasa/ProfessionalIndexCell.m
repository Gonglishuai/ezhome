//
//  ProfessionalIndexCell.m
//  Homestyler
//
//  Created by Berenson Sergei on 7/8/13.
//
//

#import "ProfessionalIndexCell.h"
#import "UILabel+Size.h"
#import "AppCore.h"
#import "NSString+ImageResizer.h"
#import "ImageFetcher.h"

@implementation ProfessionalIndexCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void) setProfessional:(ProfessionalDO*) professional {
    
    
    self.myProfessional=professional;
    
    NSString* name = [NSString stringWithFormat:@"%@ %@", professional.firstName, professional.lastName];
    self.nameLabel.text = name;
    self.nameLabel.accessibilityLabel = [NSString stringWithFormat:@"lbl_name_%@",name];
    self.lblDescription.accessibilityLabel = [NSString stringWithFormat:@"txt_description_%@",name];
    self.locationLabel.accessibilityLabel = [NSString stringWithFormat:@"lbl_locations_%@",name];
    self.professionLabel.accessibilityLabel = [NSString stringWithFormat:@"lbl_profession_%@",name];
    self.profileImage.accessibilityLabel = [NSString stringWithFormat:@"img_profile_%@",name];
    self.lblDescription.text =professional._description;
    
    NSArray* locs = professional.locations;
    NSString* locations = @"";
    for(NSString* location in locs) {
        locations = [locations stringByAppendingString:location];
        locations = [locations stringByAppendingString:@", "];
    }
    self.locationLabel.text = (locations.length > 0) ? [locations substringWithRange:NSMakeRange(0, locations.length - 2)] : @"";
    
    NSArray* profs =professional.professions;
    NSString* professions = @"";
    int profesionsCount = 0;
    for(NSString* profession in profs) {
        professions = [professions stringByAppendingString:profession];
        professions = [professions stringByAppendingString:@", "];
        profesionsCount++;
    }
    
    self.professionLabel.text = (professions.length > 0) ? [professions substringWithRange:NSMakeRange(0, professions.length - 2)] : @"";
    
    //load design image
    CGSize designSize = self.profileImage.frame.size;
    NSValue *valSize = [NSValue valueWithCGSize:designSize];
    NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL:  (professional.userPhoto)?professional.userPhoto:@"",
                          IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                          IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                          IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.profileImage};
    
    NSInteger lastUid = -1;
    lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
               {
                   NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.profileImage];
                   
                   if (currentUid == uid)
                   {
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          
                                          self.profileImage.image = image;
                                          [self.loadingIndicator stopAnimating];
                                      });
                   }
               }];
}

- (IBAction)viewPortfolioBtnPressed:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(professionalSelected:)]) {
        [self.delegate performSelector:@selector(professionalSelected:) withObject:self.myProfessional._id];
    }
}

@end
