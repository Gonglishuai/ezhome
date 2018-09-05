//
//  BundleEx.m
//  Homestyler
//
//  Created by Tomer Har Yoffi on 7/7/14.
//
//

#import "NSBundle+Language.h"


#import <objc/runtime.h>

static const char _bundle = 0;

@interface BundleEx : NSBundle
@end

@implementation BundleEx
-(NSString*)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName
{
    NSBundle* bundle=objc_getAssociatedObject(self, &_bundle);
    return bundle ? [bundle localizedStringForKey:key value:value table:tableName] : [super localizedStringForKey:key value:value table:tableName];
}
@end

/////////////////////////////////////////////////////////////

static NSString * _languageCode;

@implementation NSBundle (Language)

-(NSString *)getLanguageCode {
    if (!_languageCode) {
        _languageCode = [[NSBundle mainBundle].preferredLocalizations objectAtIndex:0];
        NSRange range = [_languageCode rangeOfString:@"-"];
        if (range.location != NSNotFound) {
            _languageCode = [_languageCode substringToIndex:range.location];
        }
    }
    return _languageCode;
}

+(void)setLanguage:(NSString*)language
{
    _languageCode = language;
    NSRange range = [_languageCode rangeOfString:@"-"];
    if (range.location != NSNotFound) {
        _languageCode = [_languageCode substringToIndex:range.location];
    }

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      object_setClass([NSBundle mainBundle],[BundleEx class]);
                  });
    objc_setAssociatedObject([NSBundle mainBundle], &_bundle, language ? [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:language ofType:@"lproj"]] : nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
