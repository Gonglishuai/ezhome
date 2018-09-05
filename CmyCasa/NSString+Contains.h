//
//  NSString+Contains.h
//  Homestyler
//
//  Created by Or Sharir on 6/13/13.
//
//

#import <Foundation/Foundation.h>

@interface NSString (Contains)

+(BOOL)isNullOrEmpty:(NSString*)str;

-(BOOL)contains:(NSString*)string;
-(BOOL)contains:(NSString*)string options:(NSStringCompareOptions)options;
-(NSString *)JSONString:(NSString *)aString;

//Localization
+ (NSString*)localizedStringCustom:(NSString*)key;
@end
