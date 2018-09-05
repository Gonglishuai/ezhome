//
//  NSData+MD5.m
//  Homestyler
//
//  Created by Or Sharir on 4/23/13.
//
//

#import "MD5Categories.h"
#import <CommonCrypto/CommonDigest.h>
#import "Base64.h"
@implementation NSData (MD5)
-(NSString*)md5 {
    unsigned char result[16];
    CC_MD5( self.bytes, (CC_LONG)self.length, result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}
-(NSString*)md5InBase64 {
    unsigned char result[16];
    CC_MD5( self.bytes, (CC_LONG)self.length, result ); // This is the md5 call
    NSData* d = [NSData dataWithBytes:result length:16];
    return [d base64EncodedString];
}
-(BOOL)checkMD5:(NSString*)md5Encoding {
    if (md5Encoding == nil || md5Encoding.length == 0) {
        return NO;
    }
    NSString* md5 = [self md5];
    if (![md5 isEqualToString:md5Encoding]) {
        HSMDebugLog(@"Checksum Error. Expected %@. Found %@", md5Encoding, md5);
        return NO;
    }
    return YES;
}
@end

@implementation NSString (MD5)
-(NSString*)md5 {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] md5];
}
-(NSString*)md5InBase64 {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] md5InBase64];
}
-(BOOL)checkMD5:(NSString*)md5Encoding {
    return [[self md5] isEqualToString:md5Encoding];
}
@end

