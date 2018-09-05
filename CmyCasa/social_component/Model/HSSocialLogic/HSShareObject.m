//
//  HSShareObject.m
//  Homestyler
//
//  Created by Berenson Sergei on 11/11/13.
//
//

#import "HSShareObject.h"

@implementation HSShareObject


-(id)init{
    self=   [super init];
    self.canComposeMessage=YES;
    
    return self;
}

-(NSString*)getSharingMessage{
    NSString * result = nil;
    if (!self.canComposeMessage) {
        NSString *messageStr = [self.message copy];
        if ([self.message rangeOfString:@"#homestyler"].location == NSNotFound) {
            messageStr = [NSString stringWithFormat:@"%@\n%@",@"#homestyler",messageStr];
        }
        return messageStr;
    }
//    if (self.designShareLink) {
//        result = [NSString stringWithFormat:@"%@ %@",self.message,self.designShareLink];
//    }else{
//        result = self.message;
//    }
    result = self.message;
    return result;
}
@end
