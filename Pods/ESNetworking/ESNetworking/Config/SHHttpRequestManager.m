/**
 * @file    MPHttpRequestManager.m
 * @brief   the manager of HTTP request.
 * @author  Jiao
 * @version 1.0
 * @date    2016-02-03
 *
 */

#import "SHHttpRequestManager.h"
#import "AFNetworking.h"
#import "SHRequestTool.h"
#import "MGJRouter.h"

#ifdef DEBUG // 调试状态打开log功能
#define SHString [NSString stringWithFormat:@"%s", __FILE__].lastPathComponent
#define SHLog(...) printf("%s %s[%lf]:\n%s 第%d行:\n%s\n\n", [[NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterFullStyle] UTF8String], [[[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey] UTF8String], [[NSDate date] timeIntervalSince1970],[SHString UTF8String] ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String])
#else   //发布状态关闭log功能
#define SHLog(...)
#endif

@implementation SHHttpRequestManager

#pragma mark - Get

+ (void)Get:(NSString *)url Parameters:(NSDictionary *)parameters headerField:(NSDictionary *)header AFTTPInstance:(AFHTTPSessionManager *)managerIns complete:(void (^)(id responseObject, NSError *error))complete {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:url parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        if (complete) {
            complete(responseObject,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (complete) {
            complete(nil,error);
        }
    }];
    
}

+ (void)Get:(NSString *)url withParameters:(NSDictionary *)parameters
 withHeader:(NSDictionary *)header
   withBody:(NSDictionary *)body
withAFTTPInstance:(AFHTTPSessionManager*)managerIns
 andSuccess:(void (^)(NSURLSessionDataTask *, NSData *))success
 andFailure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    
    NSMutableString *newURL = [NSMutableString stringWithString:url];
    NSDictionary *newParameters;
    
    if (parameters) {
        [newURL appendString:@"?"];
        [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [newURL appendString:[NSString stringWithFormat:@"%@=%@&",key,obj]];
        }];
        newURL = [NSMutableString stringWithString:[newURL substringToIndex:newURL.length - 1]];
        
        
    }
    
    if (body) {
        
        newParameters = body;
    }
    SHLog(@"url:%@\nheader:%@\nbody:%@\n",url, header, parameters);
    [SHHttpRequestManager requestMethod:@"Get"
                                withURL:newURL
                         withParameters:newParameters
                        withHeaderField:header
                           withProgress:nil
                      withAFTTPInstance:managerIns
                             andSuccess:success
                             andFailure:failure];
}


+ (void)Get:(NSString *)url withParameters:(NSDictionary *)parameters
withHeaderField:(NSDictionary *)header
withAFTTPInstance:(AFHTTPSessionManager*)managerIns
 andSuccess:(void (^)(NSData * responseData))success
 andFailure:(void (^)(NSError* error))failure
{
    [SHHttpRequestManager requestMethod:@"Get"
                                withURL:url
                         withParameters:parameters
                        withHeaderField:header
                           withProgress:nil
                      withAFTTPInstance:managerIns
                             andSuccess:^(NSURLSessionDataTask * _Nonnull task,
                                          NSData *responseData)
     {
         if (success)
         {
             success(responseData);
         }
     }
                             andFailure:^(NSURLSessionDataTask * _Nonnull task, NSError *error)
     {
         if (failure)
         {
             failure(error);
         }
     }];
}


#pragma mark - Post

+ (void)Post:(NSString *)url withParameters:(NSDictionary *)parameters
  withHeader:(NSDictionary *)header
    withBody:(NSDictionary *)body
withAFTTPInstance:(AFHTTPSessionManager*)managerIns
  andSuccess:(void (^)(NSURLSessionDataTask *, NSData *responseData))success
  andFailure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    
    NSMutableString *newURL = [NSMutableString stringWithString:url];
    NSDictionary *newParameters;
    
    if (parameters) {
        [newURL appendString:@"?"];
        [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [newURL appendString:[NSString stringWithFormat:@"%@=%@&",key,obj]];
        }];
        newURL = [NSMutableString stringWithString:[newURL substringToIndex:newURL.length - 1]];
    }
    
    if (body) {
        
        newParameters = body;
    }
    
    [SHHttpRequestManager requestMethod:@"Post"
                                withURL:newURL
                         withParameters:newParameters
                        withHeaderField:header
                           withProgress:nil
                      withAFTTPInstance:managerIns
                             andSuccess:success
                             andFailure:failure];
}


+ (void)Post:(NSString *)url withParameters:(NSDictionary *)parameters
withHeaderField:(NSDictionary *)header
withAFTTPInstance:(AFHTTPSessionManager*)managerIns
  andSuccess:(void (^)(NSData *responseData))success
  andFailure:(void (^)(NSError* error))failure
{
    [SHHttpRequestManager requestMethod:@"Post"
                                withURL:url
                         withParameters:parameters
                        withHeaderField:header
                           withProgress:nil
                      withAFTTPInstance:managerIns
                             andSuccess:^(NSURLSessionDataTask * _Nonnull task,
                                          NSData *responseData)
     {
         if (success)
         {
             success(responseData);
         }
     }
                             andFailure:^(NSURLSessionDataTask * _Nonnull task, NSError *error)
     {
         if (failure)
         {
             failure(error);
         }
     }];
}


+ (NSURLSessionDataTask *)Post:(NSString *)url withParameters:(NSDictionary *)parameters
                     withFiles:(NSArray <NSDictionary *>*)files
                    withHeader:(NSDictionary *)header
             withAFTTPInstance:(AFHTTPSessionManager*)managerIns
        appendPartWithFiledata:(BOOL)appendPartWithFiledata
                    andSuccess:(void (^)(NSURLSessionDataTask *, NSData *))success
                    andFailure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    
    [SHHttpRequestManager cleanRequestHeader:managerIns];
    if (header) {
        [header enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [managerIns.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    SHLog(@"url:%@\nheader:%@\nbody:%@\n",url, header, parameters);
#pragma mark - POST 上传图片 暂未使用, 未做签名处理
    return [managerIns POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [files enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (appendPartWithFiledata)
                [formData appendPartWithFileData:obj[@"data"] name:obj[@"name"] fileName:obj[@"fileName"] mimeType:obj[@"type"]];
            else
                [formData appendPartWithFileURL:obj[@"filename"] name:obj[@"name"] error:nil];
            
        }];
        
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        SHLog(@"网络请求失败:%@",error);
        if (![SHRequestTool statueIsOverdue:((NSHTTPURLResponse *)task.response).statusCode]) {
            
        }
        if (failure) {
            failure(task,error);
        }
    }];
}

+ (void)Post:(NSString * _Nonnull)url withParameters:(NSDictionary * _Nullable)parameters
  withHeader:(NSDictionary * _Nullable)header
   withFiles:(NSArray <NSDictionary *>* _Nullable)files
withAFTTPInstance:(AFHTTPSessionManager* _Nonnull)managerIns
  andSuccess:(void (^ _Nullable)(NSURLResponse * _Nullable response,
                                 NSData * _Nullable responseData))success
  andFailure:(void (^ _Nullable)(NSError * _Nullable error))failure
{
    [SHHttpRequestManager cleanRequestHeader:managerIns];
    if (header)
    {
        [header enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop)
         {
             [managerIns.requestSerializer setValue:obj forHTTPHeaderField:key];
         }];
    }
    
    SHLog(@"url:%@\nheader:%@\nbody:%@\n",url, header, parameters);
    // prepare the request
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [managerIns.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:url relativeToURL:managerIns.baseURL] absoluteString] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [files enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [formData appendPartWithFileData:obj[@"data"] name:obj[@"name"] fileName:obj[@"fileName"] mimeType:obj[@"type"]];
        }];
    } error:&serializationError];
    //    NSMutableURLRequest *request = [
    //                                    requestWithMethod:@"PUT"
    //                                    URLString:
    //                                    error:&serializationError];
    
    if (serializationError)
    {
        if (failure)
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(serializationError);
            });
#pragma clang diagnostic pop
        }
    }
    
    __block NSURLSessionDataTask *task = [managerIns uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        
        if (![SHRequestTool statueIsOverdue:((NSHTTPURLResponse *)response).statusCode]) {
            if (error) {
                SHLog(@"网络请求失败:%@",error);
                if (failure) {
                    failure(error);
                }
            } else {
                if (success) {
                    success(response, responseObject);
                }
            }
        } else {
            [SHHttpRequestManager mark401:url param:parameters header:header];
            SHLog(@"request %@ :401",url);
            if (failure) {
                failure(error);
            }
        }
    }];
    
    [task resume];
    
}

#pragma mark - Put


+ (void)Put:(NSString *)url withParameters:(NSDictionary *)parameters
 withHeader:(NSDictionary *)header
   withBody:(NSDictionary *)body
withAFTTPInstance:(AFHTTPSessionManager*)managerIns
 andSuccess:(void (^)(NSURLSessionDataTask *, NSData *))success
 andFailure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    
    NSMutableString *newURL = [NSMutableString stringWithString:url];
    NSDictionary *newParameters;
    
    if (parameters) {
        [newURL appendString:@"?"];
        [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [newURL appendString:[NSString stringWithFormat:@"%@=%@&",key,obj]];
        }];
        newURL = [NSMutableString stringWithString:[newURL substringToIndex:newURL.length - 1]];
    }
    
    if (body) {
        
        newParameters = body;
    }
    
    [SHHttpRequestManager requestMethod:@"Put"
                                withURL:newURL
                         withParameters:newParameters
                        withHeaderField:header
                           withProgress:nil
                      withAFTTPInstance:managerIns
                             andSuccess:success
                             andFailure:failure];
}

+ (void)Put:(NSString *)url  withParameters:(NSDictionary *)parameters
withHeaderField:(NSDictionary *)header
withAFTTPInstance:(AFHTTPSessionManager*)managerIns
 andSuccess:(void (^)(NSData *responseData))success
 andFailure:(void (^)(NSError* error))failure
{
    [SHHttpRequestManager requestMethod:@"Put"
                                withURL:url
                         withParameters:parameters
                        withHeaderField:header
                           withProgress:nil
                      withAFTTPInstance:managerIns
                             andSuccess:^(NSURLSessionDataTask * _Nonnull task,
                                          NSData *responseData)
     {
         if (success)
             success(responseData);
     }
                             andFailure:^(NSURLSessionDataTask * _Nonnull task, NSError *error)
     {
         if (failure)
             failure(error);
     }];
}

+ (void)Put:(NSString *)url withParameters:(NSDictionary *)parameters
 withHeader:(NSDictionary *)header
  withFiles:(NSArray <NSDictionary *>*)files
withAFTTPInstance:(AFHTTPSessionManager*)managerIns
 andSuccess:(void (^)(NSURLResponse *,
                      NSData *))success
 andFailure:(void (^)(NSError *))failure
{
    [SHHttpRequestManager cleanRequestHeader:managerIns];
    if (header)
    {
        [header enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop)
         {
             [managerIns.requestSerializer setValue:obj forHTTPHeaderField:key];
         }];
    }
    
    SHLog(@"url:%@\nheader:%@\nbody:%@\n",url, header, parameters);
    // prepare the request
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [managerIns.requestSerializer multipartFormRequestWithMethod:@"PUT" URLString:[[NSURL URLWithString:url relativeToURL:managerIns.baseURL] absoluteString] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [files enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [formData appendPartWithFileData:obj[@"data"] name:obj[@"name"] fileName:obj[@"fileName"] mimeType:obj[@"type"]];
        }];
        
    } error:&serializationError];
    //    NSMutableURLRequest *request = [
    //                                    requestWithMethod:@"PUT"
    //                                    URLString:
    //                                    error:&serializationError];
    
    if (serializationError)
    {
        if (failure)
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(serializationError);
            });
#pragma clang diagnostic pop
        }
    }
    
    __block NSURLSessionDataTask *task = [managerIns uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        
        if (![SHRequestTool statueIsOverdue:((NSHTTPURLResponse *)response).statusCode]) {
            if (error) {
                SHLog(@"网络请求失败:%@",error);
                if (failure) {
                    failure(error);
                }
            } else {
                if (success) {
                    success(response, responseObject);
                }
            }
        } else {
            [SHHttpRequestManager mark401:url param:parameters header:header];
            SHLog(@"request %@ :401",url);
            if (failure) {
                failure(error);
            }
        }
    }];
    
    [task resume];
}

#pragma mark - Delete

+ (void)Delete:(NSString *)url withParameters:(NSDictionary *)parameters
    withHeader:(NSDictionary *)header
      withBody:(NSDictionary *)body
withAFTTPInstance:(AFHTTPSessionManager*)managerIns
    andSuccess:(void (^)(NSURLSessionDataTask *, NSData *))success
    andFailure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    
    NSMutableString *newURL = [NSMutableString stringWithString:url];
    NSDictionary *newParameters;
    
    if (parameters) {
        [newURL appendString:@"?"];
        [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [newURL appendString:[NSString stringWithFormat:@"%@=%@&",key,obj]];
        }];
        newURL = [NSMutableString stringWithString:[newURL substringToIndex:newURL.length - 1]];
    }
    
    if (body) {
        
        newParameters = body;
    }
    
    [SHHttpRequestManager requestMethod:@"Delete"
                                withURL:newURL
                         withParameters:newParameters
                        withHeaderField:header
                           withProgress:nil
                      withAFTTPInstance:managerIns
                             andSuccess:success
                             andFailure:failure];
}


+ (void)Delete:(NSString *)url withParameters:(NSDictionary *)parameters
withHeaderField:(NSDictionary *)header
withAFTTPInstance:(AFHTTPSessionManager*)managerIns
    andSuccess:(void (^)(NSData *responseData))success
    andFailure:(void (^)(NSError* error))failure
{
    [SHHttpRequestManager requestMethod:@"Delete"
                                withURL:url
                         withParameters:parameters
                        withHeaderField:header
                           withProgress:nil
                      withAFTTPInstance:managerIns
                             andSuccess:^(NSURLSessionDataTask * _Nonnull task,
                                          NSData *responseData)
     {
         if (success)
         {
             success(responseData);
         }
     }
                             andFailure:^(NSURLSessionDataTask * _Nonnull task, NSError *error)
     {
         if (failure)
             failure(error);
     }];
}


+ (NSURLSessionDownloadTask*)DownloadFile:(NSString *)url
                          withHeaderField:(NSDictionary *)header
                             atTargetPath:(NSURL *)path
                                progresss:(nullable void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                        withAFTTPInstance:(AFHTTPSessionManager*)managerIns
                                  success:(void (^)(NSURL *filePath, id responseObject))success
                                  failure:(void (^)(NSError* error))failure
{
    [SHHttpRequestManager cleanRequestHeader:managerIns];
    // populate the headers
    if (header)
    {
        [header enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop)
         {
             [managerIns.requestSerializer setValue:obj forHTTPHeaderField:key];
         }];
    }
    SHLog(@"url:%@\nheader:%@\n",url, header);
#pragma mark - 下载图片 暂未使用未做签名处理
    // prepare the request
    NSError *serializationError = nil;
    NSMutableURLRequest *request =
    [managerIns.requestSerializer
     requestWithMethod:@"GET"
     URLString:[[NSURL URLWithString:url relativeToURL:managerIns.baseURL] absoluteString]
     parameters:nil
     error:&serializationError];
    if (serializationError)
    {
        SHLog(@"网络请求失败:%@",serializationError);
        if (failure)
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(dispatch_get_main_queue(), ^{
                SHLog(@"FAILED: ACSAPIManager DownloadFile");
                failure(serializationError);
            });
#pragma clang diagnostic pop
        }
    }
    
    __block NSURLSessionDownloadTask *dataTask = nil;
    dataTask =
    [managerIns
     downloadTaskWithRequest:request
     progress:^(NSProgress * _Nonnull downloadProgress) {
         dispatch_async(dispatch_get_main_queue(), ^{
             if (downloadProgressBlock)
                 downloadProgressBlock(downloadProgress);
         });
     }
     destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response)
     {
         return path;
     }
     completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error)
     {
         if (error)
         {
             SHLog(@"网络请求失败:%@",error);
             if (failure)
             {
                 SHLog(@"FAILED: ACSAPIManager DownloadFile");
                 failure(error);
             }
         }
         else if (success)
             success(filePath, response);
     }];
    
    [dataTask resume];
    
    return dataTask;
}


#pragma mark - Public Method
+ (void)requestMethod:(NSString*)method
              withURL:(NSString *)url
       withParameters:(NSDictionary *)parameters
      withHeaderField:(NSDictionary *)header
         withProgress:(void (^)(NSProgress *progress))downloadProgress
    withAFTTPInstance:(AFHTTPSessionManager*)managerIns
           andSuccess:(void (^)(NSURLSessionDataTask * task,
                                NSData *responseData))success
           andFailure:(void (^)(NSURLSessionDataTask * task,
                                NSError* error))failure
{
    NSURLSessionDataTask *dataTask =
    [SHHttpRequestManager dataTaskWithHTTPMethod:[method uppercaseString]
                                     headerField:header
                                       URLString:url
                                      parameters:parameters
                               withAFTTPInstance:managerIns
                                  uploadProgress:nil
                                downloadProgress:nil
                                         success:^(NSURLSessionDataTask * _Nonnull task,
                                                   id  _Nullable responseObject)
     {
         if (success)
         {
             success(task,responseObject);
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         SHLog(@"网络请求失败:%@",error);
         if ([SHRequestTool statueIsOverdue:((NSHTTPURLResponse *)task.response).statusCode])
         {
             [SHHttpRequestManager mark401:url param:parameters header:header];
             SHLog(@"request %@ :401  %@",url,parameters);
         }
         if (failure)
         {
             failure(task,error);
         }
     }];
    
    [dataTask resume];
}

#pragma mark -
+ (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                     headerField:(NSDictionary *)header
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                               withAFTTPInstance:(AFHTTPSessionManager*)managerIns
                                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    [SHHttpRequestManager cleanRequestHeader:managerIns];
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [managerIns.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URLString relativeToURL:managerIns.baseURL] absoluteString] parameters:parameters error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(managerIns.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    header = [SHRequestTool updateHeader:header withRequest:request];
    if (header) {
        [header enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key,
                                                    id  _Nonnull obj,
                                                    BOOL * _Nonnull stop)
         {
             [managerIns.requestSerializer setValue:obj forHTTPHeaderField:key];
             [request setValue:obj forHTTPHeaderField:key];
         }];
    }
    
    SHLog(@"url:%@\nheader:%@\nbody:%@",URLString,header,parameters);
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [managerIns dataTaskWithRequest:request
                                uploadProgress:uploadProgress
                              downloadProgress:downloadProgress
                             completionHandler:^(NSURLResponse * __unused response,
                                                 id responseObject,
                                                 NSError *error)
                {
                    if (error) {
                        if (failure) {
                            failure(dataTask, error);
                        }
                    } else {
                        if (success) {
                            success(dataTask, responseObject);
                        }
                    }
                }];
    
    return dataTask;
}

#pragma mark - Clean Header
+ (void)cleanRequestHeader:(AFHTTPSessionManager *)manager
{
    NSDictionary * requestHeader = manager.requestSerializer.HTTPRequestHeaders;
    [requestHeader enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        [manager.requestSerializer setValue:nil
                         forHTTPHeaderField:key];
    }];
}

#pragma mark - 401
+ (void)mark401:(NSString *)url
          param:(NSDictionary *)param
         header:(NSDictionary *)header
{
    NSDictionary *dict = @{
                           @"event" : @"401",
                           @"url" : url,
                           @"parameters": param ?[param description] : @"",
                           @"header" : header?[header description]:@""
                           };
    [MGJRouter openURL:@"/ESFoundation/Analysis" withUserInfo:dict completion:nil];
}

@end

