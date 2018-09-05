//
//  GalleryImageItemInfoCell.m
//  Homestyler
//
//  Created by Eric Dong on 05/04/2018.
//

#import "GalleryImageItemInfoCell.h"
#import "GalleryImageViewController.h"

#import "NotificationNames.h"

#import "DesignBaseClass.h"

#import "ImageFetcher.h"

#import "UIImage+Exif.h"
#import "UIImageView+LoadImage.h"
#import "UIImageView+ViewMasking.h"
#import "UILabel+NUI.h"
#import "UILabel+Size.h"
#import "UIView+ReloadUI.h"


static const CGFloat GalleryImageItem_MARGIN_IPAD = 50;
static const CGFloat GalleryImageItem_MARGIN_IPHONE = 20;
static const CGFloat GalleryImageItem_IMAGE_ASPECT_RATIO_IPAD = 9.0 / 16.0;
static const CGFloat GalleryImageItem_IMAGE_ASPECT_RATIO_IPHONE = 3.0 / 4.0;

@implementation GalleryImageItemInfoCell
{
    CGSize _designImageViewSize;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    _designImage.userInteractionEnabled = YES;

    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapOnImage:)];
    [_designImage addGestureRecognizer:tapRecognizer];

    CGFloat margin = IS_IPAD ? GalleryImageItem_MARGIN_IPAD : GalleryImageItem_MARGIN_IPHONE;
    CGFloat designImageWidth = [UIScreen mainScreen].bounds.size.width - 2 * margin;
    CGFloat designImageAspect = IS_IPAD ? GalleryImageItem_IMAGE_ASPECT_RATIO_IPAD : GalleryImageItem_IMAGE_ASPECT_RATIO_IPHONE;
    _designImageViewSize = CGSizeMake(designImageWidth, designImageWidth * designImageAspect);

    [self reloadUI];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)prepareForReuse
{
    [super prepareForReuse];

    [self resetUI];
}

-(void)resetUI {
    _itemDetail = nil;
    _designTitle.text = @"";

    _designImage.image = nil;
}

- (void)singleTapOnImage:(id)sender {
    if (_delegate != nil && [_delegate respondsToSelector:@selector(showFullDesignImage:)]) {
        [_delegate showFullDesignImage:_itemDetail];
    }
}

-(void)initData:(DesignBaseClass*)itemDetail
{
    _itemDetail = itemDetail;
    if (_itemDetail == nil)
        return;

    _designTitle.text=_itemDetail.title;

    [self loadBackgroundImageFromCacheOnly];
}

-(void)getFullImage{

    MyDesignDO * mdesign = (MyDesignDO *)_itemDetail;
    if (mdesign.eSaveDesignStatus == SAVED_DESIGN_STATUS_AUTOSAVE) {
        SavedDesign * autoDesign = [[DesignsManager sharedInstance] workingDesign];

        _designImage.image = autoDesign.image;
        if (self.parentTableHolder)
            self.parentTableHolder.mainDesignImage.image = autoDesign.image;

        return;
    }

    NSString * url = _itemDetail.url;
    CGRect rect = self.parentTableHolder.mainDesignImage.bounds;

    //load design image
    CGSize designSize = rect.size;

    NSValue *valSize = [NSValue valueWithCGSize:designSize];
    NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (url)?url:@"",
                          IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                          IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                          IMAGE_FETCHER_INFO_KEY_LOAD_IMAGE_EXIF : @"YES",
                          IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : _designImage};

    NSInteger lastUid = -1;
    lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
               {
                   NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:_designImage];

                   if (currentUid == uid)
                   {
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          if (self.parentTableHolder)
                                          {
                                              self.parentTableHolder.mainDesignImage.image = image;
                                          }
                                      });
                   }
               }];
}

-(void)loadBackgroundImageFromCacheOnly{
    if (_itemDetail.eSaveDesignStatus == SAVED_DESIGN_STATUS_AUTOSAVE) {
        SavedDesign * autoDesign = [[DesignsManager sharedInstance] workingDesign];
        _designImage.image = autoDesign.image;
        if (self.parentTableHolder)
            self.parentTableHolder.mainDesignImage.image = autoDesign.image;

        return;
    }

    __weak typeof(self) weakSelf = self;
    [_designImage loadImageFromUrl:_itemDetail.url withSize:_designImageViewSize defaultImage:nil animated:YES completion:^(UIImage *image, NSInteger uid, NSDictionary* imageMeta) {
        if (image != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.parentTableHolder) {
                    weakSelf.parentTableHolder.mainDesignImage.image = image;
                }
            });
        }
    }];
}

@end
