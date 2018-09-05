//
//  ESCase2DImageModel.h
//  AFNetworking
//
//  Created by Admin on 2018/8/6.
//

#import <Foundation/Foundation.h>
#import "ESCase2DItemModel.h"

@interface ESCase2DImageModel : NSObject
@property (nonatomic, copy) NSString *typeKey;
@property (nonatomic, copy) NSString *typeName;
@property (nonatomic, copy) NSString *description_Space;
@property (nonatomic, strong) NSMutableArray <ESCase2DItemModel *>* renderImgs;

+ (instancetype)objFromDict: (NSDictionary *)dict;
@end
