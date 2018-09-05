//
//  MessagesResponse.h
//  Homestyler
//
//  Created by liuyufei on 5/1/18.
//

#import "BaseResponse.h"

@interface MessagesResponse : BaseResponse

@property (nonatomic, strong) NSDictionary *countOfTypes;

@property (nonatomic, strong) NSArray *noticeList;

@property (nonatomic, strong) NSString *lastViewTime;

@end
