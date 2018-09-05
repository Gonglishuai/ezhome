//
//  ProfFilterNameItemDO.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/28/13.
//
//

#import "ProfFilterNameItemDO.h"

@implementation ProfFilterNameItemDO

-(id)initWithDict:(NSDictionary*)dict{
    
    self=[super init];
    
    
    self.key=[dict objectForKey:@"key"];
    self.name=[dict objectForKey:@"val"];
    
    return self;
}
@end
