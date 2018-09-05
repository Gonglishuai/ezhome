//
//  GetLayoutsDO.h
//  Homestyler
//
//  Created by Berenson Sergei on 7/29/13.
//
//

#import <Foundation/Foundation.h>
#import "RestkitObjectProtocol.h"
@interface GetLayoutsDO : BaseResponse <RestkitObjectProtocol>


@property(nonatomic,strong) NSMutableArray * layouts;
@property(nonatomic,strong) NSMutableArray * flows;


@end
