//
//  ProfessionalCell.m
//  Homestyler
//
//  Created by Yiftach Ringel on 20/06/13.
//
//

#import "ProfessionalCell.h"
#import "ImageFetcher.h"
#import "UIView+Effects.h"
@interface ProfessionalCell ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *professionLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewPortfolioLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewPortfolioIcon;

@property (strong, nonatomic) IBOutletCollection (UIImageView) NSArray *projectImages;

@end

@implementation ProfessionalCell


- (instancetype)init
{
    self = [super init];
    
    if (self) {
        NSString * nibName = IS_IPAD ? @"ProfessionalCell_iPad": @"ProfessionalCell";
        self = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil][0];
    }
 
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.viewPortfolioLabel.text = NSLocalizedString(@"professional_cell_view_protfolio", @"View Protfolio");
    [self.viewPortfolioLabel sizeToFit];
    
    if (IS_IPAD)
    {
        //726 is the edge of the last image in the cell
        self.viewPortfolioLabel.frame = CGRectMake(726 - self.viewPortfolioLabel.frame.size.width, self.viewPortfolioLabel.frame.origin.y, self.viewPortfolioLabel.frame.size.width, self.viewPortfolioLabel.frame.size.height);
        self.viewPortfolioIcon.frame = CGRectMake(self.viewPortfolioLabel.frame.origin.x - self.viewPortfolioIcon.frame.size.width, self.viewPortfolioIcon.frame.origin.y, self.viewPortfolioIcon.frame.size.width, self.viewPortfolioIcon.frame.size.height);
    }
    
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.profileImage.image = nil;
}

- (void)setProfessional:(ProfessionalDO *)professional
{
    _professional = professional;
    
    self.contentView.hidden = NO;
    
    if (professional != nil)
    {
        self.contentView.hidden = NO;
        self.profileImage.image = nil;
        
        CGSize designSize = self.profileImage.frame.size;
        NSValue *valSize = [NSValue valueWithCGSize:designSize];
        NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (professional.userPhoto)?professional.userPhoto:@"",
                              IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                              IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                              IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.profileImage};
        
        NSInteger lastUid = -1;
        lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
                   {
                       NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:_profileImage];
                       
                       if (currentUid == uid)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              _profileImage.image = image;
                                          });
                       }
                   }];
        
        self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", professional.firstName, professional.lastName];
        
        // Professions
        NSMutableString* professions = [NSMutableString new];
        for (NSInteger currProfession = 0; currProfession < self.professionLabel.numberOfLines; currProfession++)
        {
            if (currProfession < professional.professions.count)
            {
                NSString * curProfession = professional.professions[currProfession];
                if (!curProfession) {
                    [professions appendString:curProfession];
                }
            }
            [professions appendString:@"\n"];
        }
        
        if(professions.length > 0){
            NSString * res = [professions substringToIndex:professions.length-1];
            [professions setString:res];
        }
        
        self.professionLabel.text = professions;
        
        // Projects
        NSMutableArray * imageUrls = self.professional.imageAssets;
  
        // Set the images
        for (NSUInteger currImageIndex = 0; currImageIndex < self.projectImages.count; currImageIndex++)
        {
            // Clear old image
            UIImage * image = (UIImage*)[self.projectImages objectAtIndex:currImageIndex];
            if (image) {
                image = nil;
            }
            
            // Check if there's a new image
            if (currImageIndex < imageUrls.count)
            {
                    UIImageView *imageView = self.projectImages[currImageIndex];
                    CGSize designSize = imageView.frame.size;
                    NSValue *valSize = [NSValue valueWithCGSize:designSize];
                    NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL:( imageUrls[currImageIndex])? imageUrls[currImageIndex]:@"",
                                          IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                                          IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                                          IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : imageView};
                    
                    NSInteger lastUid = -1;
                    lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
                               {
                                   NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:imageView];
                                   
                                   if (currentUid == uid)
                                   {
                                       dispatch_async(dispatch_get_main_queue(), ^
                                                      {
                                                          imageView.image = image;
                                                      });
                                   }
                               }];
            }
        }
    }
}

- (IBAction)professionalPressed
{
    if (self.delegate) {
        [self.delegate professionalPressed:self.professional._id];
    }
}

- (void)initWithData:(id)data andDelegate:(id)delegate  andProfileUserType:(ProfileUserType)profileType
{
    [self setProfessional:data];
    self.delegate=delegate;
}

@end
