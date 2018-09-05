//
//  UIView+Alignment.m
//  Homestyler
//
//  Created by Avihay Assouline on 1/7/14.
//
//

#import "UIView+Alignment.h"

@implementation UIView (Alignment)

- (void)alignWithView:(UIView*)referenceView type:(AlignmentBaseLineType)type
{
    CGRect referenceFrame = referenceView.frame;
    CGRect selfFrame = self.frame;
    
    switch (type)
    {
        case eAlignmentHorizontalCenter:
        {
            CGFloat leftXPosition = referenceFrame.origin.x + (referenceFrame.size.width / 2) - selfFrame.size.width / 2;
            [self setFrame:CGRectMake(leftXPosition, selfFrame.origin.y, selfFrame.size.width, selfFrame.size.height)];
        } break;
            
        case eAlignmentVerticalCenter:
        {
            CGFloat yPosition = referenceView.center.y;
            [self setCenter:CGPointMake(self.center.x, yPosition)];
        } break;
            
        case eAlignmentRight:
        {
            CGFloat rightXPosition = referenceFrame.origin.x + referenceFrame.size.width;
            [self setFrame:CGRectMake(rightXPosition - selfFrame.size.width, selfFrame.origin.y, selfFrame.size.width, selfFrame.size.height)];
        } break;
        case eAlignmentLeft:
        {
            CGFloat leftXPosition = referenceFrame.origin.x;
            [self setFrame:CGRectMake(leftXPosition, selfFrame.origin.y, selfFrame.size.width, selfFrame.size.height)];
        } break;
        case eAlignmentTop:
        {
            CGFloat topYPosition = referenceFrame.origin.y;
            [self setFrame:CGRectMake(selfFrame.origin.x, topYPosition, selfFrame.size.width, selfFrame.size.height)];
        } break;
        case eAlignmentBottom:
        {
            CGFloat topYPosition = referenceFrame.origin.y + referenceFrame.size.height - self.frame.size.height;
            [self setFrame:CGRectMake(selfFrame.origin.x, topYPosition, selfFrame.size.width, selfFrame.size.height)];
        } break;
        default:
        {
            
        } break;
    }
}

- (void)appendViewWithMargin:(UIView*)viewToAppend type:(AppendBaseLineType)type margin:(CGFloat)margin
{
    CGRect appendingFrame = viewToAppend.frame;
    CGRect selfFrame = self.frame;
    
    switch (type)
    {
        case eAppendLeft:
        {
            [viewToAppend setFrame:CGRectMake(selfFrame.origin.x - appendingFrame.size.width - margin,
                                              appendingFrame.origin.y,
                                              appendingFrame.size.width,
                                              appendingFrame.size.height)];
        } break;
            
        case eAppendRight:
        {
            [viewToAppend setFrame:CGRectMake(selfFrame.origin.x + selfFrame.size.width + margin,
                                              appendingFrame.origin.y,
                                              appendingFrame.size.width,
                                              appendingFrame.size.height)];
        } break;
        case eAppendBottom:
        {
            [viewToAppend setFrame:CGRectMake(appendingFrame.origin.x,
                                              selfFrame.origin.y + selfFrame.size.height + margin,
                                              appendingFrame.size.width,
                                              appendingFrame.size.height)];
        } break;
        case eAppendTop:
        {
            [viewToAppend setFrame:CGRectMake(appendingFrame.origin.x,
                                              selfFrame.origin.y - selfFrame.size.height - margin,
                                              appendingFrame.size.width,
                                              appendingFrame.size.height)];
        } break;
    }
}

- (void)alignWithViewAndMargin:(UIView*)referenceView type:(AlignmentBaseLineType)type margin:(CGFloat)margin
{
    CGRect referenceFrame = referenceView.frame;
    CGRect selfFrame = self.frame;
    
    switch (type)
    {
        case eAlignmentHorizontalCenter:
        {
            CGFloat leftXPosition = referenceFrame.origin.x + (referenceFrame.size.width / 2) - selfFrame.size.width / 2;
            [self setFrame:CGRectMake(leftXPosition, selfFrame.origin.y, selfFrame.size.width, selfFrame.size.height)];
        } break;
            
        case eAlignmentVerticalCenter:
        {
            // TODO
        } break;
            
        case eAlignmentRight:
        {
            CGFloat rightXPosition = referenceFrame.origin.x + referenceFrame.size.width;
            [self setFrame:CGRectMake(rightXPosition - selfFrame.size.width - margin, selfFrame.origin.y, selfFrame.size.width, selfFrame.size.height)];
        } break;
        case eAlignmentLeft:
        {
            CGFloat leftXPosition = referenceFrame.origin.x;
            [self setFrame:CGRectMake(leftXPosition + margin, selfFrame.origin.y, selfFrame.size.width, selfFrame.size.height)];
        } break;
        case eAlignmentTop:
        {
            CGFloat topYPosition = referenceFrame.origin.y;
            [self setFrame:CGRectMake(selfFrame.origin.x, topYPosition + margin, selfFrame.size.width, selfFrame.size.height)];
        } break;
        case eAlignmentBottom:
        {
            CGFloat topYPosition = referenceFrame.origin.y + referenceFrame.size.height - self.frame.size.height;
            [self setFrame:CGRectMake(selfFrame.origin.x, topYPosition - margin, selfFrame.size.width, selfFrame.size.height)];
        } break;
        default:
        {
            
        } break;
    }
}

static inline UIEdgeInsets sgm_safeAreaInset(UIView *view) {
    if (@available(iOS 11.0, *)) {
        return view.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}

+ (void)getIphoneXoffsetcurrentView:(UIView *)currentView andControllerView:(CGRect)controllerVc andDirection:(IphoneXOffSetDirection)direction andMargin:(CGFloat)margin {
    switch (direction) {
        case DirectionTop:{
            CGFloat safeAreaTop = 44.0; // 上方安全距离
            UIEdgeInsets safeAreaInsets = sgm_safeAreaInset(currentView);
            safeAreaTop += safeAreaInsets.top > 0 ? safeAreaInsets.top : 0;
            if (currentView.frame.origin.y != (safeAreaTop + margin)) {
                currentView.frame = CGRectMake(0, safeAreaTop + margin, currentView.frame.size.width, currentView.frame.size.height);
            }
        }
            break;
        case DirectionBottom:{
            CGFloat safeAreaBottom = 34.0; // 下方安全距离
            UIEdgeInsets safeAreaInsets = sgm_safeAreaInset(currentView);
            safeAreaBottom += safeAreaInsets.bottom > 0 ? safeAreaInsets.bottom : 0;
            if (currentView.frame.origin.y != (controllerVc.size.height - (safeAreaBottom + margin + currentView.frame.size.height))) {
                currentView.frame = CGRectMake(currentView.frame.origin.x, controllerVc.size.height - (safeAreaBottom + margin + currentView.frame.size.height), currentView.frame.size.width, currentView.frame.size.height);
            }
        }
        default:
            break;
    }
}

@end
