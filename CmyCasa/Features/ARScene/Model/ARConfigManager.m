//
//  ARConfigManager.m
//  EZHome
//
//  Created by xiefei on 19/9/17.
//

#import "ARConfigManager.h"
#import "ARModel.h"

@interface ARConfigManager ()

@end

@implementation ARConfigManager
static ARConfigManager *sharedInstance = nil;


+ (ARConfigManager *)sharedInstance {
    
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at
        sharedInstance = [[ARConfigManager alloc] init];
        sharedInstance.baseFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"/ARData"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:sharedInstance.baseFilePath])
            [[NSFileManager defaultManager] createDirectoryAtPath:sharedInstance.baseFilePath withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
    });
    
    return sharedInstance;
}




-(void)clearArModelsData {
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sharedInstance.baseFilePath error:nil];
    for (NSString *fileName in dirContents) {
        NSString* filePath = [sharedInstance.baseFilePath stringByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}

@end
