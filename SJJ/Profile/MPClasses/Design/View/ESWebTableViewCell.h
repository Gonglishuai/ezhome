//
//  ESWebTableViewCell.h
//  Consumer
//
//  Created by jiang on 2017/8/15.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESWebView.h"

@interface ESWebTableViewCell : UITableViewCell
- (void)setUrl:(NSString *)url ContentSizeCallBack:(void(^)(CGSize))block  tapBlock:(void(^)(NSString *))tapBlock;

@end
