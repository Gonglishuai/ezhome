//
//  RecommendFromDesingerCell.h
//  Consumer
//
//  Created by shejijia on 13/4/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecommendFromDesingerCell : UITableViewCell
 
@property (nonatomic, strong) UIImageView *recommendTypeImV;
@property (nonatomic ,strong) UIImageView *backImgV;
@property (nonatomic ,strong) UILabel *title;
@property (nonatomic ,strong) UIImageView *iconImgV;
@property (nonatomic ,strong) UILabel *name;
@property (nonatomic ,strong) UILabel *recommendTime;
@property (nonatomic ,strong) UILabel *line;

- (void)setInfo:(NSDictionary *)info;

@end
