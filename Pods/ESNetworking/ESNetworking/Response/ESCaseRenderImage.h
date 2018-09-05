//
//  ESCaseRenderImage.h
//  AFNetworking
//
//  Created by xiefei on 28/7/18.
//

#import <Foundation/Foundation.h>

@interface ESCaseRenderImage : NSObject
@property (nonatomic, copy) NSString *renderId;
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, copy) NSString *roomTypeDisplayName;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, assign) NSInteger selectStatus;
@property (nonatomic, copy) NSString *renderType;
@property (nonatomic, copy) NSString *coverUrl;
@property (nonatomic, copy) NSString *photoUrl;
@property (nonatomic, copy) NSString *photo360Url;
@property (nonatomic, copy) NSString *skus;
@property (nonatomic, copy) NSString *subRenderingType;

+ (instancetype)objFromDict: (NSDictionary *)dict;
@end
