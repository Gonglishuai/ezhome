//
//  ItemCollectionViewCell.h
//  Consumer
//
//  Created by jiang on 2017/5/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^ItemClickBlock)(NSInteger);

@interface ItemCollectionViewCell : UICollectionViewCell
- (void)setDataSource:(NSDictionary *)datas calculateBlock:(ItemClickBlock)block;
@end
