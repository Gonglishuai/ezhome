//
//  ESCaseCollectionTableViewCell.h
//  Consumer
//
//  Created by jiang on 2017/8/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESCaseCollectionTableViewCell : UITableViewCell
- (void)setFavDatas:(NSArray *)datas tapBlock:(void(^)(NSString *))tapBlock;
@end
