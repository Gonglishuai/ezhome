//
//  NSString+JSONHelpers.m
//  CmyCasa
//
//
//

#import "NSString+JSONHelpers.h"

@implementation NSString (JSONHelpers)
-(NSString*)prepareStringForJSON {
	NSString* temp = [[self unescapeUnicode] removeControlChars];
	temp = [temp stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
	return temp;
}
-(NSString*)unescapeUnicode {
	NSMutableString* convertedString = [self mutableCopy];
	CFStringRef transform = CFSTR("Any-Hex/Java");
	CFStringTransform((__bridge CFMutableStringRef)convertedString, NULL, transform, YES);
	return [NSString stringWithString:convertedString];
}
-(NSString*)removeControlChars {
	return [[[[self stringByReplacingOccurrencesOfString:@"\t" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""]  stringByReplacingOccurrencesOfString:@":null," withString:@":\"\","]
            stringByReplacingOccurrencesOfString:@":null" withString:@":\"\""];
}


-(NSMutableDictionary*)parseJsonStringIntoMutableDictionary{
  
    
    NSData *jsondata=[self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *errorDesc = nil;
    NSMutableDictionary *resp = [[NSJSONSerialization JSONObjectWithData:jsondata
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:&errorDesc] mutableCopy];
    
    return  resp;
}


-(NSString*)capitalizeFirstChar{
    
    NSString *firstCapChar = [[self substringToIndex:1] capitalizedString];
    NSString *cappedString = [self stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:firstCapChar];
    
    return cappedString;
    
}
@end
