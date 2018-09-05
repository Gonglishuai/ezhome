//
//  ESMasterSearchHistoryHeaderView.h
//  Mall
//
//  Created by jiang on 2017/8/30.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESMasterSearchHistoryHeaderView : UITableViewHeaderFooterView
- (void)setTitle:(NSString *)title Block:(void(^)(void))block;
@end
