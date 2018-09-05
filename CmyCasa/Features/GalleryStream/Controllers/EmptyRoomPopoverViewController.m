//
//  EmptyRoomPopoverViewController.m
//  Homestyler
//
//  Created by xiefei on 14/5/18.
//

#import "EmptyRoomPopoverViewController.h"
#import "ProgressPopupBaseViewController.h"

#import "UIImageView+LoadImage.h"

#import "ImageFetcher.h"

#define EMPTYROOM_IMAGEVIEW_WIDTH                   ([UIScreen mainScreen].bounds.size.width - 24)
#define EMPTYROOM_IMAGEVIEW_HEIGHT                  (9.00/16.00 * EMPTYROOM_IMAGEVIEW_WIDTH)
#define EMPTYROOM_IMAGEVIEW_UNTIL_BOTTOM            (EMPTYROOM_IMAGEVIEW_HEIGHT + 110)

@interface EmptyRoomPopoverViewController ()
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UIImageView *emptyRoomImageView;
@property (weak, nonatomic) IBOutlet UILabel *emptyRoomTitle;
@property (weak, nonatomic) IBOutlet UIButton *designBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emptyRoomLayout;
@end

@implementation EmptyRoomPopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setEmptyRoomInfo];
    [self getEmptyRoomImage];
}

-(void)setEmptyRoomInfo {
    [self.designBtn setTitle:NSLocalizedString(@"start_design", @"") forState:UIControlStateNormal];
    
    UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(comeBack)];
    [self.shadowView addGestureRecognizer:tap];
    UIPanGestureRecognizer *rap = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(comeBack)];
    [self.shadowView addGestureRecognizer:rap];
    
    self.emptyRoomTitle.text = self.itemDetail.title;
    
    self.emptyRoomLayout.constant = -EMPTYROOM_IMAGEVIEW_UNTIL_BOTTOM;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self customAnimation:YES];
}

-(void)customAnimation:(BOOL)isDisplay {
    self.emptyRoomLayout.constant = isDisplay ? 0 : -self.emptyView.bounds.size.height ;
    NSLog(@"%f",self.emptyRoomLayout.constant);
    [UIView animateWithDuration:0.35f delay:0.0f usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.shadowView.alpha = isDisplay ? 0.5 : 0.0;
        self.emptyView.alpha = isDisplay ? 1.0 : 0.0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (!isDisplay) {
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }];
}

-(void)getEmptyRoomImage {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGSize designSize = CGSizeMake(EMPTYROOM_IMAGEVIEW_WIDTH, EMPTYROOM_IMAGEVIEW_HEIGHT);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [self.emptyRoomImageView loadImageFromUrl:self.itemDetail.url withSize:designSize defaultImage:nil animated:YES completion:^(UIImage *image, NSInteger uid, NSDictionary *imageMeta) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }];
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)comeBack {
    [self customAnimation:NO];
}

- (IBAction)design:(id)sender {
    
    if (![ConfigManager isAnyNetworkAvailableOrOffline]) {
        [ConfigManager showMessageIfDisconnected];
        return;
    }

    [[ProgressPopupBaseViewController sharedInstance] stopLoading];

    NSString* strDesign = [self getItemContent];

    if (![NSString notEmpty:strDesign]) {
        self.itemDetailsPrivateURLNeeded = [self.itemDetail isDesignBelongsToLoggedInUser];

        [[ProgressPopupBaseViewController sharedInstance] startLoading:self];

        [self loadItemDetailFromServer:^(BOOL status) {
            if (status) {
                [self performSelectorOnMainThread:@selector(design:) withObject:self.itemDetail waitUntilDone:NO];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{

                    [[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"failed_load_models", @"We couldn't load the design")
                                              delegate:nil
                                     cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"")
                                     otherButtonTitles: nil] show];

                });
            }
        }];

        return;
    }

    if ([self.itemDetail isKindOfClass:[MyDesignDO class]]) {
        MyDesignDO * md = (MyDesignDO*)self.itemDetail;
        if (md.eSaveDesignStatus == SAVED_DESIGN_STATUS_AUTOSAVE) {

            SavedDesign* designData = [[DesignsManager sharedInstance] workingDesign];

            GalleryItemDO * gido = (GalleryItemDO*)md;

            [self validateRedesignImages:designData.originalImage background:designData.image mask:designData.maskImage needMask:designData.maskImage == Nil ];

            [[UIManager sharedInstance] galleryDesignSelected:designData withOriginalDesign:gido  withOriginEvent:EVENT_PARAM_VAL_LOAD_ORIGIN_REDESIGN];

        } else {
            [self prepareDesignData:self.itemDetail];
        }

    } else {
        [self prepareDesignData:self.itemDetail];
    }
}



- (void)prepareDesignData:(DesignBaseClass *)designInfo {
    NSString* strDesign = [self getItemContent];
    
    if ([strDesign length ] == 0) {
        [self getMyItemDetail];
        return;
    }
    
    if ([[self getItemItself] isUpdateRequeredForRedesign]) {
        UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@""
                                                      message:NSLocalizedString(@"redesign_json_newer_alert", @"")
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"alert_view_dont_remind", @"") otherButtonTitles: NSLocalizedString(@"Update Now", @"Update"),nil];
        [alert show];
        return;
    }
    
    SavedDesign* designData = [SavedDesign designWithJSONString:strDesign];
    
    if (designData == nil) {
        UIImage * image = [self getCurrentPresentingImage];
        designData = [SavedDesign initWithImage:image
                                  imageMetadata:nil
                                 devicePosition:nil
                            originalOrientation:image.imageOrientation];
    }
    
    [designData updateLockingStateAccordingToDesignType:1];
    
    //get design id
    
    if ([designInfo isDesignBelongsToLoggedInUser]) {
        designData.designID=[self getItemID];
        
        designData.designDescription=[self getDesignDescription];
        designData.designRoomType=[self getRoomType];
        designData.name=[self getDesignTitle];
    }
    
    BOOL bUpdateParent = ![designData.UniqueID isEqualToString:[self getItemID]];
    BOOL bUpdateParent2 = ![designData.designID isEqualToString:[self getItemID]];
    
    if (bUpdateParent && bUpdateParent2) {
        designData.parentID = [self getItemID];
    }
    
    if ([designInfo isPublicOrPublished]) {
        designData.publicDesignID=[self getItemID];
    }
    
    if ([[self getItemItself] isDesignPublished] || [designInfo isDesignBelongsToLoggedInUser]==NO) {
        designData.mustSaveAsNewDesign=YES;
    }
    
    GalleryItemDO * gido = (GalleryItemDO*)designInfo;
    
    [[UIManager sharedInstance] galleryDesignSelected:designData
                                   withOriginalDesign:gido
                                      withOriginEvent:EVENT_PARAM_VAL_LOAD_ORIGIN_REDESIGN];
    [self getFullImages];
}

//Used for new ImageFetcher
-(void)getFullImages{
    
    NSString * bgImgURL = [self getBGImageURL];
    NSString * origImgURL = [self getOrigImageURL];
    __block NSString * maskImgURL = [self getMaskImageURL];
    
    __block UIImage * imgBG = nil;
    __block UIImage * origImg = nil;
    __block UIImage * maskImg = nil;
    
    NSValue *valSize = [NSValue valueWithCGSize:CGSizeZero];
    NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (bgImgURL)?bgImgURL:@"",
                          IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                          IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                          IMAGE_FETCHER_INFO_KEY_URL_FORMATING:IMAGE_FETCHER_INFO_KEY_URL_FORMATING_NO_RESIZING};
    
    [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
     {
         
         dispatch_async(dispatch_get_main_queue(), ^
                        {
                            BOOL maskExist = !(maskImgURL!=nil && maskImg==nil);
                            
                            imgBG = image;
                            [self validateRedesignImages:origImg background:imgBG mask:maskImg needMask:maskExist ];
                        });
     }];
    
    dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (origImgURL)?origImgURL:@"",
            IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
            IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
            IMAGE_FETCHER_INFO_KEY_URL_FORMATING:IMAGE_FETCHER_INFO_KEY_URL_FORMATING_NO_RESIZING};
    
    
    [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
     {
         dispatch_async(dispatch_get_main_queue(), ^
                        {
                            origImg = image;
                            BOOL maskExist = !(maskImgURL!=nil && maskImg==nil);
                            
                            
                            [self validateRedesignImages:origImg background:imgBG mask:maskImg needMask:maskExist ];
                        });
     }];
    
    
    dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (maskImgURL)?maskImgURL:@"",
            IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
            IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
            IMAGE_FETCHER_INFO_KEY_URL_FORMATING:IMAGE_FETCHER_INFO_KEY_URL_FORMATING_NO_RESIZING};
    
    
    [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             maskImg = image;
             //clear maskUrl if returned image is null, so that other images could finish normaly
             if (image==nil) {
                 maskImgURL=nil;
             }
             [self validateRedesignImages:origImg background:imgBG mask:maskImg needMask:YES ];
         });
     }];
}

-(void)validateRedesignImages:(UIImage *)original background:(UIImage *)background mask:(UIImage *)mask needMask:(BOOL)needMask {
    if ([_delegate respondsToSelector:@selector(startRedesignImages:background:mask:needMask:)]) {
        [_delegate startRedesignImages:original background:background mask:mask needMask:needMask];
    }
}

@end
