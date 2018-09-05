//
//  UIView+Alignment.h
//  Homestyler
//
//  Created by Avihay Assouline on 1/7/14.
//
//

#import <UIKit/UIKit.h>

///////////////////////////////////////////////////////
//                  TYPES                            //
///////////////////////////////////////////////////////

typedef enum AlignmentBaseLineType_t
{
    eAlignmentLeft = 0,
    eAlignmentRight,
    eAlignmentHorizontalCenter,
    eAlignmentVerticalCenter,
    eAlignmentTop,
    eAlignmentBottom
} AlignmentBaseLineType;

typedef enum AppendBaseLineType_t
{
    eAppendLeft = 0,
    eAppendRight,
    eAppendTop,
    eAppendBottom
} AppendBaseLineType;

typedef enum {
    DirectionTop = 0,
    DirectionBottom = 1,
}IphoneXOffSetDirection;

///////////////////////////////////////////////////////
//                  INTERFACE                        //
///////////////////////////////////////////////////////

@interface UIView (Alignment)

- (void)alignWithView:(UIView*)referenceView type:(AlignmentBaseLineType)type;
- (void)appendViewWithMargin:(UIView*)viewToAppend type:(AppendBaseLineType)type margin:(CGFloat)margin;
- (void)alignWithViewAndMargin:(UIView*)referenceView type:(AlignmentBaseLineType)type margin:(CGFloat)margin;
+ (void)getIphoneXoffsetcurrentView:(UIView *)currentView andControllerView:(CGRect)controllerVc andDirection:(IphoneXOffSetDirection)direction andMargin:(CGFloat)margin;

@end
