//
//  CoCaseImageCell.m
//  Consumer
//
//  Created by Jiao on 16/7/20.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "CoCaseImageCell.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD+NJ.h"

@interface CoCaseImageCell()<UIGestureRecognizerDelegate,UIScrollViewDelegate,UIActionSheetDelegate>
{
    NSUInteger photoIndex;
}
@property (nonatomic, strong) NSArray *caseImageArray;

@end
@implementation CoCaseImageCell
{
    __weak IBOutlet UIImageView *_caseImageView;
    UIImageView * caseImgView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _caseImageView.contentMode = UIViewContentModeScaleAspectFill;
    _caseImageView.clipsToBounds = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoClick:)];
    [_caseImageView addGestureRecognizer:tap];
}

- (NSArray *)caseImageArray{
    if(_caseImageArray == nil){
        if([self.delegate respondsToSelector:@selector(getCaseArr)]){
            _caseImageArray = [self.delegate getCaseArr];
        }
    }
    return _caseImageArray;
}

- (void) updateCellForSection:(NSInteger)section withIndex:(NSUInteger)index {
    
    if ([self.delegate respondsToSelector:@selector(getCaseLibraryDetailModelForSection:withIndex:)]) {

        NSString *image = [self.delegate getCaseLibraryDetailModelForSection:section withIndex:index];
//        image = [NSString stringWithFormat:@"%@HD.jpg", image];
        _caseImageView.userInteractionEnabled = YES;
        
        [_caseImageView sd_setImageWithURL:[NSURL URLWithString:image] placeholderImage:[UIImage imageNamed:HOUSE_DEFAULT_IMAGE]];
        
        // get the photo index in the caseImageArray
        photoIndex = [self.caseImageArray indexOfObject:image];
    }
}


-(void)photoClick:(UITapGestureRecognizer *)tap
{
    if([self.delegate respondsToSelector:@selector(caseImageCellDidSelectedPhoto:imageView:photoIndex:)])
    {
        if ([tap.view isKindOfClass:[UIImageView class]])
        {
            [self.delegate caseImageCellDidSelectedPhoto:self
                                               imageView:(UIImageView *)tap.view
                                              photoIndex:photoIndex];
        }
    }
}


@end
