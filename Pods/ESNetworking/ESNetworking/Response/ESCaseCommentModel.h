//
//  ESCaseCommentModel.h
//  Consumer
//
//  Created by jiang on 2017/8/21.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESCaseCommentModel : NSObject

@property (nonatomic, assign) NSInteger commentId;       //
@property (nonatomic, assign) NSInteger resourceId;       //
@property (nonatomic, strong) NSString *resourceName;       //
@property (nonatomic, strong) NSString *regionId;     //
@property (nonatomic, strong) NSString *comment;      //
@property (nonatomic, strong) NSString *createTime;   //
@property (nonatomic, assign) NSInteger type;         //
@property (nonatomic, strong) NSString *createId;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *phone;

+ (instancetype)objFromDict: (NSDictionary *)dict;

@end
