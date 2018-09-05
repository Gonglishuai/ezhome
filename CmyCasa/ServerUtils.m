//
//  ServerUtils.m
//  CmyCasa
//
//  Copyright (c) 2012 CmyCasa Inc. All rights reserved.
//

#import "ServerUtils.h"
#import "NotificationAdditions.h"
#import "NSString+JSONHelpers.h"
#import "ProtocolsDef.h"
#import "UIDevice-Hardware.h"
#import "FlurryDefs.h"
#import "MD5Categories.h"
#import "PackageManager.h"


#define MAX_CONCURRENT_OPERATIONS   (3)

@interface ServerUtils ()
{
    NSString* _guid;
    NSOperationQueue* _modelsQueue;
    NSString* _localModelsFileName;
    NSMutableDictionary * _serverASIRequestsRetryQueue;
}
@end

@implementation ServerUtils

static ServerUtils *sharedInstance = nil;

+ (ServerUtils *)sharedInstance {
    
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedInstance = [[ServerUtils alloc] init];
    });
    
    return sharedInstance;
}

-(id)init {
    if ( self = [super init] ) {
        _modelsQueue = [[NSOperationQueue alloc] init];
        [_modelsQueue setMaxConcurrentOperationCount:MAX_CONCURRENT_OPERATIONS];
        _serverASIRequestsRetryQueue=[NSMutableDictionary dictionaryWithCapacity:0];
    }
    return self;
}

- (NSString *)generateGuid
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);    
    NSString* str = [NSString stringWithString:(__bridge NSString *)uuidString];
	CFRelease(uuidString);
	return str;
}


#pragma mark - Models downloading

- (Boolean) areModelsStillDownloading {
    NSLog(@"Download queue size: %lu", (unsigned long)[_modelsQueue.operations count]);
    return [_modelsQueue.operations count] != 0;
}

- (void)downloadModelZip:(NSString*)url
              toFilePath:(NSString*)localFilePath
     withCompletionBlock:(HSModelDownloadCompletionBlock)completion
{
    HSMDebugLog(@"downloadModelZip %@, localPath=%@", url, localFilePath);
    
    // If offline mode is active and there is no connection, fetch the information from
    // the local package.
    if ([ConfigManager isOfflineModeActive] && ![ConfigManager isAnyNetworkAvailable])
    {
        NSData *data = [[PackageManager sharedInstance] getFileByURLString:url];
        
        if(!data)
            [self downloadModelWentWrongOffline:localFilePath];
        
        if(![data writeToFile:localFilePath atomically:YES])
            [self downloadModelWentWrongOffline:localFilePath];
        
        if (completion)
            completion(localFilePath);
        
        return;
    }
   
    NSLog(@"before encoding:%@", url);
    url = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* webStringURL = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"after encoding:%@", webStringURL);

    NSURL  *urlObj = [NSURL URLWithString:webStringURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlObj];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:_modelsQueue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
    
        if (connectionError) {
            [self downloadModelWentWrong:connectionError path:url];
            return;
        }
        
        NSError * error = nil;
        NSString * path = localFilePath;
        [data writeToFile:path options:NSDataWritingAtomic error:&error];
        
        if (error) {
            NSLog(@"Write returned error: %@", [error localizedDescription]);

            [self downloadModelWentWrong:error path:path];
            return;
        }
        
        NSLog(@"File downloaded Succsesfully");
        
        completion(localFilePath);
    }];
}

- (void) cancelAllModelsDownloads {
    [_modelsQueue cancelAllOperations];
}

- (void)downloadModelDoneOffline:(NSString*)filePath
{
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:
     [NSNotification notificationWithName:@"downloadModelFinished" object:nil userInfo:nil]];
}

- (void)downloadModelWentWrongOffline:(NSString*)filePath
{
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:
     [NSNotification notificationWithName:@"downloadModelWentWrong"
                                   object:nil
                                 userInfo:nil]];
}

- (void)downloadModelWentWrong:(NSError *)error path:(NSString*)filePath
{
    HSMDebugLog(@"downloadModelWentWrong error %@", error.debugDescription);
    
    
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
        
//        [Flurry logError:@"downloadModelWentWrong" message:filePath error:error];
    }
#endif
    
   
    if ([[NSFileManager defaultManager] fileExistsAtPath: filePath ] == YES)
        [[NSFileManager defaultManager] removeItemAtPath: filePath error: NULL];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:
     [NSNotification notificationWithName:@"downloadModelWentWrong" object:nil userInfo:nil]];
}

/////////////////////////////////////////////////////////////////////////////////////
//Cube

- (void)uploadNewPhoto:(UIImage*)originalImage completion:(HSCompletionBlock)completion{
    
    NSMutableData *body = [NSMutableData data];
    NSString *BoundaryConstant = @"0xKhTmLbOuNdArY-85E18EE8-0968-481E-9E21-EB5F6F0ED6B7";
    
    NSData * imageData = UIImageJPEGRepresentation([originalImage scaleToFitLargestSide:1024], 0.9);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[[ConfigManager sharedInstance] uploadProfileImage]]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"close" forHTTPHeaderField:@"Proxy-Connection"];
    [request setValue:@"multipart/form-data; charset=utf-8; boundary=0xKhTmLbOuNdArY-85E18EE8-0968-481E-9E21-EB5F6F0ED6B7" forHTTPHeaderField: @"Content-Type"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"s\""] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@", [[UserManager sharedInstance]getSessionId]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSDictionary * tokenDict=[[BaseRO new] generateToken:YES];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"t\""] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@", [tokenDict objectForKey:@"Token"]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"ts\""] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@", [tokenDict objectForKey:@"Time"]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"v\""] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@", API_VERSION] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (imageData) {
        NSLog(@"appending image data\n");
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"photo\"; filename=\"file\""] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error) {
        NSLog(@"Filed to upload image");
        [self showErrorWithCompletion:completion];
    }else{
        
        NSString* encodeRespose = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //NSLog(@"encodeRespose %@", encodeRespose);
        
        encodeRespose = [encodeRespose prepareStringForJSON];
        
        NSError * error;
        NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:[encodeRespose dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
        if (error) {
            HSMDebugLog(@"uploadProfilePhotoInternal json parse error %@", error.debugDescription);
            [self showErrorWithCompletion:completion];
        }else{
            int errCode = [[jsonData objectForKey:@"er"] intValue];
            
            if (errCode != -1)
            {
                HSMDebugLog(@"uploadProfilePhotoInternal server error code=%d", errCode);
                NSString * erMessage=[jsonData objectForKey:@"erMessage"];
                [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:errCode] withPrevGuid:nil];
                [self showErrorWithCompletion:completion];
            }else{
                NSString *   url = [NSString stringWithFormat:@"%@", [jsonData objectForKey:@"url"]];
                [[NSUserDefaults standardUserDefaults] setObject:url forKey:@"profileImage"];
                
                if(completion){
                    completion([[NSUserDefaults standardUserDefaults] objectForKey:@"profileImage"],nil);
                }
            }
        }
    }
}

- (void)showErrorWithCompletion:(HSCompletionBlock)completion {
    dispatch_async(dispatch_get_main_queue(),^(void){
        [[[UIAlertView alloc]initWithTitle:nil
                                   message:NSLocalizedString(@"err_msg_upload_profile_image",@"Failed to upload profile image")
                                  delegate:nil
                         cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"Close")
                         otherButtonTitles: nil] show];
        if(completion){
            completion(nil, NSLocalizedString(@"err_msg_upload_profile_image",@"Failed to upload profile image"));
        }
    });
}


- (void)uploadImage:(UIImage*)image andParmaters:(NSMutableDictionary*)mdict andCallback: (NSString*)callbackName {
     
    _guid = [self generateGuid];
    
    NSMutableData *body = [NSMutableData data];
    NSString *BoundaryConstant = @"0xKhTmLbOuNdArY-FD720D9A-D181-48D2-A2D0-10FB3CF785FB";
    
    NSData* imageData = UIImageJPEGRepresentation(image, 0.9);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[[ConfigManager sharedInstance] g_uploadURL]]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"close" forHTTPHeaderField:@"Connection"];
    [request setValue:@"close" forHTTPHeaderField:@"Proxy-Connection"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"multipart/form-data; charset=utf-8; boundary=0xKhTmLbOuNdArY-FD720D9A-D181-48D2-A2D0-10FB3CF785FB" forHTTPHeaderField: @"Content-Type"];

    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"type\""] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"mobile"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"key\""] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@", _guid] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"v\""] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"1"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];

//    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"checksum\""] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithFormat:@"%@", [imageData md5InBase64]] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (imageData) {
        NSLog(@"appending image data\n");
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file.jpg\"; filename=\"file.jpg\""] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: image/jpeg"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
        if (connectionError) {
            NSString* responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            HSMDebugLog(@"uploadRequestFailed = %@", responseStr );
            
            if (responseStr == nil || [responseStr length] ==0)
            {
                HSMDebugLog(@"UploadFinished server error ");
                [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:
                 [NSNotification notificationWithName:callbackName  object:nil userInfo:@{ @"isSuccess" : @NO, @"responseString": responseStr}]];
            }
        }else{
            NSString* responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            HSMDebugLog(@"uploadRequestFinished = %@", responseStr );
            
            if (responseStr == nil || [responseStr length] ==0)
            {
                HSMDebugLog(@"UploadFinished server error ");
                [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:
                 [NSNotification notificationWithName:callbackName  object:nil userInfo:@{ @"isSuccess" : @NO, @"responseString": responseStr}]];
                return;
            }else{
                //HSMDebugLog(@"processed json: %@", jsonData);
                [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:
                 [NSNotification notificationWithName:callbackName object:nil userInfo:@{ @"isSuccess" : @YES, @"responseString": responseStr}]];
            }
        }
    }];
}

- (void) serverImageAnalysis:(GLKMatrix3)rotationMatrix focalLength:(NSNumber*)focalLength strImageURL:(NSString*)strURL {

#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
        NSDictionary *dictionary =
        [NSDictionary dictionaryWithObjectsAndKeys:strURL,FLURRY_3D_ANALYSIS_REQUEST,
         nil];
//        [HSFlurry logEvent:FLURRY_3D_ANALYSIS withParameters:dictionary];
    }
#endif
    
	HSMDebugLog(@"image analysis request sent");
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[[ConfigManager sharedInstance]g_operationURL]]];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField: @"Content-Type"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [request setHTTPMethod:@"POST"];

	NSDictionary* metadata = @{ @"formatVersion" : @"1.1"};
	NSString* deviceModel = [[UIDevice currentDevice] platform];
    NSMutableDictionary* data = [NSMutableDictionary dictionaryWithDictionary:@{ @"metadata" : metadata, @"u": strURL, @"device": deviceModel}];
    if (focalLength) {
        data[@"focalLengthIn35mmFilm"] = focalLength;
    }
    
    if (GLKVector3AllEqualToScalar(GLKMatrix3MultiplyVector3(rotationMatrix, GLKVector3Make(1, 1, 1)), 0) == false) {
        data[@"rm"] = @[@(rotationMatrix.m00),@(rotationMatrix.m01), @(rotationMatrix.m02),@(rotationMatrix.m10),@(rotationMatrix.m11),@(rotationMatrix.m12),@(rotationMatrix.m20),@(rotationMatrix.m21),@(rotationMatrix.m22)];
    }
	
	NSData* json = [NSJSONSerialization dataWithJSONObject:data options:0 error:NULL];
	NSString* jsonStr = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];

    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"c=%@&t=3", jsonStr] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (connectionError) {
            [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:
             [NSNotification notificationWithName:@"ImageAnalysisFinished" object:nil userInfo:@{ @"isSuccess" : @YES }]];
        }else{
            NSString* d = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            d = [d prepareStringForJSON];
            NSError* error;
            NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:[d dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
            
            if (jsonData == nil) {
                [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:
                 [NSNotification notificationWithName:@"ImageAnalysisFinished" object:nil userInfo:@{ @"isSuccess" : @NO}]];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:
                 [NSNotification notificationWithName:@"ImageAnalysisFinished" object:nil userInfo:@{ @"isSuccess" : @YES, @"jsonData": jsonData }]];
            }
        }
    }];
}

- (void)uploadImage:(UIImage*) image andParmaters:(NSMutableDictionary*)mdict andComplitionBlock:(HSCompletionBlock)completion {
  
    if (!image) {
        if (completion) {
            completion(nil,@"no image");
        }
        return;
    }
    
    _guid = [self generateGuid];
    
    NSMutableData *body = [NSMutableData data];
    NSString *BoundaryConstant = @"0xKhTmLbOuNdArY-FD720D9A-D181-48D2-A2D0-10FB3CF785FB";
    
    NSData* imageData = UIImageJPEGRepresentation(image, 0.9);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[[ConfigManager sharedInstance] g_uploadURL]]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"close" forHTTPHeaderField:@"Connection"];
    [request setValue:@"close" forHTTPHeaderField:@"Proxy-Connection"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"multipart/form-data; charset=utf-8; boundary=0xKhTmLbOuNdArY-FD720D9A-D181-48D2-A2D0-10FB3CF785FB" forHTTPHeaderField: @"Content-Type"];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"type\""] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"mobile"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"key\""] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@", _guid] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"v\""] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"1"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    //    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"checksum\""] dataUsingEncoding:NSUTF8StringEncoding]];
    //    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    //    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    //    [body appendData:[[NSString stringWithFormat:@"%@", [imageData md5InBase64]] dataUsingEncoding:NSUTF8StringEncoding]];
    //    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (imageData) {
        NSLog(@"appending image data\n");
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file.jpg\"; filename=\"file.jpg\""] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: image/jpeg"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        NSString* responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

        if (connectionError) {
            if (completion) {
                completion(nil,responseStr);
            }        }else{
            if (completion) {
                completion(responseStr,nil);
            }
        }
    }];
    
    HSMDebugLog(@"uploadImage");
}

@end
