//
//  BannerCell.m
//  Homestyler
//
//  Created by xiefei on 1/11/17.
//

#import "BannerCell.h"
#import "ImageFetcher.h"
#import "UIImageView+WebCache.h"

@interface BannerCell()<UIPopoverPresentationControllerDelegate>
@property (strong,nonatomic)UIVisualEffectView *shadowView;
@property (copy,nonatomic)NSString *imageStr;
@end

@implementation BannerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self getBannerImage];
}

-(void)loadBannerImage:(NSString*)imageUrlStr{
    self.imageStr = imageUrlStr;
}

- (IBAction)btnClick:(id)sender {
    if (self.vc) {
        NSRange range = [self.bannerUrl rangeOfString:@"https"];
        NSString *url = [self.bannerUrl substringFromIndex:range.location];
        GenericWebViewBaseViewController * web = [[UIManager sharedInstance] createGenericWebBrowser:url];
        web.displayPortrait = YES;
        if (IS_IPHONE) {
            [self.vc.navigationController pushViewController:web animated:YES];
        }else{
            web.preferredContentSize = CGSizeMake(449, 550);
            web.modalPresentationStyle = UIModalPresentationPopover;
            web.popoverPresentationController.permittedArrowDirections = 0;
            web.popoverPresentationController.sourceView=self.vc.view;
            web.popoverPresentationController.sourceRect = CGRectMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2, 0 , 0);
            web.popoverPresentationController.delegate = self;
            [self.vc.view addSubview:self.shadowView];
            [self.vc presentViewController:web animated:YES completion:nil];
        }
#ifdef USE_FLURRY
//        [HSFlurry logAnalyticEvent:EVENT_BANNER_CLICKED withParameters:@{EVENT_ACTION_BANNER_NAME:url}];
#endif
    }
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController; {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.shadowView removeFromSuperview];
    });
}

-(UIVisualEffectView *)shadowView {
    if (_shadowView == nil) {
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _shadowView = [[UIVisualEffectView alloc] initWithEffect:blur];
        _shadowView.frame = self.vc.view.bounds;
    }
    return _shadowView;
}

-(void)getBannerImage {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.imageStr isEqualToString:@""]==false)
        {
            //load design image
            CGSize designSize = CGSizeMake(self.bannerImage.bounds.size.width, self.bannerImage.bounds.size.height);
            NSValue *valSize = [NSValue valueWithCGSize:designSize];
            NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL:(self.imageStr)?self.imageStr:@"",
                                  IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                                  IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                                  IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.bannerImage};
            
            NSInteger lastUid = -1;
            lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
                       {
                           NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.bannerImage];
                           
                           if (currentUid == uid)
                           {
                               dispatch_async(dispatch_get_main_queue(), ^
                                              {
                                                  if (image) {
                                                      self.bannerImage.image = image;
                                                  } else {
                                                      self.bannerImage.image = [UIImage imageNamed:(IS_IPAD ? @"banner_ipad" : @"banner_iphone")];
                                                  }
                                              });
                           }
                       }];
        }
    });
}

@end
