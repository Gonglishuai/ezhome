
#import "ESProductDetailModelView.h"
#import "ESProductDetailSampleroomModel.h"
#import "UIImageView+WebCache.h"

@interface ESProductDetailModelView ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gradientImageViewHeight;

@end

@implementation ESProductDetailModelView
{
    NSInteger _index;
}

+ (instancetype)productDetailModelView
{
    NSArray *array = [[ESMallAssets hostBundle] loadNibNamed:@"ESProductDetailModelView"
                                                   owner:self
                                                 options:nil];
    return [array firstObject];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = 2.0f;
    
    self.tipLabel.clipsToBounds = YES;
    self.tipLabel.layer.cornerRadius = CGRectGetHeight(self.tipLabel.frame)/2.0f;
    self.tipLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.tipLabel.layer.borderWidth = 1.0f;
    
    self.gradientImageViewHeight.constant = CGRectGetHeight(self.imageView.frame)/4.0f;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(modelViewDidTapped)];
    [self addGestureRecognizer:tap];
}

- (void)updateModelViewWithIndex:(NSInteger)index
{
    _index = index;
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getSampleroomWithIndex:)])
    {
        ESProductDetailSampleroomModel *sampleroomModel = [(id)self.viewDelegate getSampleroomWithIndex:index];
        if (!sampleroomModel
            || ![sampleroomModel isKindOfClass:[ESProductDetailSampleroomModel class]])
        {
            return;
        }
    
        self.informationLabel.text = sampleroomModel.case_information;
        
        self.imageView.image = [UIImage imageNamed:@"image_default"];
        if (sampleroomModel.default_img
            && [sampleroomModel.default_img isKindOfClass:[NSString class]]
            && sampleroomModel.default_img.length > 0)
        {
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:sampleroomModel.default_img]
                              placeholderImage:[UIImage imageNamed:@"image_default"]];
        }
    }
}

- (void)modelViewDidTapped
{
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(modelViewDidTappedWithIndex:)])
    {
        [self.viewDelegate modelViewDidTappedWithIndex:_index];
    }
}

@end
