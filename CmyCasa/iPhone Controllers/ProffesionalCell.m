//
//  ProffesionalCell.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/25/13.
//
//

#import "ProffesionalCell.h"
#import "UILabel+Size.h"
#import "ImageFetcher.h"
#import "UIView+Alignment.h"
#import "UILabel+NUI.h"

@implementation ProffesionalCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.profImage.image = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self.backgroundImage setHighlighted:selected];
    // Configure the view for the selected state
}

-(void)initWithProf:(ProfessionalDO*)prof{
    
    if ([self.nameLabel respondsToSelector:@selector(applyNUI)]) {
        [self.nameLabel performSelector:@selector(applyNUI)];
    }
    
    if ([self.profProfessions respondsToSelector:@selector(applyNUI)]) {
        [self.profProfessions performSelector:@selector(applyNUI)];
    }

    
    self.myProf=prof;
    self.profImage.image=nil;
    [self.loadingIndicator startAnimating];
    self.profDescription.text=[prof _description];
    
    
    NSString* name = [NSString stringWithFormat:@"%@ %@", prof.firstName, prof.lastName];
    self.nameLabel.text = name;
    [self.nameLabel setNumberOfLines:0];
    CGSize sz= [self.nameLabel getActualTextHeightForLabel:40];
    
    self.nameLabel.frame = CGRectMake(self.nameLabel.frame.origin.x, self.nameLabel.frame.origin.y,
                                    self.nameLabel.frame.size.width, sz.height);
    
    [self.nameLabel alignWithView:self.profImage type:eAlignmentTop];
    
    NSString * profs=@"";
    for (int i=0;i<[prof.professions count];i++)
    {
        if (i==0) {
            profs=[prof.professions objectAtIndex:i];
        }else
            profs=[NSString stringWithFormat:@"%@, %@",profs,[prof.professions objectAtIndex:i]];
    }
    
    self.profProfessions.text=profs;

    [self.profProfessions setNumberOfLines:0];
    sz= [self.profProfessions getActualTextHeightForLabel:40];
    
    self.profProfessions.frame = CGRectMake(self.profProfessions.frame.origin.x, self.profProfessions.frame.origin.y,
                                          self.profProfessions.frame.size.width, sz.height);
    
    [self.nameLabel appendViewWithMargin:self.profProfessions type:eAppendBottom margin:5];

    //self.LikesCount.text=[NSString stringWithFormat:@"%d", [[prof likesCount] intValue]];
    //load design image
    CGSize designSize = self.profImage.frame.size;
    NSValue *valSize = [NSValue valueWithCGSize:designSize];
    NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL:  (prof.userPhoto)?prof.userPhoto:@"",
                          IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                          IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                          IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.profImage};
    
    NSInteger lastUid = -1;
    lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
               {
                   NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.profImage];
                   
                   if (currentUid == uid)
                   {
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {

                                          self.profImage.image = image;
                                          [self.loadingIndicator stopAnimating];
                                      });
                   }
            }];
}

@end
