//
//  ESKeyBoardInputView.h
//  Consumer
//
//  Created by jiang on 2017/8/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESKeyBoardInputView : UIView
@property (weak, nonatomic) IBOutlet UITextField *textField;

+ (instancetype)creatWithPlacetitle:(NSString *)placeTitle title:(NSString *)title Block:(void(^)(NSString*))block;
- (void)setWithPlacetitle:(NSString *)placeTitle title:(NSString *)title;
@end
