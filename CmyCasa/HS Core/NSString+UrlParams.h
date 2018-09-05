//
//  NSString+UrlParams.h
//  Homestyler
//
//  Created by Berenson Sergei on 7/17/13.
//
//

#import <Foundation/Foundation.h>

@interface NSString (UrlParams)



-(NSString*)replaceUrlParamPlaceHolder:(NSString*)value forKey:(NSString*)placeholder;

-(NSString*)AddUrlParameterToUrlString:(NSString*)value forKey:(NSString*)key;
@end

