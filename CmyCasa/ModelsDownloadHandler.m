//
//  ModelsDownloadHandler.m
//  CmyCasa
//
//  Created by Dor Alon on 12/8/12.
//
//

#import "ModelsDownloadHandler.h"
#import "ModelsHandler.h"
#import "Entity.h"
#import "HSMacros.h"

#define MAX_DOWNLOAD_ERRORS 3


@implementation HSSingleModelDownloadDecriptor

- (instancetype)init
{
    self = [super init];
    return self;
}

- (id)copyWithZone:(NSZone*)zone
{
    HSSingleModelDownloadDecriptor *copy = [[[self class] allocWithZone:zone] init];
    
    if (!copy)
        return nil;
    
    copy.modelId = [self.modelId copy];
    copy.variationId = [self.variationId copy];
    
    return copy;
}

@end

///////////////////////////////////////////////////////
//                  INTERFACE                        //
///////////////////////////////////////////////////////

@interface ModelsDownloadHandler ()
{
    NSUInteger _totalDownloadsCount;
    int _totalErrorsCount;
    int _successfultDownloadsCount;
    ServerUtils* _serverUtils;
    ModelsHandler* _modelsHandler;
    NSMutableArray* _allModels;
    HSSingleModelDownloadDecriptor *_singleModelDescriptor;
}
@end

///////////////////////////////////////////////////////
//               IMPLEMENTATION                      //
///////////////////////////////////////////////////////

@implementation ModelsDownloadHandler

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (instancetype) initDownloader {
    
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadModelWentWrong:)
                                                     name:@"downloadModelWentWrong" object:nil];
        
        _serverUtils = [ServerUtils sharedInstance];
        _modelsHandler = [ModelsHandler sharedInstance];
    }

    return self;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)downloadModelFinished:(NSString*)localFilePath
{
    NSLog(@"Download finished for file %@", localFilePath);
    
    RETURN_VOID_ON_NIL(self.delegate);
    
     dispatch_async(dispatch_get_main_queue(),^{
         
        _successfultDownloadsCount++;
        
        if (_singleModelDescriptor)
        {
            [self.delegate singleModelDownloadEnded:_singleModelDescriptor
                                        successFlag:YES];
            return;
        }
        
        NSString* modelId = [[[localFilePath pathComponents] lastObject] stringByDeletingPathExtension];
        NSArray* models = [_allModels filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            Entity* entity = evaluatedObject;
            return [modelId isEqualToString:entity.modelId] || [modelId isEqualToString:entity.variationId ];
        }]];
         
         NSLog(@"The model: %@ appears %lu time(s) in the scene. Will try to load", modelId, (unsigned long)[models count]);
                                 
        if (![self.delegate finishedDownloadingModels:models]) {
            NSLog(@"Did not finish downloading models");
            
            _totalErrorsCount++;
            _successfultDownloadsCount--;
            if (![_serverUtils areModelsStillDownloading]) {
                NSLog(@"No downloads are pending. Notify that we finished with the download process.");
                [self.delegate modelsDownloadedEndedWithErrors:_successfultDownloadsCount
                                                   errorsCount:_totalErrorsCount
                                                 isSingleModel:(_singleModelDescriptor != nil)];
            }
        }
        
        if (_totalErrorsCount + _successfultDownloadsCount == _totalDownloadsCount) {
            [self.delegate finishedDownloadingAllModels];
        }
     });
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) downloadModelWentWrong:(NSNotification *)notification {
    _totalErrorsCount++;
    
    if (_singleModelDescriptor) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(modelsDownloadedEndedWithErrors:errorsCount:isSingleModel:)]) {
            [self.delegate modelsDownloadedEndedWithErrors:_successfultDownloadsCount
                                               errorsCount:_totalErrorsCount
                                             isSingleModel:YES];
        }
    }
    
    else if (_totalErrorsCount + _successfultDownloadsCount == _totalDownloadsCount || _totalErrorsCount >= MAX_DOWNLOAD_ERRORS) {
        [self cancelDownload];
        if (self.delegate && [self.delegate respondsToSelector:@selector(modelsDownloadedEndedWithErrors:errorsCount:isSingleModel:)]) {
            [self.delegate modelsDownloadedEndedWithErrors:_successfultDownloadsCount
                                               errorsCount:_totalErrorsCount
                                             isSingleModel:NO];
        }
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)downloadModels:(NSArray*)models
             allModels:(NSArray*)allModels
{
    [self cancelDownload];
    _allModels = [allModels mutableCopy];
    _singleModelDescriptor = nil;
    _successfultDownloadsCount = 0;
    
    // (1) Look for any models requested if it is in the cache
    NSArray* cachedModels = [_modelsHandler getCachedModelsFromArray:models];
    
    // (2) Find the subset of models that remain to download
    NSPredicate *relativeComplement = [NSPredicate predicateWithFormat:@"NOT SELF IN %@", cachedModels];
    NSArray *remainingModels = [models filteredArrayUsingPredicate:relativeComplement];
    NSMutableDictionary *uniqueRemainingModelsMap = [NSMutableDictionary new];
    
    for (Entity *remainingModel in remainingModels)
    {
        NSString *tmpKey = [NSString stringWithFormat:@"%@_%@", remainingModel.modelId,
                            remainingModel.variationId];
        if (![uniqueRemainingModelsMap objectForKey:tmpKey])
            [uniqueRemainingModelsMap setObject:remainingModel forKey:tmpKey];
    }
    
    NSArray *uniqueRemainingModels = [uniqueRemainingModelsMap allValues];
    
    NSLog(@"I Need to download %lu models.", (unsigned long)[models count]);
    NSLog(@"I Found %lu models in cache.", (unsigned long)[cachedModels count]);
    NSLog(@"I Need to download %lu models from web.", (unsigned long)[remainingModels count]);
    NSLog(@"Out of which %lu models are unique.", (unsigned long)[uniqueRemainingModels count]);
    if ([uniqueRemainingModels count] > 0) {
        // The total downloads that we are going to perform is the unique remaining objects
        // This is an optimization, however some other code rely on this assumption, so be careful
        // here.
        _totalDownloadsCount = [uniqueRemainingModels count];
        for(Entity* entity in uniqueRemainingModels)
        {
            for (Entity *model in [entity uniqueModels])
            {
                NSString* localPath = [_modelsHandler getModelFilePath:model.variationId];
                NSString* url = [_modelsHandler getModelFileUrl:model.modelId
                                                 andVariationId:model.variationId];
                
                HSModelDownloadCompletionBlock downloadCompletionBlock = ^(NSString *filePath){
                    _successfultDownloadsCount++;
                    if (_totalDownloadsCount == _successfultDownloadsCount) {
                        if ([self.delegate respondsToSelector:@selector(extractAllModelFromDevice:)]) {
                            [self.delegate extractAllModelFromDevice:allModels];
                        }
                    }
                };
                
                [_serverUtils downloadModelZip:url
                                    toFilePath:localPath
                           withCompletionBlock:downloadCompletionBlock];
            }
        }

    }else{
        if ([self.delegate respondsToSelector:@selector(extractAllModelFromDevice:)]) {
            [self.delegate extractAllModelFromDevice:allModels];
        }
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)downloadSingleModel:(HSSingleModelDownloadDecriptor*)modelDescriptor
                 andVersion:(NSString*)timeStamp;
{
    [self cancelDownload];
    _totalDownloadsCount = 1;
    _totalErrorsCount = 0;
    _successfultDownloadsCount = 0;
    _singleModelDescriptor = [modelDescriptor copy];
    
    _allModels = nil;
    
    NSString* localPath = [_modelsHandler getModelFilePath:_singleModelDescriptor.variationId];
    
    NSString *modelURL = [_modelsHandler getModelFileUrl:modelDescriptor.modelId                                                                andVariationId:modelDescriptor.variationId];
    
    NSString *tsModelURL = [NSString stringWithFormat:@"%@?s=%@",[_modelsHandler getModelFileUrl:modelDescriptor.modelId
                                                                         andVariationId:modelDescriptor.variationId], timeStamp];
    
    NSString* url = (timeStamp.length) ? tsModelURL : modelURL;
    
    HSModelDownloadCompletionBlock downloadCompletionBlock = ^(NSString *filePath) {
        [self downloadModelFinished:filePath];
    };
    
    if (url) {
        [_serverUtils downloadModelZip:url
                            toFilePath:localPath
                   withCompletionBlock:downloadCompletionBlock];
    }else{
        NSLog(@"Missing url");
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) cancelDownload
{
    [_serverUtils cancelAllModelsDownloads];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void ) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"downloadModelWentWrong"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"downloadModelFinished"
                                                  object:nil];
}
@end
