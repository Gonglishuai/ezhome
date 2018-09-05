//
//  UserComboDO.h
//  Homestyler
//
//  Created by Berenson Sergei on 12/19/13.
//
//

#import "BaseResponse.h"
#import "RestkitObjectProtocol.h"

@interface UserComboDO : NSObject <RestkitObjectProtocol, NSCopying,NSCoding>


@property(nonatomic,strong)NSString * comboId;
@property(nonatomic,strong)NSString * comboName;

- (id)copyWithZone:(NSZone *)zone;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToADo:(UserComboDO *)aDo;

- (NSUInteger)hash;

@end
