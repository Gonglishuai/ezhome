//
//  ESCaseCommentCell.h
//  Consumer
//
//  Created by jiang on 2017/8/15.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESCaseCommentModel.h"

@interface ESCaseCommentCell : UITableViewCell
- (void)setFavDatas:(ESCaseCommentModel *)datas tapBlock:(void(^)(NSString *))tapBlock;
+ (CGFloat)currentCommitViewHeight:(NSString*)String;
@end
