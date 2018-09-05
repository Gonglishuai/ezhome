//
//  ModelSingleCache.m
//  Homestyler
//
//  Created by Avihay Assouline on 11/23/14.
//
//

#import "ModelSingleCache.h"
#import "ModelsHandler.h"
#import "UIViewController+Helpers.h"
#import "ZipArchive.h"
#import "UIImage+fixOrientation.h"
#import "UIImage+Scale.h"
#import "UIImage+Masking.h"
#import "ZipZap/ZipZap.h"
#import "NSDictionary+Helpers.h"
#import "UIImage+OpenCVWrapper.h"
#import "SaveDesignFlowBaseController.h"
#import "ControllersFactory.h"
#import "ConcealViewController.h"
#import "UIView+Effects.h"
#import "ImageFetcher.h"
#import "NotificationNames.h"
#import "HSMacros.h"
#import "UIView+ReloadUI.h"
#import "ModelsCache.h"
#import "ModelsHandler.h"
#import "HSCryptograpy.h"

#define OBJECT_SCALE (0.01f) // 1 unit = 1 cm

@implementation ModelSingleCache

@synthesize mesh=_mesh, metadata=_metadata, texInfo=_texInfo;

////////////////////////////////////////////////////////////////////////////////////////////////////

-(id)initWithModelId:(NSString*)modelId
         variationId:(NSString*)variationId
               queue:(dispatch_queue_t)queue
{
    if (self = [super init]) {
        _queue = queue;
        self.modelId = modelId;
        self.variationId = variationId;
        self.count = 0;
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)loadWithGlobalScale:(float)globalScale andCompressFactor:(int)compressFactor
{
    if (self.mesh != nil) {
        self.count += 1;
        return;
    }
    
    dispatch_barrier_sync(_queue, ^{
        if (self.mesh == nil) {
            NSArray* data = [self loadModelComponentsFromZipWithGlobalScale:globalScale
                                           andCompressFactor:compressFactor];
           
            if (data) {
                
                AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
                __block GLKTextureInfo* texInfo = nil;
                NSDictionary* texOpt = @{GLKTextureLoaderApplyPremultiplication:@YES};
                dispatch_semaphore_t sema = dispatch_semaphore_create(0);
                if (sema != NULL) {
                    [[appDelegate textureLoader] textureWithContentsOfData:data[1]
                                                                   options:texOpt
                                                                     queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
                                                         completionHandler:^(GLKTextureInfo *textureInfo, NSError *outError) {
                        texInfo = textureInfo;
                        
                        dispatch_semaphore_signal(sema);
                    }];
                    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
                    self.texInfo = texInfo;
                    self.mesh = data[0];
                    self.metadata = data[2];
                }
            }
        }
        if (self.mesh) self.count += 1;
    });
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)unload {
    self.count -= 1;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)loadMipmapTexture:(GLKTextureInfo*)texInfo
{
    if (texInfo) {
        GLuint name = texInfo.name;
        glBindTexture(GL_TEXTURE_2D, name);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        
        
        glGenerateMipmap(GL_TEXTURE_2D);
        
        int err = glGetError();
        if (err != GL_NO_ERROR)
            NSLog(@"Error uploading texture. glError: 0x%04X", err);
        
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)dealloc {
    self.mesh = nil;
    
    self.metadata = nil;
    if (self.texInfo) {
        GLuint name = self.texInfo.name;
        glDeleteTextures(1, &name);
        self.texInfo = nil;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSArray*)loadModelComponentsFromZipWithGlobalScale:(float)globalScale
                     andCompressFactor:(int)compressFactor
{
    @autoreleasepool {
        NSDictionary* files = nil;
        if ([[ModelsHandler sharedInstance] useEncryption]) {
            files = [self extractModelZip2];
        } else {
            files = [self extractModelZip:self.variationId];
        }
        
        if (files && files[@"model.obj"]) {
            NSDictionary* metaData = [NSDictionary dictionaryWithData:files[@"metadata.plist"]];
            NSString* objFile = [[NSString alloc] initWithData:files[@"model.obj"] encoding:NSASCIIStringEncoding]; //Replaced from NSUTF8StringEncoding
            
            GraphicObject* graphicObj = [[GraphicObject alloc] initWithOBJFormat:objFile scale:OBJECT_SCALE parseTexture:YES];
            if (graphicObj == nil) {
                NSLog(@"Can't create model.obj from DAT file");
                return nil;
            }
            
            objFile = nil;
            float diagonalBound  = [graphicObj diagonalBoundingBox];
            if(globalScale>0)
            {
                diagonalBound/=globalScale;
            }
            
            NSData* textureImageData = files[@"texture.pvr"];
            if (textureImageData == nil) {
                if (files[@"texture_base.jpg"] && files[@"texture_mask.png"]) {
                    UIImage* base = [self loadTextureToMemory:files[@"texture_base.jpg"]
                                                withObjVolume:diagonalBound
                                            andCompressFactor:compressFactor];
                    
                    UIImage* mask = [self loadTextureToMemory:files[@"texture_mask.png"]
                                                withObjVolume:diagonalBound
                                            andCompressFactor:compressFactor];
                    
                    textureImageData = UIImagePNGRepresentation([base imageByMaskingUsingImage:mask]);
                } else {
                    textureImageData = UIImagePNGRepresentation([self loadTextureToMemory:files[@"texture.png"]
                                                                            withObjVolume:diagonalBound
                                                                        andCompressFactor:compressFactor]);
                }
            } else {
                HSMDebugLog(@"pvr: %@", self.variationId);
            }
            
            if (textureImageData == nil) {
                return nil;
            }
            NSString* strModelzIndex = [metaData valueForKey:@"z-index"];
            if (!strModelzIndex) {
                strModelzIndex = @"300";
            }
            NSDictionary* metaDict  = [NSDictionary dictionaryWithObject:strModelzIndex forKey:Z_INDEX];
            
            return @[graphicObj, textureImageData, metaDict, files[@"model.obj"]];
        }
        
        return nil;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (UIImage*)loadTextureToMemory:(NSData*)imgData withObjVolume:(float)volume andCompressFactor:(int)compressFactor
{
    UIImage* textureImageData = nil;
    int compress = 1;
    
    if (volume < 2)
    {
        compress = 2;
    }

    compress = MAX(compress,compressFactor);
    //HSMDebugLog(@"Compress texture volume:%f compress:%d",volume,compress);
    if( compress != 1)
    {
        UIImage* pngImage = [ UIImage imageWithData:imgData];
        textureImageData =  [pngImage resizeImageByFactor:1.0f / compress];
    }
    else
    {
        textureImageData = [UIImage imageWithData:imgData];
    }
    return textureImageData;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSDictionary*)extractModelZip2
{
    NSMutableDictionary* ret = nil;
    @autoreleasepool
    {
        NSError * error;
        
        // (1) Find and load the model from disk
        NSString *filePath = [[ModelsHandler sharedInstance] getModelFilePath:self.variationId];
        NSData *zipData = [NSData dataWithContentsOfFile:filePath];
        
        // (2) Decrypt the model data where the key is GUID without the hyphens.
        
         NSLog(@"TRY extract model from zip file with key %@", self.variationId);
        NSString * publicKey = [self.variationId stringByReplacingOccurrencesOfString:@"-" withString:@""];
        zipData = [HSCryptograpy decryptData:zipData withPublicKey:publicKey];
        
        ZZArchive* za = [ZZArchive archiveWithData:zipData error:&error];
        
        // (3) Check if the extraction worked. If not, remove the file from disk as it cannot be used anymore
        if (!za || za.entries.count == 0) {
            NSLog(@"Excpetion: Cannot extract model from zip file");
            
            NSLog(@"TRY extract model from zip file with key %@", self.modelId);
            NSString * publicKey = [self.modelId stringByReplacingOccurrencesOfString:@"-" withString:@""];
            NSData *zipData2 = [NSData dataWithContentsOfFile:filePath];
            zipData2 = [HSCryptograpy decryptData:zipData2 withPublicKey:publicKey];
            
            za = [ZZArchive archiveWithData:zipData2 error:&error];
            
            if (!za || za.entries.count == 0) {
                NSLog(@"Excpetion: Cannot extract model from zip file");

                NSFileManager* fm = [[NSFileManager alloc] init];
                [fm removeItemAtPath:filePath error:NULL];
                return nil;
            }
        }
        
        // (4) Add every file in the archive to the dictionary and return to user
        ret = [NSMutableDictionary dictionary];
        for (ZZArchiveEntry* entry in za.entries) {
            NSData * data = [entry newDataWithError:nil];
            [ret setObject:data forKey:entry.fileName];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:ret];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSDictionary*) extractModelZip:(NSString*)modelId {
    ModelsHandler* modelsHandler = [ModelsHandler sharedInstance];
    NSString *objPath =  [NSString stringWithFormat:@"%@/model.obj", [modelsHandler getModelsPath]];
    NSString *pvrPath =  [NSString stringWithFormat:@"%@/texture.pvr", [modelsHandler getModelsPath]];
    NSString *pngPath =  [NSString stringWithFormat:@"%@/texture.png", [modelsHandler getModelsPath]];
    NSString *jpgPath =  [NSString stringWithFormat:@"%@/texture_base.jpg", [modelsHandler getModelsPath]];
    NSString *maskPath =  [NSString stringWithFormat:@"%@/texture_mask.png", [modelsHandler getModelsPath]];
    NSString *plistPath =  [NSString stringWithFormat:@"%@/metadata.plist", [modelsHandler getModelsPath]];
    NSFileManager* fm = [[NSFileManager alloc] init];
    [fm removeItemAtPath:jpgPath error:NULL];
    [fm removeItemAtPath:pngPath error:NULL];
    [fm removeItemAtPath:maskPath error:NULL];
    [fm removeItemAtPath:objPath error:NULL];
    [fm removeItemAtPath:pvrPath error:NULL];
    [fm removeItemAtPath:plistPath error:NULL];
    
    NSString  *filePath = [modelsHandler getModelFilePath:modelId];
    
    ZipArchive* za = [[ZipArchive alloc] init];
    BOOL ret = NO;
    if( [za UnzipOpenFile:filePath] ) {
        if( [za UnzipFileTo:[modelsHandler getModelsPath] Password:@"test" overWrite:YES] != NO ) {
            ret = YES;
        }
        
        [za UnzipCloseFile];
        za = nil;
    }
    if (ret == NO) return nil;
    
    NSMutableDictionary* d = [[NSMutableDictionary alloc] init];
    d[@"model.obj"] = [NSData dataWithContentsOfFile:objPath];
    if ([fm fileExistsAtPath:plistPath]) {
        d[@"metadata.plist"] = [NSData dataWithContentsOfFile:plistPath];
    }
    if ([fm fileExistsAtPath:pvrPath]) {
        d[@"texture.pvr"] = [NSData dataWithContentsOfFile:pvrPath];
    }
    
    if ([fm fileExistsAtPath:pngPath]) {
        d[@"texture.png"] = [NSData dataWithContentsOfFile:pngPath];
    }
    if ([fm fileExistsAtPath:jpgPath]) {
        d[@"texture_base.jpg"] = [NSData dataWithContentsOfFile:jpgPath];
    }
    if ([fm fileExistsAtPath:maskPath]) {
        d[@"texture_mask.png"] = [NSData dataWithContentsOfFile:maskPath];
    }
    [fm removeItemAtPath:jpgPath error:NULL];
    [fm removeItemAtPath:pngPath error:NULL];
    [fm removeItemAtPath:maskPath error:NULL];
    [fm removeItemAtPath:objPath error:NULL];
    [fm removeItemAtPath:pvrPath error:NULL];
    [fm removeItemAtPath:plistPath error:NULL];
        
    return [NSDictionary dictionaryWithDictionary:d];
}

@end
