//
//  TblRecordProfileImageCell.m
//  Homestyler
//
//  Created by Berenson Sergei on 12/18/13.
//
//


#import "TblRecordProfileImageCell.h"
#import "NSString+Contains.h"
#import "ProfileUserDetailsViewController_iPad.h"
#import "ImageFetcher.h"
#import "UIImageView+ViewMasking.h"
#import "UIView+Effects.h"

#define kButtonOffset 8
#define kImageBorderColor [UIColor colorWithRed:151.f/255.f green:151.f/255.f blue:151.f/255.f alpha:1.f]

@implementation TblRecordProfileImageCell

- (id)init
{
    if (IS_IPAD) {
        self = [[NSBundle mainBundle] loadNibNamed:@"RecordProfileImageCell_iPad" owner:self options:nil][0];
    }else{
        self = [[NSBundle mainBundle] loadNibNamed:@"RecordProfileImageCell_iPhone" owner:self options:nil][0];
    }
    
    //Change the user image and the camera icon to a circle view
    [self.profileImageView setMaskToCircleWithBorderWidth:1.0f andColor:kImageBorderColor];
    [self.cameraButtonIcon strokeWithWidth:0.0f cornerRadius:MIN(self.cameraButtonIcon.frame.size.width, self.cameraButtonIcon.frame.size.height) / 2 color:[UIColor clearColor]];

    [self.signOutButton setTitle:NSLocalizedString(@"user_profile_signout_lbl", @"Sign Out") forState:UIControlStateNormal];
    [self.changeImageButton setTitle:NSLocalizedString(@"Change_Profile_Image_btn_title", @"Change Profile Image") forState:UIControlStateNormal];
    [self.changePassButton setTitle:NSLocalizedString(@"Change_Password_btn_title", @"Change Password") forState:UIControlStateNormal];
    [self.changeImageButton sizeToFit];
    [self.changePassButton sizeToFit];
    
    //Set the buttons on the screen
    //CGRect frame = self.separatorLine.frame;
    //frame.origin.x = self.changeImageButton.frame.origin.x + self.changeImageButton.frame.size.width + kButtonOffset;
    //self.separatorLine.frame = frame;
    
    //frame = self.changePassButton.frame;
    //frame.origin.x = self.separatorLine.frame.origin.x + self.separatorLine.frame.size.width + kButtonOffset;
    //self.changePassButton.frame = frame;

    [self setBackgroundColor:[UIColor clearColor]];
     self.selectionStyle=UITableViewCellSelectionStyleNone;

    return self;
}

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

    // Configure the view for the selected state
}

-(void)initCellWithData:(NSDictionary*)data{
    [super initCellWithData:data];
    //clear previos editing state
    if (self.isEditing) {
        [self startEditMode];
    }else{
        [self stopEditMode];
        
    }
    
    if ([data objectForKey:USER_DETAIL_ROW_TYPE_VALUE ]) {
        
        NSString *path=[data objectForKey:USER_DETAIL_ROW_TYPE_VALUE ];
        UIImage * img=[data objectForKey:USER_DETAIL_TEMP_IMAGE];
        
        
        
        if ([NSString isNullOrEmpty:path] && [img isEqual:[NSNull null]]) {
            self.profileImageView.image=[UIImage imageNamed:@"user_avatar"];
        
        }else if ([img isEqual:[NSNull null]]==false) {
            self.profileImageView.image=img;
        }else 

            if(![NSString isNullOrEmpty:path]){
        
            if ([path rangeOfString:@"graph.facebook.com/"].location!=NSNotFound &&
                [path rangeOfString:@"?type=large"].location==NSNotFound)
            {
                path = [NSString stringWithFormat:@"%@?type=large",path];
            }
            
            CGSize designSize = self.profileImageView.frame.size;
            NSValue *valSize = [NSValue valueWithCGSize:designSize];
            NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL:path,
                                  IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                                  IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                                  IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.profileImageView};
            
            NSInteger lastUid = -1;
            lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
                       {
                           NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.profileImageView];
                           
                           if (currentUid == uid)
                           {
                               dispatch_async(dispatch_get_main_queue(), ^
                                              {
                                                  if (image) {
                                                      self.profileImageView.image = image;
                                                  }else{
                                                      self.profileImageView.image=[UIImage imageNamed:@"user_avatar"];
                                                  }
                                                 
                                                  [self.profileImageView setMaskToCircleWithBorderWidth:1.0f andColor:kImageBorderColor];
                                              });
                           }
                       }];
            
        }
        
        [self.profileImageView setMaskToCircleWithBorderWidth:1.0f andColor:kImageBorderColor];
    }
    
    //For not email users fullname, description, password and photo can't be changed
    if ([data objectForKey:USER_TYPE_VALUE] && [[data objectForKey:USER_TYPE_VALUE] intValue]!=kUserTypeEmail
        && [[data objectForKey:USER_TYPE_VALUE] intValue]!=kUserTypePhone
        && self.comboType==kFieldProfileImage ) {
            self.changeImageButton.hidden=YES;
            self.changePassButton.hidden=YES;
            self.cameraButtonIcon.hidden = YES;
            self.cameraButtonBgView.hidden = YES;
        
    }else{
        self.changeImageButton.hidden=!self.isEditing;
        self.changePassButton.hidden= ![ConfigManager isSetPassWord];
        self.cameraButtonIcon.hidden = !self.isEditing;
        self.cameraButtonBgView.hidden = !self.isEditing;
    }
}

-(void)startEditMode{
    [super startEditMode];
 
}

-(void)stopEditMode{
    [super stopEditMode];
    
}

- (IBAction)changeProfileImageAction:(id)sender {
  
    if ([self.dictData objectForKey:USER_TYPE_VALUE] && [[self.dictData objectForKey:USER_TYPE_VALUE] intValue]!=kUserTypeEmail
        && [[self.dictData objectForKey:USER_TYPE_VALUE] intValue]!=kUserTypePhone
        && self.comboType==kFieldProfileImage) {
        //block photo editing for non email users
        
    }else{
        if (!self.isEditing) {
            return;
        }
        if (self.profileDetailsDelegate && [self.profileDetailsDelegate respondsToSelector:@selector(changeUserProfileImageRequestedForRect:)]) {
            
            [self.profileDetailsDelegate changeUserProfileImageRequestedForRect:self.profileImageView];
        }
    }
}

- (IBAction)signOutAction:(id)sender {
    
    if (self.profileDetailsDelegate && [self.profileDetailsDelegate respondsToSelector:@selector(signoutRequested)]) {
        [self.profileDetailsDelegate signoutRequested];
    }
}

- (IBAction)changePasswordAction:(id)sender {
    if (!self.isEditing) {
        return;
    }
    if (self.profileDetailsDelegate && [self.profileDetailsDelegate respondsToSelector:@selector(changePasswordRequested)]) {
        
        [self.profileDetailsDelegate changePasswordRequested];
    }
}
@end
