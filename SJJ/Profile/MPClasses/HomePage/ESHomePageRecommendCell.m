
#import "ESHomePageRecommendCell.h"
#import "UIImageView+WebCache.h"

@interface ESHomePageRecommendCell ()

@property (weak, nonatomic) IBOutlet UIView *firstBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *firstTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstDescLabel;
@property (weak, nonatomic) IBOutlet UIImageView *firstImageView;
@property (weak, nonatomic) IBOutlet UILabel *firstDesignStatusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *firstDesignerAvatarImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstImageViewBottomConstraint;// design 40, normal 10
@property (weak, nonatomic) IBOutlet UIView *firstDesignBackgroundView;

@property (weak, nonatomic) IBOutlet UIView *secondBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *secondImageView;
@property (weak, nonatomic) IBOutlet UILabel *secondTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondDescLabel;

@property (weak, nonatomic) IBOutlet UIView *thirdBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *thirdImageView;
@property (weak, nonatomic) IBOutlet UILabel *thirdTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdDescLabel;

@property (weak, nonatomic) IBOutlet UIView *fourthBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *fourthImageView;
@property (weak, nonatomic) IBOutlet UILabel *fourthTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *fourthDescLabel;

@end

@implementation ESHomePageRecommendCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    [self.firstBackgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(firstDidTapped)]];
    [self.secondBackgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(secondDidTapped)]];
    [self.thirdBackgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thirdDidTapped)]];
    [self.fourthBackgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fourthDidTapped)]];
    
    self.firstImageView.layer.masksToBounds = YES;
    self.firstImageView.layer.cornerRadius = 2.0f;
    self.secondImageView.layer.masksToBounds = YES;
    self.secondImageView.layer.cornerRadius = 2.0f;
    self.thirdImageView.layer.masksToBounds = YES;
    self.thirdImageView.layer.cornerRadius = 2.0f;
    self.fourthImageView.layer.masksToBounds = YES;
    self.fourthImageView.layer.cornerRadius = 2.0f;
    self.firstDesignerAvatarImageView.layer.masksToBounds = YES;
    self.firstDesignerAvatarImageView.layer.cornerRadius = CGRectGetWidth(self.firstDesignerAvatarImageView.frame)/2.0f;
}

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getRecommendInformation)])
    {
        NSArray *recommends = [self.cellDelegate getRecommendInformation];
        if (recommends
            && [recommends isKindOfClass:[NSArray class]])
        {
            for (NSInteger i = 0; i < recommends.count; i++)
            {
                NSDictionary *dict = recommends[i];
                if (!dict
                    || ![dict isKindOfClass:[NSDictionary class]])
                {
                    return;
                }
                NSString *title = @"";
                NSString *subTitle = @"";
                NSString *imageName = @"";
                BOOL isDesign = NO;
                if (dict[@"title"]
                    && [dict[@"title"] isKindOfClass:[NSString class]])
                {
                    title = dict[@"title"];
                }
                if (dict[@"subTitle"]
                    && [dict[@"subTitle"] isKindOfClass:[NSString class]])
                {
                    subTitle = dict[@"subTitle"];
                }
                if (dict[@"extend_dic"]
                    && [dict[@"extend_dic"] isKindOfClass:[NSDictionary class]]
                    && dict[@"extend_dic"][@"image"]
                    && [dict[@"extend_dic"][@"image"] isKindOfClass:[NSString class]])
                {
                    imageName = dict[@"extend_dic"][@"image"];
                }
                if (dict[@"operation_type"]
                    && [dict[@"operation_type"] isKindOfClass:[NSString class]]
                    && [dict[@"operation_type"] isEqualToString:@"DESIGN_DETAIL"])// 资源位跳转,是否是设计详情
                {
                    isDesign = YES;
                }
                
                switch (i)
                {
                    case 0:
                    {
                        if (isDesign)
                        {
                            self.firstDesignBackgroundView.hidden = NO;
                            self.firstImageViewBottomConstraint.constant = 40.0f;
                            
                            self.firstTitleLabel.text = @"我的装修项目";
                            self.firstImageView.image = [UIImage imageNamed:@"home_page_recommend_design_degault"];
                            
                            NSString *designName = @"";
                            NSString *designStatus = @"";
                            NSString *designerAvatar = @"";
                            if (dict[@"extend_dic"]
                                && [dict[@"extend_dic"] isKindOfClass:[NSDictionary class]])
                            {
                                NSDictionary *designInfo = dict[@"extend_dic"];
                                if (designInfo[@"title"]
                                    && [designInfo[@"title"] isKindOfClass:[NSString class]])
                                {
                                    designName = designInfo[@"title"];
                                }
                                if (designInfo[@"status"]
                                    && [designInfo[@"status"] isKindOfClass:[NSString class]])
                                {
                                    designStatus = designInfo[@"status"];
                                }
                                if (designInfo[@"designerAvatar"]
                                    && [designInfo[@"designerAvatar"] isKindOfClass:[NSString class]])
                                {
                                    designerAvatar = [NSString stringWithFormat:@"%@", designInfo[@"designerAvatar"]];
                                }
                            }
                            self.firstDescLabel.text = designName;
                            self.firstDesignStatusLabel.text = designStatus;
                            [self.firstDesignerAvatarImageView sd_setImageWithURL:[NSURL URLWithString:designerAvatar] placeholderImage:[UIImage imageNamed:ICON_HEADER_DEFAULT]];
                        }
                        else
                        {
                            self.firstDesignBackgroundView.hidden = YES;
                            self.firstImageViewBottomConstraint.constant = 20.0f;
                            
                            self.firstTitleLabel.text = title;
                            self.firstDescLabel.text = subTitle;
                            [self.firstImageView sd_setImageWithURL:[NSURL URLWithString:imageName] placeholderImage:[UIImage imageNamed:@"defaultPlaceholder"]];
                        }
                        break;
                    }
                    case 1:
                    {
                        self.secondTitleLabel.text = title;
                        self.secondDescLabel.text = subTitle;
                        [self.secondImageView sd_setImageWithURL:[NSURL URLWithString:imageName] placeholderImage:[UIImage imageNamed:@"defaultPlaceholder"]];
                        break;
                    }
                    case 2:
                    {
                        self.thirdTitleLabel.text = title;
                        self.thirdDescLabel.text = subTitle;
                        [self.thirdImageView sd_setImageWithURL:[NSURL URLWithString:imageName] placeholderImage:[UIImage imageNamed:@"defaultPlaceholder"]];
                        break;
                    }
                    case 3:
                    {
                        self.fourthTitleLabel.text = title;
                        self.fourthDescLabel.text = subTitle;
                        [self.fourthImageView sd_setImageWithURL:[NSURL URLWithString:imageName] placeholderImage:[UIImage imageNamed:@"defaultPlaceholder"]];
                        break;
                    }
                    default:
                        break;
                }
            }
        }
    }
}

#pragma mark - Tap Methods
- (void)firstDidTapped
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(recommendDidTappedWithType:)])
    {
        [self.cellDelegate recommendDidTappedWithType:ESHomePageRecommendTypeFirst];
    }
}

- (void)secondDidTapped
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(recommendDidTappedWithType:)])
    {
        [self.cellDelegate recommendDidTappedWithType:ESHomePageRecommendTypeSecond];
    }
}

- (void)thirdDidTapped
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(recommendDidTappedWithType:)])
    {
        [self.cellDelegate recommendDidTappedWithType:ESHomePageRecommendTypeThird];
    }
}

- (void)fourthDidTapped
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(recommendDidTappedWithType:)])
    {
        [self.cellDelegate recommendDidTappedWithType:ESHomePageRecommendTypeFourth];
    }
}

@end
