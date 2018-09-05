//
//  HSNUIIconLabelButton.m
//  Homestyler
//
//  Created by Maayan Zalevas on 4/16/14.
//
//

#import "UIIconButtonView.h"
#import "UIButton+NUI.h"


@implementation UIIconButtonView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self addIconButton];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if ((hitView != nil) && (hitView == self.btnIcon))
    {
        return self;
    }
    // If the hitView is THIS view, return the view that you want to receive the touch instead:
    /*if (hitView == self) {
     return otherView;
     }*/
    // Else return the hitView (as it could be one of this view's buttons):
    return hitView;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (self.btnIcon != nil)
    {
        [self.btnIcon setHighlighted:highlighted];
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (self.btnIcon != nil)
    {
        [self.btnIcon setHighlighted:selected];
    }
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    if (self.btnIcon != nil)
    {
        [self.btnIcon setEnabled:enabled];
    }
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath
{
    //set the nuiClass value for the icon label
    if ([keyPath isEqualToString:@"iconNuiClass"])
    {
        if ((self.btnIcon != nil) && ([self.btnIcon respondsToSelector:@selector(nuiClass)]))
        {
            [self.btnIcon setValue:value forKeyPath:@"nuiClass"];
        }
    }
    else if ([keyPath isEqualToString:@"iconDefaultHexValue"])
    {
        if (self.btnIcon != nil)
        {
            [self.btnIcon setTitle:value forState:UIControlStateNormal];
        }
    }
    else if ([keyPath isEqualToString:@"iconHighlightedValue"])
    {
        if (self.btnIcon != nil)
        {
            [self.btnIcon setTitle:value forState:UIControlStateHighlighted];
        }
    }
    else if ([keyPath isEqualToString:@"iconDisabledValue"])
    {
        if (self.btnIcon != nil)
        {
            [self.btnIcon setTitle:value forState:UIControlStateDisabled];
        }
    }
    else if ([keyPath isEqualToString:@"iconSelectedValue"])
    {
        if (self.btnIcon != nil)
        {
            [self.btnIcon setTitle:value forState:UIControlStateSelected];
        }
    }
    else if ([keyPath isEqualToString:@"iconHorizontalPosition"])
    {
        if (self.btnIcon != nil)
        {
            if ([self.iconHorizontalPosition isEqualToString:@"right"])
                [self.btnIcon setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
            
            else if ([self.iconHorizontalPosition isEqualToString:@"left"])
                [self.btnIcon setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        }
    }
    
    [super setValue:value forKeyPath:keyPath];
}


//Override this method to not raise an exception in case of a human error when setting one of the runtime attributes in IB
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

- (void)addIconButton
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [btn setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft]; // Default position for the icon is left
    
    
    
    if (self.iconHorizontalPosition != nil)
    {
        if ([self.iconHorizontalPosition isEqualToString:@"right"])
            [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        
        if ([self.iconHorizontalPosition isEqualToString:@"left"])
            [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    }
    
//    if (self.iconNuiClass != nil)
//    {
//        [btn setValue:self.iconNuiClass forKeyPath:@"nuiClass"];
//    }
//    
    if (self.iconDefaultHexValue != nil)
    {
        [btn setTitle:self.iconDefaultHexValue forState:UIControlStateNormal];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(self.iconVertMargin.x,
                                                 self.iconHorMargin.x,
                                                 self.iconVertMargin.y,
                                                 self.iconHorMargin.y)];
        [btn setTitleColor:self.iconColor forState:UIControlStateNormal];
    }
    [btn.titleLabel setFont:[UIFont fontWithName:@"homestylermainicons" size:self.iconSize]];
//
//    if (self.iconHighlightedValue != nil)
//    {
//        [btn setTitle:self.iconHighlightedValue forState:UIControlStateHighlighted];
//    }
//    
//    if (self.iconDisabledValue != nil)
//    {
//        [btn setTitle:self.iconDisabledValue forState:UIControlStateDisabled];
//    }
//    
//    if (self.iconSelectedValue != nil)
//    {
//        [btn setTitle:self.iconSelectedValue forState:UIControlStateSelected];
//    }
    
    [self addSubview:btn];
    
    self.btnIcon = btn;
    
    [self setNeedsDisplay];
}

-(void)prepareForInterfaceBuilder
{
    [self addIconButton];
}

@end
