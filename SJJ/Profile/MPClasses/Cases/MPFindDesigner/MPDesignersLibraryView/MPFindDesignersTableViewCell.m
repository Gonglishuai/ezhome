/**
 * @file    MPFindDesignersTableViewCell.m
 * @brief   the view for cell.
 * @author  Xue
 * @version 1.0
 * @date    2016-02-17
 */

#import "MPFindDesignersTableViewCell.h"
#import "MPDesignerInfoModel.h"
#import "UIImageView+WebCache.h"


@interface MPFindDesignersTableViewCell()

/// liang fang price.
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

/// designer name.
@property (weak, nonatomic) IBOutlet UILabel *designerNameLabel;

/// Number of works.
@property (weak, nonatomic) IBOutlet UILabel *workLabel;

/// Good at style.
@property (weak, nonatomic) IBOutlet UILabel *skillLabel;

/// show head image.
@property (weak, nonatomic) IBOutlet UIImageView *headerImageview;

/// show authentication.
@property (weak, nonatomic) IBOutlet UIImageView *VimageView;
@property (weak, nonatomic) IBOutlet UILabel *attentionCountLabel;

/// the index for model in datasource.
@property (assign, nonatomic) NSUInteger index;

//价格label的高度约束值，根据用户角色进行改变，使当是设计师的时候保持上下居中
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *priceLabelHeightConstraint;


@end
@implementation MPFindDesignersTableViewCell


-(void) updateCellForIndex:(NSUInteger) index
{
    if ([self.delegate respondsToSelector:@selector(getDesignerLibraryModelForIndex:)])
    {
        [self.contentView bringSubviewToFront:self.VimageView];
        self.index = index;
        MPDesignerInfoModel *model = [self.delegate getDesignerLibraryModelForIndex:self.index];
        
//        self.layer.masksToBounds = YES;
//        self.layer.cornerRadius = 5.0f;
        
        NSString *url = @"";
        if (![model.avatar isEqualToString:@""]) {
            url = [NSString stringWithFormat:@"%@",model.avatar];
        }
        [self.headerImageview sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:ICON_HEADER_DEFAULT]];
        
        if ([model.designer.is_real_name intValue]== 2) {
            self.VimageView.image = [UIImage imageNamed:VERIFIED_V];//已认证
        } else {
            self.VimageView.image = [UIImage imageNamed:@""];
        }

        NSString *design_budget;
        if (([[model.designer.design_price_min description] rangeOfString:@"null"].length == 4 || model.designer.design_price_min == nil)) {
            design_budget = @"尚未填写";
        } else {
            design_budget = [NSString stringWithFormat:@"%ld-%ld%@",
                             (long)model.designer.design_price_min.integerValue,
                             (long)model.designer.design_price_max.integerValue,
                             @"元/㎡"];
        }
        
        self.priceLabel.text = design_budget;
        self.attentionCountLabel.text = [NSString stringWithFormat:@"关注人数 : %@",(model.follows == nil)?@(0):model.follows];
//        self.attentionCountLabel.hidden = YES;
        
        NSString * designName =  (model.nick_name == nil)?model.first_name:model.nick_name;
        
        if (designName.length > 8) {
            designName = [[designName substringToIndex:8] stringByAppendingString:@"..."];
        }
        self.designerNameLabel.text = designName;

        
        NSString *works = [NSString stringWithFormat:@"%@ %@",
                           @"作品 :",
                           (model.designer.case_count == nil)?@(0):model.designer.case_count];
        self.workLabel.text = works;
        
        NSString *stylesStr = model.designer.style_names;
        NSArray *arrStyles = [stylesStr componentsSeparatedByString:@" "];
        if (arrStyles.count >= 3)
        {
            stylesStr = [NSString stringWithFormat:@"%@ %@ %@...",arrStyles[0],arrStyles[1],arrStyles[2]];
        }
        NSString *stilledStr = [NSString stringWithFormat:@"%@ %@",
                                @"擅长 :",
                                (model.designer.style_names == nil)?@"其他":stylesStr];
        self.skillLabel.text = stilledStr;
        
        if ([SHAppGlobal AppGlobal_GetIsDesignerMode] && SCREEN_WIDTH <= 320 + 1)
        {
            
            NSString *designPrice = self.priceLabel.text;
            NSRange range = [designPrice rangeOfString:@"元"];
            if (range.length != 0)
            {
                designPrice = [NSString stringWithFormat:@"%@\n元%@",
                               [designPrice substringToIndex:range.location],
                               [designPrice substringFromIndex:range.location + range.length]];
                self.priceLabel.text = designPrice;
            }
        }
        
        [self.priceLabel layoutIfNeeded];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.headerImageview.layer.masksToBounds = YES;
    self.headerImageview.layer.cornerRadius = (92.0f*SCREEN_SCALE-31)*0.5;
}

@end
