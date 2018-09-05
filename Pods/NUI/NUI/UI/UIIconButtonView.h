//
//  HSNUIIconLabelButton.h
//  Homestyler
//
//  Created by Maayan Zalevas on 4/16/14.
//
//



/*
 Set a value for "icon<?>HexValue" in Interface Builders' "User Defined Runtime Attributes" in order to set the Hex text to be translated to an icon via the custom font.
 Set a value for "iconNuiClass" in Interface Builders' "User Defined Runtime Attributes" in order to set a nuiClass for the icon part of the custom button.
 */

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface UIIconButtonView : UIButton


@property (nonatomic, strong) IBInspectable NSString *iconHighlightedValue;
@property (nonatomic, strong) IBInspectable NSString *iconSelectedValue;
@property (nonatomic, strong) IBInspectable NSString *iconDisabledValue;
@property (nonatomic, strong) IBInspectable NSString *iconNuiClass;
@property (nonatomic, strong) IBInspectable NSString *iconHorizontalPosition;
@property (nonatomic, strong) IBInspectable UIButton *btnIcon;

@property (nonatomic, strong) IBInspectable NSString *iconDefaultHexValue;
@property (nonatomic, strong) IBInspectable UIColor  *iconColor;
@property (nonatomic) IBInspectable CGPoint   iconHorMargin;
@property (nonatomic) IBInspectable CGPoint   iconVertMargin;
@property (nonatomic) IBInspectable CGFloat   iconSize;

- (void)addIconButton;
@end
