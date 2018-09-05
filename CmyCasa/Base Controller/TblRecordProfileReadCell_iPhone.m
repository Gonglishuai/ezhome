//
//  TblRecordProfileReadCell_iPhone.m
//  Homestyler
//
//  Created by Berenson Sergei on 1/8/14.
//
//

#import "TblRecordProfileReadCell_iPhone.h"
#import "NSString+Contains.h"
#import "ProfileUserDetailsBaseViewController.h"
#import "ImageFetcher.h"
#import "UIImageView+ViewMasking.h"

@implementation TblRecordProfileReadCell_iPhone

- (id)init
{

   self = [[NSBundle mainBundle] loadNibNamed:@"RecordProfileReadCell_iPhone" owner:self options:nil][0];
       
    self.selectionStyle=UITableViewCellSelectionStyleNone;
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)initCellWithData:(NSDictionary *)data{
    [super initCellWithData:data];
    
    
    [self.profileImage setMaskToCircleWithBorderWidth:0.f andColor:[UIColor clearColor]];

    NSDictionary  * values=[data objectForKey:USER_DETAIL_ROW_TYPE_VALUE];
    if (values) {
        
        if ([values objectForKey:@"profession"]) {
            self.tblLabelProfession.text=[values objectForKey:@"profession"];
        }else
            self.tblLabelProfession.text=@"";
        
        if ([values objectForKey:@"image"] && ![NSString isNullOrEmpty:[values objectForKey:@"image"]]) {
            CGSize designSize = self.profileImage.frame.size;
            NSValue *valSize = [NSValue valueWithCGSize:designSize];
            NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL:[values objectForKey:@"image"],
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
                                                  if (image) {
                                                      self.profileImage.image = image;
                                                  }else{
                                                        self.profileImage.image=[UIImage imageNamed:@"user_avatar"];
                                                  }
                                                  
                                              });
                           }
                       }];
        }else{
            self.profileImage.image=[UIImage imageNamed:@"user_avatar"];
        }
        
        if ([values objectForKey:@"fullname"]) {
            self.tblLabelName.text=[values objectForKey:@"fullname"];
        }
    }
    
   
}

-(void)initWithData:(id)data andDelegate:(id)delegate andProfileUserType:(ProfileUserType)profileType{
    [self initCellWithData:data];
}

@end



