//
//  ESMSServerStoreViewController.h
//  Mall
//
//  Created by jiang on 2017/9/8.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "MPBaseViewController.h"

@interface ESMSServerStoreViewController : MPBaseViewController
- (void)setBlock:(void(^)(NSMutableDictionary *serverStoreDic))block;
@end
