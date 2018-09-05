//
//  ESDesignPricePicker.h
//  Consumer
//
//  Created by 焦旭 on 2017/11/8.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESFilterItem.h"

@protocol ESDesignPricePickerDelegate <NSObject>

- (void)selectedPrice:(ESFilterItem *)item;
@end

@interface ESDesignPricePicker : UIView

- (instancetype)initWithData:(NSArray <ESFilterItem *>*)data
                withDelegate:(id <ESDesignPricePickerDelegate>)delegate;

- (void)showDesignPricePickerInView:(UIView *)view;

- (void)hiddenInView;

@end
