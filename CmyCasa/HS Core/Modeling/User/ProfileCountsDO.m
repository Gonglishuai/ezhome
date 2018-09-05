//
// Created by Berenson Sergei on 12/30/13.
//


#import "ProfileCountsDO.h"


@implementation ProfileCountsDO {

}

-(instancetype)init{
    self = [super init];
    
    
    self.activities=[NSMutableString new];
    
    return self;
}
-(void)setActivities:(NSMutableString *)acts{
    _activities=acts;
}


@end