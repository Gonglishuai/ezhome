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

@interface HSNUIIconLabelButton : UIButton

@property (nonatomic, strong) NSString *iconDefaultHexValue;
@property (nonatomic, strong) NSString *iconHighlightedValue;
@property (nonatomic, strong) NSString *iconSelectedValue;
@property (nonatomic, strong) NSString *iconDisabledValue;
@property (nonatomic, strong) NSString *iconNuiClass;
@property (nonatomic, strong) NSString *iconHorizontalPosition;
@property (nonatomic, strong) UIButton *btnIcon;

- (void)addIconButton;
@end
