//
//  FileDownloadManager.h
//  Homestyler
//
//  Created by Tomer Har Yoffi on 11/18/14.
//
//

#import <Foundation/Foundation.h>

typedef void(^HSFDCompletionBlock)(NSData* data);
typedef void(^HSFDFailureBlock)(AFRKHTTPRequestOperation *operation, NSError *error);
typedef void(^HSMProgreesBlock)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead);

@interface FileDownloadManager : BaseManager <NSCoding>

+ (FileDownloadManager *)sharedInstance;

-(void)loadFileFromUrl:(NSString*)fileUrl
               success:(HSFDCompletionBlock)success
               failure:(HSFDFailureBlock)failure
              progress:(HSMProgreesBlock)progress;

@end
