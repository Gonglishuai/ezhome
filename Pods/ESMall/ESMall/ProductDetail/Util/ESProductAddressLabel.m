
#import "ESProductAddressLabel.h"
#import <ESFoundation/UIColor+Stec.h>
@implementation ESProductAddressLabel
{
    UIColor *_addressLabelBackgroundColor;
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

// 可以响应的方法
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(newCopyFunc))
    {
        return YES;
    }
    return NO;
}

//针对于响应方法的实现
-(void)copy:(id)sender
{
    [self newCopyFunc];
}

//UILabel默认是不接收事件的，我们需要自己添加touch事件
-(void)attachTapHandler
{
    self.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *touch = [[UILongPressGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(handleTap:)];
    [self addGestureRecognizer:touch];
}

//绑定事件
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self attachTapHandler];
        [self addObserverForBackground];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self attachTapHandler];
    [self addObserverForBackground];
}

-(void)handleTap:(UIGestureRecognizer*) recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        return;
    }
    else if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        [self becomeFirstResponder];
        self.backgroundColor = self.addressLabelTappedBackgroundColor;
        UIMenuItem * item = [[UIMenuItem alloc]initWithTitle:@"复制"
                                                      action:@selector(newCopyFunc)];
        [[UIMenuController sharedMenuController] setTargetRect:self.frame
                                                        inView:self.superview];
        [UIMenuController sharedMenuController].menuItems = @[item];
        [UIMenuController sharedMenuController].menuVisible = YES;
    }
}

-(void)newCopyFunc
{
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    if (self.text)
    {
        pboard.string = self.text;
    }
    else
    {
        pboard.string = self.attributedText.string;
    }
}

- (void)addObserverForBackground
{
    __weak ESProductAddressLabel *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:UIMenuControllerWillHideMenuNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification * _Nonnull note)
     {
         weakSelf.backgroundColor = weakSelf.addressLabelBackgroundColor;
     }];
}

#pragma mark - Getter
- (UIColor *)addressLabelBackgroundColor
{
    if (!_addressLabelBackgroundColor)
    {
        _addressLabelBackgroundColor = [UIColor whiteColor];
    }
    
    return _addressLabelBackgroundColor;
}

- (UIColor *)addressLabelTappedBackgroundColor
{
    if (!_addressLabelTappedBackgroundColor)
    {
        _addressLabelTappedBackgroundColor = [UIColor stec_lineGrayColor];
    }
    
    return _addressLabelTappedBackgroundColor;
}

#pragma mark - Super Methods
- (void)dealloc
{
    NSLog(@"ESProductCopyLabel释放");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
