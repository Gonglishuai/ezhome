//
//  DesignBaseClass.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/9/13.
//
//

#import <Foundation/Foundation.h>
#import "RestkitObjectProtocol.h"
#import "LikeDesignDO.h"

@class DesignGetItemResponse;

typedef enum _ItemType
{
    e3DItem =  1,
    e2DItem =  2,
    eArticle = 3,
    eEmptyRoom= 4
} AssetItemType;

typedef AssetItemType ItemType;

typedef int DesignStatus;

@interface DesignBaseClass : BaseResponse <NSCoding,RestkitObjectProtocol>



@property(nonatomic,strong)NSString * author;

@property(nonatomic) ItemType type;
@property(nonatomic,strong)NSNumber * commentsCount;
@property(nonatomic,strong)NSNumber * productsCount;
@property(nonatomic,strong)NSNumber * tempLikeCount;
@property(nonatomic,strong)NSString * _description;
@property(nonatomic,strong)NSString * _id;
@property(nonatomic,strong)NSString * title;
@property(nonatomic,strong)NSString * uid;
@property(nonatomic,strong)NSString * url;
@property(nonatomic,strong)NSString * uthumb;
@property(nonatomic,strong)NSString * timestamp;
@property(nonatomic)BOOL  isPro;
@property(nonatomic)DesignStatus publishStatus;

@property(nonatomic) BOOL isPublicOrPublished;
@property(nonatomic) BOOL isDesignPublished;
@property(nonatomic) BOOL requestIsActive;
@property(nonatomic) BOOL isFullyLoaded;
@property(nonatomic) NSString * uname;
@property(nonatomic) NSNumber * roomType;
@property(nonatomic) NSMutableArray * images;
@property(nonatomic) NSString * content;


@property(nonatomic) NSString * backgroundImageURL; // Mandatory for design
@property(nonatomic) NSString * originalImageURL;   // Mandatory for design
@property(nonatomic) NSString * editedImageURL;
@property(nonatomic) NSString * maskImageURL;

@property(nonatomic, assign) SavedDesignStatus eSaveDesignStatus;

-(BOOL)isUpdateRequeredForRedesign;
-(void)updateDesignItemWithFullData:(NSMutableDictionary*)dict;
-(void)updateDesignItemWithResponse:(DesignGetItemResponse*)response;

-(id)initWithDict:(NSDictionary*)dict;
-(void)duplicateFromOther:(DesignBaseClass*)original;

- (NSNumber*)getTotalCommentsCount;
-(int)getLikesCountForDesign;
-(BOOL)isUserLikesDesign;
-(void)fillDataFromDict:(NSDictionary*)dict;
-(BOOL)isArticle;
-(BOOL)is2DDesign;
-(BOOL)is3DDesign;



typedef void (^ loadDesignBaseInfoBlock)(BOOL);
typedef void (^ dictionaryResponseBlock)(NSString*);

- (void)createCustomArticle;
- (void)loadGalleryItemExtraInfo :(loadDesignBaseInfoBlock)completeBlock;
- (void)virtualGalleryItemExtraInfo:(dictionaryResponseBlock)completeBlock;
- (void)virtualGalleryItemExtraInfo:(BOOL)richData completionBlock:(dictionaryResponseBlock)completeBlock;
- (BOOL)isDesignBelongsToLoggedInUser;
- (NSString*)getAPITimestamp;

@end


@interface DesignMetadata : NSObject

@property(nonatomic,strong)NSString * designId;
@property(nonatomic,strong)NSString * designTitle;
@property(nonatomic,strong)NSString * designDescription;

@property(nonatomic) BOOL textChanged;

@end
