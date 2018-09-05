//
//  ModelsDownloadHandler.h
//  CmyCasa
//

#import <Foundation/Foundation.h>
#import "ModelsHandler.h"
#import "ServerUtils.h"

@interface HSSingleModelDownloadDecriptor : NSObject

@property (nonatomic, strong) NSString *modelId;
@property (nonatomic, strong) NSString *variationId;

@end


///////////////////////////////////////////////////////
//                  PROTOCOLS                        //
///////////////////////////////////////////////////////

@protocol ModelsDownloadHandlerDelegate <NSObject>

@required
- (void)singleModelDownloadEnded:(HSSingleModelDownloadDecriptor*)modelDescriptor
                     successFlag:(Boolean)isSucceeded;
@optional
- (void)extractAllModelFromDevice:(NSArray*)fullModelList;
- (BOOL)finishedDownloadingModels:(NSArray*)models;
- (void)finishedDownloadingAllModels;
- (void)modelsDownloadedEndedWithErrors:(int)succededDownloadCount
                            errorsCount:(int)errorsCount
                          isSingleModel:(BOOL)isSingleModel;

@end

///////////////////////////////////////////////////////
//                  INTERFACE                        //
///////////////////////////////////////////////////////

@interface ModelsDownloadHandler : NSObject

/*
 *
 */
- (instancetype)initDownloader;

/*
 *
 */
- (void)downloadModels:(NSArray*)models allModels:(NSArray*)allModels;

/*
 *
 */
- (void)cancelDownload;

/*
 *
 */
- (void)downloadSingleModel:(HSSingleModelDownloadDecriptor*)modelDescriptor
                 andVersion:(NSString*)timeStamp;

@property (weak, nonatomic) id<ModelsDownloadHandlerDelegate> delegate;

@end
