//
//  ESCase2DItemModel.h
//  AFNetworking
//
//  Created by Admin on 2018/8/6.
//

#import <Foundation/Foundation.h>

@interface ESCase2DItemModel : NSObject
//@property (nonatomic, copy) NSString *[id];
@property (nonatomic, copy) NSString *link;
@property (nonatomic, assign) bool isPrimary;

+ (instancetype)objFromDict: (NSDictionary *)dict;
@end
