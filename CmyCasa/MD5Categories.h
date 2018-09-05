//
//  NSData+MD5.h
//  Homestyler
//
//  Created by Or Sharir on 4/23/13.
//
//

#import <Foundation/Foundation.h>

@interface NSData (MD5)
-(NSString*)md5;
-(NSString*)md5InBase64;
-(BOOL)checkMD5:(NSString*)md5Encoding;
@end

@interface NSString (MD5)
-(NSString*)md5;
-(NSString*)md5InBase64;
-(BOOL)checkMD5:(NSString*)md5Encoding;
@end
