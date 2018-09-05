
#import "ESCaseFittingRoomHomeCell.h"
#import "UIImageView+WebCache.h"
#import "ESFittingSampleModel.h"

@interface ESCaseFittingRoomHomeCell ()

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *headerTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *headerSubTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UIImageView *midImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;

@end

@implementation ESCaseFittingRoomHomeCell
{
    NSInteger _index;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.headerImageView.layer.cornerRadius  = 6.0f;
    self.headerImageView.layer.masksToBounds = YES;
    [self.headerImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                                initWithTarget:self
                                                action:@selector(categoryEntryTap:)]];
    self.leftImageView.layer.cornerRadius    = 3.0f;
    self.leftImageView.layer.masksToBounds   = YES;
    self.leftImageView.layer.borderColor     = [UIColor stec_viewBackgroundColor].CGColor;
    self.leftImageView.layer.borderWidth     = 0.5f;

    [self.leftImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                              initWithTarget:self
                                              action:@selector(caseImageDidTapped:)]];
    self.midImageView.layer.cornerRadius     = 3.0f;
    self.midImageView.layer.masksToBounds    = YES;
    self.midImageView.layer.borderColor      = [UIColor stec_viewBackgroundColor].CGColor;
    self.midImageView.layer.borderWidth      = 0.5f;
    [self.midImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(caseImageDidTapped:)]];
    self.rightImageView.layer.cornerRadius   = 3.0f;
    self.rightImageView.layer.masksToBounds  = YES;
    self.rightImageView.layer.borderColor    = [UIColor stec_viewBackgroundColor].CGColor;
    self.rightImageView.layer.borderWidth    = 0.5f;
    [self.rightImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(caseImageDidTapped:)]];
    
    self.moreButton.layer.masksToBounds = YES;
    self.moreButton.layer.cornerRadius = CGRectGetHeight(self.moreButton.frame)/2.0f;
    self.moreButton.layer.borderColor = [UIColor stec_titleTextColor].CGColor;
    self.moreButton.layer.borderWidth = 0.5f;
}

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath
{
    _index = indexPath.row;
    
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getFittingRoomHomeCellDataWithIndexPath:)])
    {
        ESFittingSampleModel *model = [self.cellDelegate getFittingRoomHomeCellDataWithIndexPath:indexPath];
        if (![model isKindOfClass:[ESFittingSampleModel class]]
            || ![model.caseList isKindOfClass:[NSArray class]]
            || model.caseList.count <= 0)
        {
            return;
        }
        
        self.headerImageView.image = [ESMallAssets bundleImage:model.spaceimageName];
        self.headerIconImageView.image = [ESMallAssets bundleImage:model.spaceTitleIconName];
        
        // 主标题
        NSMutableAttributedString *attributedStringTitle = [[NSMutableAttributedString alloc] initWithString:model.spaceTitle attributes:@{NSKernAttributeName:@(6)}];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [attributedStringTitle addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [model.spaceTitle length])];
        self.headerTitleLabel.attributedText = attributedStringTitle;
        
        // 副标题
        NSMutableAttributedString *attributedStringSubTitle = [[NSMutableAttributedString alloc] initWithString:model.spaceSubTitle attributes:@{NSKernAttributeName:@(1)}];
        NSMutableParagraphStyle *subParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        [attributedStringSubTitle addAttribute:NSParagraphStyleAttributeName value:subParagraphStyle range:NSMakeRange(0, [model.spaceSubTitle length])];
        self.headerSubTitleLabel.attributedText = attributedStringSubTitle;

        for (NSInteger i =0; i < model.caseList.count; i++)
        {
            ESFittingCaseModel *caseModel = model.caseList[i];
            switch (i)
            {
                case 0:
                {
                    [self updateImageView:self.leftImageView
                                      url:caseModel.caseImgUrl];
                    break;
                }
                case 1:
                {
                    [self updateImageView:self.midImageView
                                      url:caseModel.caseImgUrl];
                    break;
                }
                case 2:
                {
                    [self updateImageView:self.rightImageView
                                      url:caseModel.caseImgUrl];
                    break;
                }
                default:
                    break;
            }
        }
    }
}

- (void)updateImageView:(UIImageView *)imageView url:(NSString *)url
{
    if (![imageView isKindOfClass:[UIImageView class]])
    {
        return;
    }
        
    if (!url
        || ![url isKindOfClass:[NSString class]]
        || url.length <= 0)
    {
        imageView.image = [UIImage imageNamed:@"HouseDefaultImage"];
        return;
    }
    
    [imageView sd_setImageWithURL:[NSURL URLWithString:url]
                 placeholderImage:[UIImage imageNamed:@"HouseDefaultImage"]];
}

#pragma mark - Button Click
- (IBAction)moreButtonDidTapped:(id)sender
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(categoryMoreDidTappedWithIndex:)])
    {
        [self.cellDelegate categoryMoreDidTappedWithIndex:_index];
    }
}

#pragma mark - Tap Methods
- (void)categoryEntryTap:(UITapGestureRecognizer *)tap {
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(categoryImageDidTappedWithIndex:)])
    {
        [self.cellDelegate categoryImageDidTappedWithIndex:_index];
    }
}

- (void)caseImageDidTapped:(UITapGestureRecognizer *)tap
{
    if ([tap isKindOfClass:[UITapGestureRecognizer class]])
    {
        NSInteger caseIndex = -1;
        if (tap.view == self.leftImageView)
        {
            caseIndex = 0;
        }
        else if (tap.view == self.midImageView)
        {
            caseIndex = 1;
        }
        else if (tap.view == self.rightImageView)
        {
            caseIndex = 2;
        }
        else
        {
            caseIndex = -1;
        }
        
        if (self.cellDelegate
            && [self.cellDelegate respondsToSelector:@selector(caseImageDidTappedWithIndex:caseIndex:)])
        {
            [self.cellDelegate caseImageDidTappedWithIndex:_index
                                                 caseIndex:caseIndex];
        }
    }
}

@end
