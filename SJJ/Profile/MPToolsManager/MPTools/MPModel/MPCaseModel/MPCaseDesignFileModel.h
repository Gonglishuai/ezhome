//
//  MPCaseDesignFileModel.h
//  Consumer
//
//  Created by 董鑫 on 16/8/19.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "SHModel.h"
#import "CoStringManager.h"

@protocol MPCaseDesignFileModel <NSObject>

@end

@interface MPCaseDesignFileModel : SHModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString * cover;
@property (nonatomic, assign) BOOL is_primary;

@property (nonatomic, assign) BOOL sectionHead;
//@property (nonatomic, assign) BOOL status;
- (instancetype)initWithDict:(NSDictionary *)dict ;
+ (instancetype)getModelFromDict:(NSDictionary *)dict;

@end
