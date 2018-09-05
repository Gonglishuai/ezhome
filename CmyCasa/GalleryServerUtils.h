//
//  GalleryServerUtils.h
//  CmyCasa
//
//  Created by Berenson Sergei on 1/15/13.
//
//

#import <Foundation/Foundation.h>
#import "CloudFrontCacheMap.h"
#import "DesignBaseClass.h"
#import "BaseManager.h"

@class CommentDO;

typedef void (^ addCommentCompletionBlock)(CommentDO *comment, BOOL success);
typedef void (^ loadGalleryStreamChunkDesigns)(NSString *,BOOL );

@interface GalleryServerUtils : NSObject

typedef void (^ fillDesignExtraInfoBlock)(NSMutableDictionary*);

+ (id)sharedInstance;
- (void)getComments: (NSString*) itemID offset:(NSUInteger)page;
- (Boolean)addComment:(NSString*) itemID :(NSString*) body :(NSString*) parentID;
- (void)addComment:(NSString*)itemID :(NSString*)body :(NSString*)parentID :(NSString*)parentUID withComplition:(addCommentCompletionBlock)completeBlock;
- (BOOL)isLayoutsLoaded;
- (void)loadImageFromUrl:(UIImageView*)currentImage url:(NSString*)url;

@property(nonatomic)CloudFrontCacheMap * cloudCache;
@property(nonatomic)BOOL inMiddleOfrequest;
@end
