//
//  ProfessionalInfoCell.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/2/13.
//
//

#import "ProfessionalInfoCell.h"
#import "UILabel+Size.h"
#import "ImageFetcher.h"
#import "UIImageView+ViewMasking.h"
#import "UIView+Alignment.h"
#import "UILabel+NUI.h"

@implementation ProfessionalInfoCell

-(void)initWithProf:(ProfessionalDO*)prof{
    self.professional = prof;

    self.isLiked = [self.professional isFollowedByUser];
    if (self.isLiked)
    {
        [self setLike:YES];
    }
    else
    {
        [self setLike:NO];
    }
    
    [self.profAvatarImage setMaskToCircleWithBorderWidth:0.1 andColor:[UIColor clearColor]];
    
    [self.moreDescriptionButton alignWithView:self.profDescription type:eAlignmentBottom];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if ([prof isExtraInfoLoaded]) {
        [self fillProfessionalInfo];
    }
}

- (IBAction)followProfessionalAction:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(changeFollowStatusForProfessional)]) {
        [self.likeButtonLiked setEnabled:NO];
        [self.likeButton setEnabled:NO];


        // do not update ui if user not loged in
        if ([[UserManager sharedInstance] isLoggedIn]) {
            
            int count = [[self.professional likesCount] intValue];
            NSLog(@"count from professional %d", count);
            if (!self.isLiked) {
                self.followsCountLabel.text= [NSString stringWithFormat:@"%d", count + 1];
            }else{
                self.followsCountLabel.text= [NSString stringWithFormat:@"%d", count - 1];
            }
            
            //[self toggleLikeBtn];
            [self sendAnalitics];
        }
        
        [self.delegate performSelector:@selector(changeFollowStatusForProfessional) withObject:nil];
    }
}

-(void)sendAnalitics{
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
        NSArray * objs = [NSArray arrayWithObjects:self.professional._id,[NSNumber numberWithBool:self.isLiked], nil];
        NSArray * keys = [NSArray arrayWithObjects:@"prof_id",@"follow_status", nil];
//        [HSFlurry logEvent:FLURRY_PROFESIONAL_FOLLOW withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
    }
#endif
}

- (IBAction)getFullDescriptionAction:(id)sender {
    
    if (self.moreDescriptionButton.tag==10) {
        self.moreDescriptionButton.tag=0;
    
        [sender setTitle:NSLocalizedString(@"prof_desc_more", @"") forState:UIControlStateNormal];
        
        CGSize size = [self.profDescription getActualTextHeightForLabel:10000];
        self.profDescription.numberOfLines=3;
        
        int newDelta=size.height-53;
        
        if (size.height>53) {
            
            CGRect rect= self.profDescription.frame;
            rect.size.height=53;
            self.profDescription.frame=rect;
            
            //move down rest of the controls.
            
            rect=self.moreDescriptionButton.frame;
            rect.origin.y-=newDelta;
            self.moreDescriptionButton.frame=rect;
            
            //move description container
            rect=self.descriptionContainer.frame;
            rect.size.height-=newDelta;
            self.descriptionContainer.frame=rect;
            
            //move contacts view
            rect=self.contactDetailsContainer.frame;
            rect.origin.y-=newDelta;
            self.contactDetailsContainer.frame=rect;
            
            if ([self.delegate respondsToSelector:@selector(changeFirstCellHeight:)]) {
                [self.delegate performSelector:@selector(changeFirstCellHeight:) withObject:[NSNumber numberWithFloat:self.frame.size.height-newDelta]];
            }
        }
    }else{
        self.moreDescriptionButton.tag=10;
        [sender setTitle:NSLocalizedString(@"prof_desc_collapse", @"") forState:UIControlStateNormal];
        
        self.profDescription.numberOfLines=0;
        
        CGSize size = [self.profDescription getActualTextHeightForLabel:10000];
        
        if (size.height>self.profDescription.frame.size.height) {
            int newDelta=size.height-self.profDescription.frame.size.height;
            
            
            CGRect rect= self.profDescription.frame;
            rect.size.height=size.height;
            self.profDescription.frame=rect;
            
            //move down rest of the controls.
            
            rect=self.moreDescriptionButton.frame;
            rect.origin.y+=newDelta;
            self.moreDescriptionButton.frame=rect;
            
            //move description container
            rect=self.descriptionContainer.frame;
            rect.size.height+=newDelta;
            self.descriptionContainer.frame=rect;
           
            //move contacts view
            rect=self.contactDetailsContainer.frame;
            rect.origin.y+=newDelta;
            self.contactDetailsContainer.frame=rect;
            
            if ([self.delegate respondsToSelector:@selector(changeFirstCellHeight:)]) {
                [self.delegate performSelector:@selector(changeFirstCellHeight:) withObject:[NSNumber numberWithFloat:self.frame.size.height+newDelta]];
            }
        }
    }
    
    [sender alignWithView:self.profDescription type:eAlignmentBottom];
}

- (IBAction)getProfContactDetails:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(openProfessionalDetails)]) {
        [self.delegate  performSelector:@selector(openProfessionalDetails) withObject:nil];
    }
}

-(void)fillProfessionalInfo{
    
    NSString* name = [NSString stringWithFormat:@"%@ %@", self.professional.firstName, self.professional.lastName];
    
    self.profName.text=name;
    
    CGSize  sz=[self.profName getActualTextHeightForLabel:44];
    
    self.profName.frame=CGRectMake(self.profName.frame.origin.x,
                                          self.profName.frame.origin.y,
                                          self.profName.frame.size.width,
                                          sz.height);
    
    self.profDescription.text=self.professional._description;
    
    NSString * profs=@"";
    for (int i=0;i<[self.professional.professions count];i++)
    {
        if (i==0) {
            profs=[self.professional.professions objectAtIndex:i];
        }else
            profs=[NSString stringWithFormat:@"%@, %@",profs,[self.professional.professions objectAtIndex:i]];
    }
    
    
    self.profProfessions.text=profs;
    
    sz = [self.profProfessions getActualTextHeightForLabel:44];
    
    self.profProfessions.frame=CGRectMake(self.profProfessions.frame.origin.x,
                                          self.profName.frame.origin.y+self.profName.frame.size.height,
                                          self.profProfessions.frame.size.width,
                                          sz.height);
    
    
    
    
    self.followsCountLabel.text=[NSString stringWithFormat:@"%d", [[self.professional likesCount] intValue]];
    
    //load design image
    CGSize designSize = self.profAvatarImage.frame.size;
    NSValue *valSize = [NSValue valueWithCGSize:designSize];
    NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL:  (self.professional.userPhoto)?self.professional.userPhoto:@"",
                          IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                          IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                          IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.profAvatarImage};
    
    NSInteger lastUid = -1;
    lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
               {
                   NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.profAvatarImage];
                   
                   if (currentUid == uid)
                   {
                       dispatch_async(dispatch_get_main_queue(),
                                      ^{
                                          self.profAvatarImage.image = image;

                                      });
                   }
               }];

    designSize = self.profCoverImage.frame.size;
    valSize = [NSValue valueWithCGSize:designSize];
    dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL:  (self.professional.posterImage)?self.professional.posterImage:@"",
            IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
            IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
            IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.profCoverImage};

    lastUid = -1;
    lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
    {
        NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.profCoverImage];

        if (currentUid == uid)
        {
            dispatch_async(dispatch_get_main_queue(),
                         ^{
            self.profCoverImage.image = image;
                          });
        }
    }];
}

-(void)setLike:(BOOL)isLiked
{
    if (isLiked)
    {
        self.likeButtonLiked.hidden = NO;
        self.likeButton.hidden = YES;
    }
    else
    {
        self.likeButtonLiked.hidden = YES;
        self.likeButton.hidden = NO;

    }
   
}

- (void)toggleLikeBtn
{
    self.isLiked = !self.isLiked;
    
    self.likeButtonLiked.hidden = !self.isLiked;
    self.likeButton.hidden = self.isLiked;
}

@end
