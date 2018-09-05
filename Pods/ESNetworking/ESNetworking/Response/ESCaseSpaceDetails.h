//
//  ESCaseSpaceDetails.h
//  AFNetworking
//
//  Created by xiefei on 28/7/18.
//

#import <Foundation/Foundation.h>
#import "ESCaseRenderImage.h"

@interface ESCaseSpaceDetails : NSObject
@property (nonatomic, copy) NSString *roomTypeCode;
@property (nonatomic, copy) NSString *description_Space;
@property (nonatomic, strong) NSMutableArray <ESCaseRenderImage *>* renderImgs;
@property (nonatomic, strong) NSMutableArray *imageUrls;
@property (nonatomic, strong) NSMutableArray *isHave360Urls;

+ (instancetype)objFromDict: (NSDictionary *)dict;
@end
