
#import "MPDesignerDetailHeaderTableViewCell.h"
#import "ESDesignerInfoModel.h"
#import "UIImageView+WebCache.h"
#import "CoStringManager.h"

@interface MPDesignerDetailHeaderTableViewCell ()

/// icon imageView.
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
/// style.
@property (weak, nonatomic) IBOutlet UILabel *styleLabel;
/// diy count.
@property (weak, nonatomic) IBOutlet UILabel *diyCountLabel;
/// money information.
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
/// V imageView.
@property (weak, nonatomic) IBOutlet UIImageView *isRealImageView;
/// chat button.
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
/// choose button.
@property (weak, nonatomic) IBOutlet UIButton *chooseTaMeasure;

@property (weak, nonatomic) IBOutlet UIButton *chatButtonLong;
@end

@implementation MPDesignerDetailHeaderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.iconImageView.clipsToBounds = YES;
    self.iconImageView.layer.cornerRadius = 37.0f;
    self.chatButton.clipsToBounds = YES;
    self.chatButton.layer.cornerRadius = 4.0f;
    self.chatButtonLong.clipsToBounds = YES;
    self.chatButtonLong.layer.cornerRadius = 4.0f;
    self.chooseTaMeasure.clipsToBounds = YES;
    self.chooseTaMeasure.layer.cornerRadius = 4.0f;
    self.isRealImageView.hidden = YES;
    self.chatButton.backgroundColor = [UIColor stec_ableButtonBackColor];
    self.chooseTaMeasure.backgroundColor = [UIColor stec_ableButtonBackColor];
}

- (void)updateCellForIndex:(NSInteger)index isCenter:(BOOL)isCenter {
    if ([self.delegate respondsToSelector:@selector(getDesignerInfoModel)]) {
        self.chatButton.hidden = isCenter;
        self.chooseTaMeasure.hidden = isCenter;
        self.chatButtonLong.hidden = !isCenter;
        
        ESDesignerInfoModel *model      = [self.delegate getDesignerInfoModel];
        
        NSString *diyCounet;
        if (model.experience == nil) {
            diyCounet = NSLocalizedString(@"尚未填写", nil);
        } else {
            diyCounet = [NSString stringWithFormat:@"%@%@",model.experience,NSLocalizedString(@"年", nil)];
        }
        
        NSString * styleString = [model.styleNames stringByReplacingOccurrencesOfString:@"," withString:@" "];
        styleString = [styleString stringByReplacingOccurrencesOfString:@"，" withString:@" "];
//        model.following_count
        NSString *followingCount = model.follows == nil ? @"0" : model.follows;
        self.moneyLabel.text         = [NSString stringWithFormat:@"%@ : %@ | 关注人数 : %@",
                                           NSLocalizedString(@"从业年限", nil),
                                           diyCounet,followingCount];
        
        self.styleLabel.text            = [NSString stringWithFormat:@"%@ : %@",
                                           NSLocalizedString(@"擅长风格", nil),
                                           ([CoStringManager isEmptyString:model.styleNames])?NSLocalizedString(@"尚未填写", nil):styleString];
        NSString *design_budget;
        if (model.designPriceMin == nil) {
            design_budget = NSLocalizedString(@"尚未填写", nil);
        } else {
            design_budget = [NSString stringWithFormat:@"%ld-%ld%@/m²",
                             (long)model.designPriceMin.integerValue,
                             (long)model.designPriceMax.integerValue,
                             NSLocalizedString(@"元", nil)];
        }
        
        NSString *money;
        if (model.measurementPrice == nil) {
            money = NSLocalizedString(@"尚未填写", nil);
        } else {
            money = [NSString stringWithFormat:@"%.2f%@",[model.measurementPrice floatValue],NSLocalizedString(@"元", nil)];
        }
        self.diyCountLabel.text            = [NSString stringWithFormat:@"%@ : %@ 丨 %@ : %@",
                                           NSLocalizedString(@"设计费", nil),
                                           design_budget,
                                           NSLocalizedString(@"量房费", nil),
                                           money];
        
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:ICON_HEADER_DEFAULT]];
        NSInteger realname = [model.isRealName integerValue];
        if (realname == 2) {
            self.isRealImageView.hidden = NO;
        } else {
            self.isRealImageView.hidden = YES;
        }
    }
}

- (IBAction)chatButtonAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(chatWithDesigner)]) {
        [self.delegate chatWithDesigner];
    }
}

- (IBAction)chaooseTaMeasure:(id)sender {
    if ([self.delegate respondsToSelector:@selector(chooseTAMeasure)]) {
        [self.delegate chooseTAMeasure];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state//
}

@end
