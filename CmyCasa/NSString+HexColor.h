//
//  NSString+HexColor.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/12/13.
//
//

#import <Foundation/Foundation.h>

@interface NSString (HexColor)
// Assumes input like "#00FF00" (#RRGGBB).
- (UIColor *)hextoColorDIY;
@end
