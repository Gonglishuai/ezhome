/**
 * @file    MPHttpRequestManager.h
 * @brief   the manager of HTTP request.
 * @author  Jiao
 * @version 1.0
 * @date    2016-02-03
 *
 */

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

/// the manager of HTTP request.
@interface SHHttpRequestManager : NSObject

+ (void)Get:(NSString * _Nonnull)url Parameters:(NSDictionary * _Nullable)parameters
headerField:(NSDictionary * _Nullable)header
AFTTPInstance:(AFHTTPSessionManager* _Nonnull)managerIns
   complete:(void (^)(id responseObject,NSError* error))complete;

+ (void)Get:(NSString * _Nonnull)url withParameters:(NSDictionary * _Nullable)parameters
 withHeader:(NSDictionary * _Nullable)header
   withBody:(NSDictionary * _Nullable)body
withAFTTPInstance:(AFHTTPSessionManager* _Nonnull)managerIns
 andSuccess:(void (^ _Nullable)(NSURLSessionDataTask * _Nonnull task,
                                NSData * _Nullable responseData))success
 andFailure:(void (^ _Nullable)(NSURLSessionDataTask * _Nonnull task,
                                NSError* _Nullable error))failure;

+ (void)Get:(NSString * _Nonnull)url withParameters:(NSDictionary * _Nullable)parameters
withHeaderField:(NSDictionary * _Nullable)header
withAFTTPInstance:(AFHTTPSessionManager* _Nonnull)managerIns
 andSuccess:(void (^ _Nullable)(NSData * _Nullable responseData))success
 andFailure:(void (^ _Nullable)(NSError*  _Nullable error))failure;

+ (void)Post:(NSString * _Nonnull)url withParameters:(NSDictionary * _Nullable)parameters
  withHeader:(NSDictionary * _Nullable)header
    withBody:(NSDictionary * _Nullable)body
withAFTTPInstance:(AFHTTPSessionManager* _Nonnull)managerIns
  andSuccess:(void (^ _Nullable)(NSURLSessionDataTask * _Nonnull task,
                                 NSData * _Nullable responseData))success
  andFailure:(void (^ _Nullable)(NSURLSessionDataTask * _Nonnull task,
                                 NSError* _Nullable error))failure;

+ (void)Post:(NSString * _Nonnull)url withParameters:(NSDictionary * _Nullable)parameters
withHeaderField:(NSDictionary * _Nullable)header
withAFTTPInstance:(AFHTTPSessionManager* _Nonnull)managerIns
  andSuccess:(void (^ _Nullable)(NSData * _Nullable responseData))success
  andFailure:(void (^ _Nullable)(NSError* _Nullable error))failure;


+ (NSURLSessionDataTask * _Nonnull)Post:(NSString * _Nonnull)url withParameters:(NSDictionary * _Nullable)parameters
                              withFiles:(NSArray <NSDictionary *>* _Nullable)files
                             withHeader:(NSDictionary * _Nullable)header
                      withAFTTPInstance:(AFHTTPSessionManager * _Nonnull)managerIns
                 appendPartWithFiledata:(BOOL)appendPartWithFiledata
                             andSuccess:(void (^ _Nullable)(NSURLSessionDataTask * _Nonnull task,
                                                            NSData * _Nullable responseData))success
                             andFailure:(void (^ _Nullable)(NSURLSessionDataTask * _Nonnull task,
                                                            NSError* _Nullable error))failure;

+ (void)Post:(NSString * _Nonnull)url withParameters:(NSDictionary * _Nullable)parameters
  withHeader:(NSDictionary * _Nullable)header
   withFiles:(NSArray <NSDictionary *>* _Nullable)files
withAFTTPInstance:(AFHTTPSessionManager* _Nonnull)managerIns
  andSuccess:(void (^ _Nullable)(NSURLResponse * _Nullable response,
                                 NSData * _Nullable responseData))success
  andFailure:(void (^ _Nullable)(NSError * _Nullable error))failure;

+ (void)Put:(NSString * _Nonnull)url withParameters:(NSDictionary * _Nullable)parameters
 withHeader:(NSDictionary * _Nullable)header
   withBody:(NSDictionary * _Nullable)body
withAFTTPInstance:(AFHTTPSessionManager* _Nonnull)managerIns
 andSuccess:(void (^ _Nullable)(NSURLSessionDataTask * _Nonnull task,
                                NSData * _Nullable responseData))success
 andFailure:(void (^ _Nullable)(NSURLSessionDataTask * _Nonnull task,
                                NSError * _Nullable error))failure;

+ (void)Put:(NSString * _Nonnull)url  withParameters:(NSDictionary * _Nullable)parameters
withHeaderField:(NSDictionary * _Nullable)header
withAFTTPInstance:(AFHTTPSessionManager* _Nonnull)managerIns
 andSuccess:(void (^ _Nullable)(NSData * _Nullable responseData))success
 andFailure:(void (^ _Nullable)(NSError* _Nullable error))failure;

+ (void)Put:(NSString * _Nonnull)url withParameters:(NSDictionary * _Nullable)parameters
 withHeader:(NSDictionary * _Nullable)header
  withFiles:(NSArray <NSDictionary *>* _Nullable)files
withAFTTPInstance:(AFHTTPSessionManager* _Nonnull)managerIns
 andSuccess:(void (^ _Nullable)(NSURLResponse * _Nullable response,
                                NSData * _Nullable responseData))success
 andFailure:(void (^ _Nullable)(NSError * _Nullable error))failure;

+ (void)Delete:(NSString * _Nonnull)url withParameters:(NSDictionary * _Nullable)parameters
    withHeader:(NSDictionary * _Nullable)header
      withBody:(NSDictionary * _Nullable)body
withAFTTPInstance:(AFHTTPSessionManager* _Nonnull)managerIns
    andSuccess:(void (^ _Nullable)(NSURLSessionDataTask * _Nonnull task,
                                   NSData * _Nullable responseData))success
    andFailure:(void (^ _Nullable)(NSURLSessionDataTask * _Nonnull task,
                                   NSError * _Nullable error))failure;

+ (void)Delete:(NSString * _Nonnull)url withParameters:(NSDictionary * _Nullable)parameters
withHeaderField:(NSDictionary * _Nullable)header
withAFTTPInstance:(AFHTTPSessionManager* _Nonnull)managerIns
    andSuccess:(void (^ _Nullable)(NSData * _Nullable responseData))success
    andFailure:(void (^ _Nullable)(NSError * _Nullable error))failure;

+ (NSURLSessionDownloadTask* _Nonnull)DownloadFile:(NSString * _Nonnull)url
                                   withHeaderField:(NSDictionary * _Nullable)header
                                      atTargetPath:(NSURL * _Nonnull)path
                                         progresss:(nullable void (^)(NSProgress * _Nullable downloadProgress)) downloadProgressBlock
                                 withAFTTPInstance:(AFHTTPSessionManager* _Nonnull)managerIns
                                           success:( void (^ _Nullable )(NSURL * _Nonnull filePath, id _Nonnull responseObject))success
                                           failure:(void (^ _Nullable)(NSError* _Nullable error))failure;

+ (void)mark401:(NSString *_Nullable)url param:(NSDictionary *_Nullable)param header:(NSDictionary *_Nullable)header;

@end

