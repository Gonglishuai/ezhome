//
//  HSCryptograpy.m
//  Homestyler
//
//  Created by Avihay Assouline on 12/19/14.
//
//  Handeling cryptography extraction of models in the HSM environment
//  The BaseEncryptionKey's real Key is: 5acf54bfb06df475b455b48b7ab01210
//  xored with: dcea02b23b43
//

#import "HSCryptograpy.h"

NSString* const BaseEncryptionKey = @"8625560d8b2e289fb6e78fc8a65a10a2";
NSString* const Pepper = @"dcea02b23b43";

///////////////////////////////////////////////////////
//              IMPLEMENTATION                       //
///////////////////////////////////////////////////////

@implementation HSCryptograpy

////////////////////////////////////////////////////////////////////////////////////////////////////

+ (NSData*) decryptData:(NSData*)data withPublicKey:(NSString*)publicKey
{
    NSMutableData* baseKey = [[HSCryptograpy dataFromHexString:BaseEncryptionKey] mutableCopy];
    NSData* h = [HSCryptograpy dataFromHexString:Pepper];
    
    for (int i = 0, j = 0; i < baseKey.length; i++, j++) {
        unsigned char byte1, byte2;
        [baseKey getBytes:&byte1 range:NSMakeRange(i, 1)];
        if (j >= h.length) j = 0;
        [h getBytes:&byte2 range:NSMakeRange(j, 1)];
        byte1 = byte1 ^ byte2;
        [baseKey replaceBytesInRange:NSMakeRange(i, 1) withBytes:&byte1];
    }
    
    NSMutableString* key = [[NSMutableString alloc] initWithCapacity:baseKey.length * 2];
    for (int i = 0; i < baseKey.length; i ++) {
        unsigned char byte;
        [baseKey getBytes:&byte range:NSMakeRange(i, 1)];
        [key appendFormat:@"%02x", byte];
    }
    
    // Make sure the salt key is lower-cased
    NSString* salt = [publicKey lowercaseString];
    NSString* iv = [salt substringFromIndex:16];
    
    
    //hot fix on crash
    NSString* finalKey = nil;
    NSData *resualt = nil;
    if (iv) {
        finalKey = [key stringByAppendingString:salt];
        resualt = [HSCryptograpy doCipher:data
                                       iv:[iv dataUsingEncoding:NSUTF8StringEncoding]
                                      key:[HSCryptograpy dataFromHexString:finalKey]
                                  context:kCCDecrypt];
    }
    
    return resualt;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

+ (NSData *)doCipher:(NSData *)dataIn
                  iv:(NSData *)iv
                 key:(NSData *)symmetricKey
             context:(CCOperation)encryptOrDecrypt
{
    CCCryptorStatus ccStatus   = kCCSuccess;
    size_t          cryptBytes = 0;    // Number of bytes moved to buffer.
    NSMutableData  *dataOut    = [NSMutableData dataWithLength:dataIn.length*kCCBlockSizeAES128];
    
    ccStatus = CCCrypt(encryptOrDecrypt,
                       kCCAlgorithmAES128,
                       kCCOptionPKCS7Padding,
                       symmetricKey.bytes,
                       symmetricKey.length,
                       iv.bytes,
                       dataIn.bytes,
                       dataIn.length,
                       dataOut.mutableBytes,
                       dataOut.length,
                       &cryptBytes);
    
    if (ccStatus != kCCSuccess) {
        HSMDebugLog(@"CCCrypt status: %d", ccStatus);
    }
    
    dataOut.length = cryptBytes;
    
    return dataOut;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

+ (NSData *)dataFromHexString:(NSString *)string
{
    string = [string lowercaseString];
    NSMutableData *data= [NSMutableData new];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i = 0;
    NSInteger length = string.length;
    while (i < length-1) {
        char c = [string characterAtIndex:i++];
        
        if (c < '0' || (c > '9' && c < 'a') || c > 'f')
            continue;
        
        byte_chars[0] = c;
        byte_chars[1] = [string characterAtIndex:i++];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    return [NSData dataWithData:data];
}

@end
