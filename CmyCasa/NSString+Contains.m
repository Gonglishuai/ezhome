//
//  NSString+Contains.m
//  Homestyler
//
//  Created by Or Sharir on 6/13/13.
//
//

#import "NSString+Contains.h"

@implementation NSString (Contains)
-(BOOL)contains:(NSString*)string {
    return [self contains:string options:NSCaseInsensitiveSearch];
}

-(BOOL)contains:(NSString*)string options:(NSStringCompareOptions)options {
    return [self rangeOfString:string options:options].location != NSNotFound;
}

-(NSString *)JSONString:(NSString *)aString {
    NSMutableString *s = [NSMutableString stringWithString:aString];
    [s replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"/" withString:@"\\/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\n" withString:@"\\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\b" withString:@"\\b" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\f" withString:@"\\f" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\r" withString:@"\\r" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\t" withString:@"\\t" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    return [NSString stringWithString:s];
}

+(BOOL)isNullOrEmpty:(NSString*)str{
    if (!str) {
        return YES;
    }
    if ([str isKindOfClass:[NSString class]] && [str length]>0) {
        return NO;
    }
    return YES;
}


+ (NSString*)localizedStringCustom:(NSString*)key{
    NSString *myLocalizableString = NSLocalizedString(key, @"");
   
    return  myLocalizableString;
}

@end
