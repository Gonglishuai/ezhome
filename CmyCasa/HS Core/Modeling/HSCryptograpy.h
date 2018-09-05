//
//  HSCryptograpy.h
//  Homestyler
//
//  Created by Avihay Assouline on 12/19/14.
//
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

///////////////////////////////////////////////////////
//                  INTERFACE                        //
///////////////////////////////////////////////////////

@interface HSCryptograpy : NSObject

/*
 *  Decrypt data that was encrypted using the HSM convention
 *  For the convention please address the backend team's documentation (or just follow the code)
 */
+ (NSData*)decryptData:(NSData*)data
         withPublicKey:(NSString*)key;


@end
