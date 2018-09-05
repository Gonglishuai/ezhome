//
//  ProfFilterNameItemDO.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/28/13.
//
//

#import <Foundation/Foundation.h>

@interface ProfFilterNameItemDO : NSObject


@property(nonatomic)NSString * key;
@property(nonatomic)NSString * name;

-(id)initWithDict:(NSDictionary*)dict;
@end
