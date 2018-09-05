//
//  NSString+UrlParams.m
//  Homestyler
//
//  Created by Berenson Sergei on 7/17/13.
//
//

#import "NSString+UrlParams.h"

@implementation NSString (UrlParams)


-(NSString*)replaceUrlParamPlaceHolder:(NSString*)value forKey:(NSString*)placeholder{
    
    
    if (placeholder==nil || value==nil || [placeholder length]==0 || [value length]==0) {
        return self;
    }
    
    
   return  [self stringByReplacingOccurrencesOfString:placeholder
                                           withString: [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
   
}

-(NSString*)AddUrlParameterToUrlString:(NSString*)value forKey:(NSString*)key{
 
    if (key==nil || value==nil || [key length]==0 || [value length]==0) {
        return self;
    }
    

    
    if ([self rangeOfString:@"?"].location==NSNotFound) {
        return [NSString stringWithFormat:@"%@?%@=%@",self,key,
                 [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }else
        return [NSString stringWithFormat:@"%@&%@=%@",self,key,
                 [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    
    
}

@end
