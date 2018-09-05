//
//  SelectExampleCell.h
//  Consumer
//
//  Created by jiang on 2017/5/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MPCaseModel;
@class HomeConsumerExampleModel;
typedef void (^NormalClickBlock)(void);
@interface SelectExampleCell : UICollectionViewCell

- (void)setNewModel:(HomeConsumerExampleModel *)model headerBlock:(NormalClickBlock)headerBlock IMBlock:(NormalClickBlock)IMblock;
@end
