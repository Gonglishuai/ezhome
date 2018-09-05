//
//  RoomTypeDO.h
//  Homestyler
//
//  Created by Ma'ayan on 11/27/13.
//
//

#import <Foundation/Foundation.h>

@interface RoomTypeDO : NSObject

@property (nonatomic, strong) NSString *myId;
@property (nonatomic, strong) NSString *desc;

+ (RKObjectMapping *)jsonMapping;

@end
