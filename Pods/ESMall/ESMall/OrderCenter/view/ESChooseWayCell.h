//
//  ESChooseWayCell.h
//  Consumer
//
//  Created by jiang on 2017/6/26.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESChooseWayCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lineLabel;
- (void)setWayImageName:(NSString *)imgName wayTitle:(NSString *)wayTitle selected:(BOOL)selected;
@end
