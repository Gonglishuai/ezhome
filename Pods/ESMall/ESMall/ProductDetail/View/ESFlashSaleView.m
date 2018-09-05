
#import "ESFlashSaleView.h"
#import "ESFlashSaleInfoModel.h"
#import "UIImageView+WebCache.h"

@interface ESFlashSaleView ()

@property (weak, nonatomic) IBOutlet UIImageView *skuImageView;
@property (weak, nonatomic) IBOutlet UILabel *skuTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *skuPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *skuValueLabel;
@property (weak, nonatomic) IBOutlet UIButton *lessButton;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UILabel *warnLabel;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeightConstraint;

@end

@implementation ESFlashSaleView
{
    NSInteger _quantity;
}

+ (instancetype)flashSaleView
{
    NSArray *array = [[ESMallAssets hostBundle] loadNibNamed:@"ESFlashSaleView"
                                                   owner:self
                                                 options:nil];
    return [array firstObject];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.topHeightConstraint.constant = SCREEN_WIDTH * 125/375.0f;
    
    self.skuImageView.clipsToBounds = YES;
    self.skuImageView.layer.cornerRadius = 2.0f;
    self.skuImageView.layer.borderColor = [UIColor stec_lineBorderColor].CGColor;
    self.skuImageView.layer.borderWidth = 0.5f;
    
    self.skuValueLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
    [self.sureButton setBackgroundImage:[self createImageWithColor:[UIColor stec_grayBackgroundTextColor]]
                               forState:UIControlStateDisabled];
    [self.sureButton setBackgroundImage:[self createImageWithColor:[UIColor stec_blueTextColor]]
                               forState:UIControlStateNormal];
    
    _quantity = 1;
}


- (void)updateView
{
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getSkuMessage)])
    {
        ESFlashSaleInfoModel *model = [self.viewDelegate getSkuMessage];
        if (model
            && [model isKindOfClass:[ESFlashSaleInfoModel class]])
        {
            [self.skuImageView sd_setImageWithURL:[NSURL URLWithString:model.itemImg]
                                 placeholderImage:[UIImage imageNamed:@"search_case_logo"]];
            self.skuTitleLabel.text = model.itemName;
            self.skuPriceLabel.text = [@"¥" stringByAppendingString:model.salePrice];
            self.skuValueLabel.text = model.skuValueMessage;
            self.countLabel.text = [NSString stringWithFormat:@"%ld", _quantity];
            
            [self updateQuantity];
        }
    }
}

#pragma mark - Button Methods
- (IBAction)closeButtonDidTapped:(id)sender
{
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(closeButtonDidTapped)])
    {
        [self.viewDelegate closeButtonDidTapped];
    }
}

- (IBAction)lessButtonDidTapped:(id)sender
{
    _quantity -= 1;
    
    [self updateQuantity];
}

- (IBAction)moreButtonDidTapped:(id)sender
{
    _quantity += 1;
    
    [self updateQuantity];
}

- (IBAction)sureButtonDidTapped:(id)sender
{
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(sureButtonDidTapped:)])
    {
        [self.viewDelegate sureButtonDidTapped:_quantity];
    }
}

#pragma mark - Methods
- (void)updateQuantity
{
    self.countLabel.text = [NSString stringWithFormat:@"%ld", _quantity];
    
    self.lessButton.enabled = _quantity > 1;
    
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getSkuMessage)])
    {
        ESFlashSaleInfoModel *model = [self.viewDelegate getSkuMessage];
        if (model
            && [model isKindOfClass:[ESFlashSaleInfoModel class]])
        {
            BOOL limitQuantityStatus = _quantity <= [model.limitQuantity integerValue];
            self.warnLabel.hidden = limitQuantityStatus;
            self.sureButton.enabled = limitQuantityStatus;
            self.moreButton.enabled = limitQuantityStatus;
        }
    }
}

- (UIImage *)createImageWithColor: (UIColor *) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
