//
//  ESCaseShareModel.h
//  Consumer
//
//  Created by jiang on 2017/8/21.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESCaseShareModel : NSObject
@property (nonatomic, strong) NSString *shareUrl;       //
@property (nonatomic, strong) NSString *shareTitle;           //
@property (nonatomic, strong) NSString *shareContent;           //
@property (nonatomic, strong) NSString *shareImg;
+ (instancetype)objFromDict: (NSDictionary *)dict;
@end
