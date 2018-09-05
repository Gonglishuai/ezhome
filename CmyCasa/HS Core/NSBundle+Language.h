//
//  BundleEx.h
//  Homestyler
//
//  Created by Tomer Har Yoffi on 7/7/14.
//
//

#import <Foundation/Foundation.h>
@interface NSBundle (Language)

-(NSString *)getLanguageCode;

+(void)setLanguage:(NSString*)language;
@end
