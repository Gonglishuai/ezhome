//
//  RetailerDO.h
//  Homestyler
//
//  Created by Berenson Sergei on 8/12/13.
//
//

#import <Foundation/Foundation.h>
#import "RestkitObjectProtocol.h"
@interface RetailerDO : NSObject<RestkitObjectProtocol>

@property(nonatomic,strong)NSString * name;
@property(nonatomic,strong)NSString * url;

-(id)initWithDictionary:(NSDictionary *)dict;

@end
