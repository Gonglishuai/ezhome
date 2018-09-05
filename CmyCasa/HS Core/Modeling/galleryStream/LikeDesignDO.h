//
//  LikeDesignDO.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/11/13.
//
//

#import <Foundation/Foundation.h>
#import "RestkitObjectProtocol.h"
#import "BaseResponse.h"

@interface LikeDesignDO : BaseResponse <NSCoding>


@property(nonatomic,strong)NSString *   designid;
@property(nonatomic,strong)NSNumber *   likesCount;
@property(nonatomic)BOOL         localModified;

@property(nonatomic)BOOL isUserLiked;


-(id)initWithDictionary:(NSDictionary*)dict;
-(id)init:(NSString*) in_id andCount :(NSNumber*) count;

-(void)updateUserLikeStatus:(BOOL)isLiked;
@end
