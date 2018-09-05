//
//  NotificationDesignInfoDO.h
//  Homestyler
//
//  Created by liuyufei on 5/1/18.
//

#import "BaseResponse.h"

@interface NotificationDesignInfoDO : NSObject<RestkitObjectProtocol>

@property (nonatomic, strong) NSString *designId;
@property (nonatomic, strong) NSString *designUserId;
@property (nonatomic, strong) NSString *designName;
@property (nonatomic, strong) NSString *resultImage;
@property (nonatomic, strong) NSString *foldCount;

@end
