//
//  NSMutableString+UrlParams.h
//  Homestyler
//
//  Created by Berenson Sergei on 7/17/13.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableString (UrlParams)


-(void)replaceUrlParamMutablePlaceHolder:(NSString*)value forKey:(NSString*)placeholder;

-(void)AddUrlParameterMutableToUrlString:(NSString*)value forKey:(NSString*)key;

@end
