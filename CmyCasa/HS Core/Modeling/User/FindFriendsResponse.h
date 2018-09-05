//
//  FindFriendsResponse.h
//  Homestyler
//
//  Created by Berenson Sergei on 8/6/13.
//
//

#import "BaseResponse.h"

@interface FindFriendsResponse : BaseResponse


@property(nonatomic,strong) NSMutableArray * users;
@property(nonatomic,strong) NSMutableArray * invited;
@property(nonatomic,strong) NSMutableArray * unknown;


@end
