
#import "ESProductDetailBottomButton.h"

const CGFloat shopping_cart_button_width = 90.0f;

@implementation ESProductDetailBottomButton
{
    UIButton *_addCartButton;
    UIButton *_customMadeButton;
    BOOL _productCouldSell;
    BOOL _productCustomMade;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initButtons];
    }
    return self;
}

- (void)initButtons
{
    // 购物车按钮
    UIButton *shoppingCartButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shoppingCartButton.frame = CGRectMake(0, 0, shopping_cart_button_width, CGRectGetHeight(self.frame));
    [shoppingCartButton setImage:[UIImage imageNamed:@"detail_shop_car"]
                        forState:UIControlStateNormal];
    [shoppingCartButton addTarget:self
                           action:@selector(shoppingCartButtonDidTapped)
                 forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:shoppingCartButton];
    
    
    
    // 添加购物车按钮
    _addCartButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _addCartButton.frame = CGRectMake(shopping_cart_button_width, 0, SCREEN_WIDTH - shopping_cart_button_width, CGRectGetHeight(self.frame));
    _addCartButton.titleLabel.font = [UIFont stec_bigTitleFount];
    [_addCartButton setBackgroundImage:[self createImageWithColor:[UIColor stec_ableButtonBackColor]]
                              forState:UIControlStateNormal];
    [_addCartButton setBackgroundImage:[self createImageWithColor:[UIColor stec_ableButtonBackColor]]
                              forState:UIControlStateHighlighted];
    [_addCartButton setTitle:@"加入购物车"
                    forState:UIControlStateNormal];
    [_addCartButton setTitleColor:[UIColor whiteColor]
                         forState:UIControlStateNormal];
    [_addCartButton addTarget:self
                       action:@selector(addCartButtonDidTapped)
             forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_addCartButton];
    
    if (BOTTOM_SAFEAREA_HEIGHT>0) {
        [shoppingCartButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
        _addCartButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0);
    }
}

#pragma mark - Button Methods
- (void)shoppingCartButtonDidTapped
{
    if (self.buttonDelegate
        && [self.buttonDelegate respondsToSelector:@selector(productDetailButtonDidTapped:enable:)])
    {
        [self.buttonDelegate productDetailButtonDidTapped:ESProductDetailBottomButtonTypeShoppingCart
                                                   enable:YES];
    }
}

- (void)addCartButtonDidTapped
{
    if (self.buttonDelegate
        && [self.buttonDelegate respondsToSelector:@selector(productDetailButtonDidTapped:enable:)])
    {
        [self.buttonDelegate productDetailButtonDidTapped:ESProductDetailBottomButtonTypeAddToCart
                                                   enable:_productCouldSell];
    }
}

- (void)customMadeButtonDidTapped
{
    if (self.buttonDelegate
        && [self.buttonDelegate respondsToSelector:@selector(productDetailButtonDidTapped:enable:)])
    {
        ESProductDetailBottomButtonType type =
        _productCustomMade ? ESProductDetailBottomButtonTypeCustomMade : ESProductDetailBottomButtonTypeBuy;
        [self.buttonDelegate productDetailButtonDidTapped:type
                                                   enable:_productCouldSell];
    }
}

- (void)flashSaleButtonDidTapped
{
    if (self.buttonDelegate
        && [self.buttonDelegate respondsToSelector:@selector(productDetailButtonDidTapped:enable:)])
    {
        [self.buttonDelegate productDetailButtonDidTapped:ESProductDetailBottomButtonTypeFlashSale
                                                   enable:NO];
    }
}

- (void)earnestButtonDidTapped
{
    if (self.buttonDelegate
        && [self.buttonDelegate respondsToSelector:@selector(productDetailButtonDidTapped:enable:)])
    {
        [self.buttonDelegate productDetailButtonDidTapped:ESProductDetailBottomButtonTypEarnest
                                                   enable:NO];
    }
}

#pragma mark - Public Methods
- (void)updateBottomButtons
{
    if (self.buttonDelegate
        && [self.buttonDelegate respondsToSelector:@selector(getBottomParams)])
    {
        NSDictionary *dict = [self.buttonDelegate getBottomParams];
        if (dict[@"earnestStatus"]
            && [dict[@"earnestStatus"] boolValue])
        {
            [self createEarnestButtonWithStatus:[dict[@"earnestStartStatus"] boolValue]];
        }
        else if (dict[@"flashSaleStatus"]
                 && [dict[@"flashSaleStatus"] boolValue])
        {
            [self createFlashSaleButton:[dict[@"flashSaleStartStatus"] boolValue]
                       hasStockQuantity:[dict[@"hasStockQuantity"] boolValue]];
        }
        else
        {
            [self createCustomMadeButton:[dict[@"customMade"] boolValue]];
            [self updateButtomButtonSellStatus:[dict[@"onSell"] boolValue]];
        }
    }
}

#pragma mark - Methods
- (void)createEarnestButtonWithStatus:(BOOL)startStatus
{
    for (UIView *view in self.subviews)
    {
        [view removeFromSuperview];
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = self.bounds;
    button.titleLabel.font = [UIFont stec_bigTitleFount];
    button.enabled = startStatus;
    [button setBackgroundImage:[self createImageWithColor:[UIColor stec_ableButtonBackColor]]
                      forState:UIControlStateNormal];
    [button setBackgroundImage:[self createImageWithColor:[UIColor stec_ableButtonBackColor]]
                      forState:UIControlStateHighlighted];
    [button setBackgroundImage:[self createImageWithColor:[UIColor stec_unabelButtonBackColor]]
                      forState:UIControlStateDisabled];
    [button setTitle:@"支付定金"
            forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor]
                 forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(earnestButtonDidTapped)
     forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
    if (BOTTOM_SAFEAREA_HEIGHT>0) {
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0);
    }
}

- (void)createFlashSaleButton:(BOOL)isStart
             hasStockQuantity:(BOOL)hasStockQuantity
{
    for (UIView *view in self.subviews)
    {
        [view removeFromSuperview];
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = self.bounds;
    button.titleLabel.font = [UIFont stec_bigTitleFount];
    [button setBackgroundImage:[self createImageWithColor:[UIColor stec_ableButtonBackColor]]
                              forState:UIControlStateNormal];
    [button setBackgroundImage:[self createImageWithColor:[UIColor stec_ableButtonBackColor]]
                              forState:UIControlStateHighlighted];
    [button setBackgroundImage:[self createImageWithColor:[UIColor stec_unabelButtonBackColor]]
                      forState:UIControlStateDisabled];
//    [button setTitle:@"加入购物车"
//                    forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor]
                         forState:UIControlStateNormal];
    [button addTarget:self
                       action:@selector(flashSaleButtonDidTapped)
             forControlEvents:UIControlEventTouchUpInside];
    NSString *buttonTitle = @"";
    if (!isStart)
    {
        buttonTitle = @"即将开始";
    }
    else
    {
        if (hasStockQuantity)
        {
            buttonTitle = @"立即抢购";
        }
        else
        {
            button.enabled = NO;
            buttonTitle = @"已售罄";
        }
    }
    [button setTitle:buttonTitle
            forState:UIControlStateNormal];
    [self addSubview:button];
    if (BOTTOM_SAFEAREA_HEIGHT>0) {
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0);
    }
}

- (void)updateButtomButtonSellStatus:(BOOL)couldSell
{
    _productCouldSell= couldSell;
    
    UIColor *addCartButtonColor = couldSell?[UIColor stec_ableButtonBackColor]:[UIColor stec_disabelButtonBackColor];
    [_addCartButton setBackgroundImage:[self createImageWithColor:addCartButtonColor]
                              forState:UIControlStateNormal];
    
    UIColor *customMadeButtonColor = couldSell?[UIColor stec_buttonBackColor]:[UIColor stec_disabelButtonBackColor];
    [_customMadeButton setBackgroundImage:[self createImageWithColor:customMadeButtonColor]
                                 forState:UIControlStateNormal];
}

- (void)createCustomMadeButton:(BOOL)showCustomMadeButton
{
    if (_customMadeButton)
    {
        return;
    }
    
    _productCustomMade = showCustomMadeButton;

    _addCartButton.frame = CGRectMake(
                                      shopping_cart_button_width,
                                      0,
                                      (SCREEN_WIDTH - shopping_cart_button_width)/2.0,
                                      CGRectGetHeight(self.frame)
                                      );
    
    _customMadeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat buttonWidth = (SCREEN_WIDTH - shopping_cart_button_width)/2.0;
    _customMadeButton.frame = CGRectMake(shopping_cart_button_width + buttonWidth, 0, buttonWidth, CGRectGetHeight(self.frame));
    _customMadeButton.titleLabel.font = [UIFont stec_bigTitleFount];
    [_customMadeButton setBackgroundImage:[self createImageWithColor:[UIColor stec_buttonBackColor]]
                                 forState:UIControlStateNormal];
    [_customMadeButton setBackgroundImage:[self createImageWithColor:[UIColor stec_buttonBackColor]]
                                 forState:UIControlStateHighlighted];
    NSString *title = _productCustomMade ? @"立即定制" : @"立即购买";
    [_customMadeButton setTitle:title
                       forState:UIControlStateNormal];
    [_customMadeButton setTitleColor:[UIColor whiteColor]
                            forState:UIControlStateNormal];
    [_customMadeButton addTarget:self
                          action:@selector(customMadeButtonDidTapped)
                forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_customMadeButton];
    if (BOTTOM_SAFEAREA_HEIGHT>0) {
        _addCartButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0);
        _customMadeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0);
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
