//
//  NSString+JSONHelpers.h
//  CmyCasa
//
// Clean a given NSString for use as a JSON string
//

#import <Foundation/Foundation.h>

@interface NSString (JSONHelpers)
-(NSString*)prepareStringForJSON;
-(NSString*)unescapeUnicode;
-(NSString*)removeControlChars;
-(NSMutableDictionary*)parseJsonStringIntoMutableDictionary;
-(NSString*)capitalizeFirstChar;
@end
