//
//  ESCaseUserInfo.h
//  AFNetworking
//
//  Created by xiefei on 27/7/18.
//

#import <Foundation/Foundation.h>

@interface ESCaseUserInfo : NSObject
@property (nonatomic, copy) NSString *design_id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *avatarUrl;

+ (instancetype)objFromDict: (NSDictionary *)dict;
@end
