//
//  NSString+EmailValidation.h
//  Homestyler
//
//  Created by Berenson Sergei on 8/7/13.
//
//

#import <Foundation/Foundation.h>

@interface NSString (EmailValidation )


-(BOOL)isStringValidEmail;
+(BOOL)notEmpty:(NSString*)string;

@end


