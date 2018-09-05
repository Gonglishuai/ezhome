//
//  UserCombosResponse.h
//  Homestyler
//
//  Created by Berenson Sergei on 12/19/13.
//
//

#import "BaseResponse.h"

@class UserComboDO;

@interface UserCombosResponse : BaseResponse


@property(nonatomic,strong)NSMutableArray * profs;
@property(nonatomic,strong)NSMutableArray * tools;
@property(nonatomic,strong)NSMutableArray * styles;
@property(nonatomic,strong)NSMutableArray * userTypes;
@property(nonatomic,strong)NSMutableArray * genders;


-(UserComboDO *)getMaleComboObject;
-(UserComboDO *)getFemaleComboObject;
-(UserComboDO *)getUnkonwnGenderObject;

@end
