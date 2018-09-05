//
//  SaveDesignResponse.h
//  Homestyler
//
//  Created by Berenson Sergei on 12/4/13.
//
//

#import "BaseResponse.h"

@interface SaveDesignResponse : BaseResponse

@property(nonatomic,strong) NSString * designID;
@property(nonatomic,strong) NSString * urlBack;
@property(nonatomic,strong) NSString * urlFinal;
@property(nonatomic,strong) NSString * urlInitial;
@property(nonatomic,strong) NSString * urlMask;
@end
