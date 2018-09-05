//
//  MPCaseScreenViewController.h
//  MarketPlace
//
//  Created by xuezy on 16/2/23.
//  Copyright © 2016年 xuezy. All rights reserved.
//

#import "MPBaseViewController.h"
@protocol caseScreendelegate <NSObject>

- (void)selectedClassificationDict:(NSMutableDictionary *)classficationDict withSelectDict:(NSMutableDictionary *)selectDict;

@end

@interface MPCaseScreenViewController : MPBaseViewController

@property (weak, nonatomic)id<caseScreendelegate>delegate;
@property (strong, nonatomic)NSMutableDictionary *selectDict;

@property (strong, nonatomic)NSMutableDictionary *selectTypeDict;

@property (nonatomic,copy)NSString * selectionsStr;

@end
