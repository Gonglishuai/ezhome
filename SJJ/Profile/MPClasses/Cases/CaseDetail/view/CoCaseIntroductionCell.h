//
//  CoCaseIntroductionCell.h
//  Consumer
//
//  Created by Jiao on 16/7/20.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ES2DCaseDetail;

@protocol CoCaseIntroductionCellDelegate <NSObject>

- (ES2DCaseDetail *)getIntroductionDetail;

@end
@interface CoCaseIntroductionCell : UITableViewCell
@property (nonatomic, weak) id<CoCaseIntroductionCellDelegate> delegate;
- (void)updateIntroductionCellWithIndex:(NSInteger)index;
@end
