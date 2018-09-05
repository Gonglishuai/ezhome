//
//  NSMutableString+UrlParams.m
//  Homestyler
//
//  Created by Berenson Sergei on 7/17/13.
//
//

#import "NSMutableString+UrlParams.h"


@implementation NSMutableString (UrlParams)


-(void)replaceUrlParamMutablePlaceHolder:(NSString*)value forKey:(NSString*)placeholder{
    
    
    if (placeholder==nil || value==nil || [placeholder length]==0 || [value length]==0) {
        return;
    }
    
    [self replaceOccurrencesOfString:placeholder withString:
     [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                             options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self length])];
                                                                                                                    
    
    
}

-(void)AddUrlParameterMutableToUrlString:(NSString*)value forKey:(NSString*)key{
    
    if (key==nil || value==nil || [key length]==0 || [value length]==0) {
        return ;
    }
    
   
    
    if ([self rangeOfString:@"?"].location==NSNotFound) {
        [self appendFormat:@"?%@=%@",key,
         [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
     }else
        [self appendFormat:@"&%@=%@",key,
         [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    
    
}
@end
