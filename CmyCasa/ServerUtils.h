//
//  ServerUtils.h
//  CmyCasa
//
//  Copyright (c) 2012 CmyCasa Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "GalleryServerUtils.h"

typedef void(^HSModelDownloadCompletionBlock)(NSString *filePath);

typedef enum
{
    eImageNotUpload,
    eImageUploadStarted,
    eImageUploaded,
    eImageUploadedFailed,
} UploadState;

@interface ServerUtils : NSObject

+ (id)sharedInstance;
- (void)uploadImage:(UIImage*) image andParmaters:(NSMutableDictionary*)mdict andCallback: (NSString*)callbackName;
- (void)uploadImage:(UIImage*) image andParmaters:(NSMutableDictionary*)mdict andComplitionBlock:(HSCompletionBlock)completion;
- (void)uploadNewPhoto:(UIImage*)originalImage completion:(HSCompletionBlock)completion;
- (void)serverImageAnalysis:(GLKMatrix3)rotationMatrix focalLength:(NSNumber*)focalLength strImageURL:(NSString*) strURL;
- (void)downloadModelZip:(NSString*)url toFilePath:(NSString*)localFilePath withCompletionBlock:(HSModelDownloadCompletionBlock)completion;
- (void)cancelAllModelsDownloads;
- (Boolean)areModelsStillDownloading;
- (NSString *)generateGuid;
@end
