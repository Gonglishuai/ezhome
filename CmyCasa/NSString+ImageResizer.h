//
//  NSString+ImageResizer.h
//  CmyCasa
//
//  Created by Berenson Sergei on 1/24/13.
//
//

#import <Foundation/Foundation.h>

@interface NSString (ImageResizeUrl)


-(NSString*)generateImageURLforWidth:(int)width andHight:(int)height  andVersion:(NSString*) version ;
-(NSString*)generateImageURLforWidth:(int)width andHight:(int)height ;
-(NSString*)generateImageURLWithEncodingForWidth:(int)width andHight:(int)height;

-(NSString*)generateImagePathForWidth:(int)width andHight:(int)height;

- (NSString *)addSmartfitSuffix;

@end
