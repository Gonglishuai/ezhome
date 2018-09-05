//
//  ProductInfoGroupSectionAccessory.h
//  Homestyler
//
//  Created by Dan Baharir on 3/2/15.
//
//

#import <UIKit/UIKit.h>

typedef enum
{
    CustomColoredAccessoryTypeRight = 0,
    CustomColoredAccessoryTypeUp,
    CustomColoredAccessoryTypeDown
} CustomColoredAccessoryType;

@interface ProductInfoGroupSectionAccessory : UIControl
{
    UIColor *_accessoryColor;
    UIColor *_highlightedColor;
    
    CustomColoredAccessoryType _type;
}

@property (nonatomic, retain) UIColor *accessoryColor;
@property (nonatomic, retain) UIColor *highlightedColor;

@property (nonatomic, assign)  CustomColoredAccessoryType type;

+ (ProductInfoGroupSectionAccessory *)accessoryWithColor:(UIColor *)color type:(CustomColoredAccessoryType)type;

@end