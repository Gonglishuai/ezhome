//
//  NSString+CommentsAndLikesNum.m
//  EZHome
//
//  Created by xiefei on 10/10/17.
//

#import "NSString+CommentsAndLikesNum.h"

@implementation NSString (CommentsAndLikesNum)
+(NSString *)numberHandle:(int)num {
    if (num > 9999) {
        return @"9999+";
    }else if (num <= 0){
        return @"";
    }else{
        return [NSString stringWithFormat:@"%d",num];
    }
}
@end
