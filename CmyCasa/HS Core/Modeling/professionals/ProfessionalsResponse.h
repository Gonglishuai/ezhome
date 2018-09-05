//
//  ProfessionalsResponse.h
//  Homestyler
//
//  Created by Berenson Sergei on 9/18/13.
//
//

#import "BaseResponse.h"

@interface ProfessionalsResponse : BaseResponse


@property(nonatomic) NSMutableArray * professionals;

@property(nonatomic) ProfessionalDO * currentProfessional;
@end
