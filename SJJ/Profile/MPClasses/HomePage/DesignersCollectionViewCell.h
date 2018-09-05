//
//  DesignersCollectionViewCell.h
//  Consumer
//
//  Created by jiang on 2017/5/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^DesignerClickBlock)(NSInteger);
@interface DesignersCollectionViewCell : UICollectionViewCell

- (void)setDataSource:(NSMutableArray *)datas calculateBlock:(DesignerClickBlock)block;

@end
