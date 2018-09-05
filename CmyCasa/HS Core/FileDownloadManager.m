//
//  FileDownloadManager.m
//  Homestyler
//
//  Created by Tomer Har Yoffi on 11/18/14.
//
//


#import "FileDownloadManager.h"
#import "PackageManager.h"

@implementation FileDownloadManager

static FileDownloadManager *sharedInstance = nil;

+ (FileDownloadManager *)sharedInstance {
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[FileDownloadManager alloc] init];
    });
    
    return sharedInstance;
}

/*
 * By giving file url for download, we use AFNetwork Framework logic to download the file to
 * NSDocumentDirectory, than we read it as NSData obj.
 */

-(void)loadFileFromUrl:(NSString*)fileUrl
               success:(void (^)(NSData* data))success
               failure:(void (^)(AFRKHTTPRequestOperation *operation, NSError *error))failure
              progress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress{
    
    
    if ([ConfigManager isOfflineModeActive] && ![ConfigManager isAnyNetworkAvailable]){
        //offline
        NSData *data = [[PackageManager sharedInstance] getFileByURLString:fileUrl];
        if (success) {
            if (data) {
                success(data);
            }else{
                success(nil);
            }
        }
    }else{
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:fileUrl]];
        
        AFRKHTTPRequestOperation *operation = [[AFRKHTTPRequestOperation alloc] initWithRequest:request];
        
        NSString *fileName = @"download.tmp";
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        __block NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
        
        [operation setCompletionBlockWithSuccess:^(AFRKHTTPRequestOperation *operation, id responseObject) {
            if ([ConfigManager isFileDownloadManagerLogActive]) {
                NSLog(@"Successfully downloaded file to %@", path);
            }
            
            NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
            
            if (success) {
                if (data) {
                    success(data);
                }else{
                    success(nil);
                }
            }
            
        } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
            if ([ConfigManager isFileDownloadManagerLogActive]) {
                NSLog(@"Error: %@", error);
            }
            if (failure)
                failure(operation, error);
        }];
        
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            
            if (progress)
                progress(bytesRead, totalBytesRead, totalBytesExpectedToRead);
            
            if ([ConfigManager isFileDownloadManagerLogActive]) {
                NSLog(@"Download = %f", (float)totalBytesRead / totalBytesExpectedToRead);
            }
        }];
        
        [operation start];
    }
}
@end
