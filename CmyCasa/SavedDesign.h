//
//  SavedDesign.h
//  CmyCasa
//
//  Copyright (c) 2012 CmyCasa Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CMMotionManager.h>
#import "SavedGyroData.h"
#import "SaveReminderItem.h"
#import "Entity.h"
#import "SimpleCamera.h"

typedef enum {
    SAVED_DESIGN_STATUS_NEW = 0,
    SAVED_DESIGN_STATUS_SAVED,
    SAVED_DESIGN_STATUS_AUTOSAVE,
    SAVED_DESIGN_STATUS_WAITING_FOR_SYNC
} SavedDesignStatus;

@class SaveDesignResponse;

extern NSString* const SavedDesignKeySceneName;
extern NSString* const SavedDesignKeyVersion;
extern NSString* const SavedDesignKeyGlobalScale;
extern NSString* const SavedDesignKeyYFOV;
extern NSString* const SavedDesignKeyScreenSize;
extern NSString* const SavedDesignKeyScreenSizeWidth;
extern NSString* const SavedDesignKeyScreenSizeHeight;
extern NSString* const SavedDesignKeyMatrix;
extern NSString* const SavedDesignKeyModels;
extern NSString* const SavedDesingKeyBGBrightness;

@interface SavedDesign : NSObject <NSCoding, NSCopying>

// Used to create a new saved design from an image and (optionally) the gyroscope
+ (SavedDesign*) initWithImage:(UIImage*)image imageMetadata:(NSDictionary*)metadata devicePosition:(SavedGyroData*)devicePosition originalOrientation:(UIImageOrientation)o;
// Used to enrich a saved design with the json returned from the image analysis
+ (SavedDesign*) initWithParams:(UIImage*)image ImageOrientation:(UIImageOrientation)orientation JSON:(NSDictionary*)jsonData;
// Used to load a saved design that originated from the server
+(SavedDesign*) designWithJSONDictionary:(NSDictionary*)jsonData;
-(NSDictionary*)jsonData;
+(SavedDesign*) designWithJSONString:(NSString*)jsonString;
-(NSString*)jsonString;

- (void)generateUniqueuId;
- (void)updateLockingStateAccordingToDesignType:(int)sourceType;
- (BOOL)isEntityScaled:(Entity*)entity;
- (BOOL)isAnyEntityWasScalled;
- (void)changeScaleLock:(BOOL)lock;
- (float)fovForScreenSize:(CGSize)screenSize;
- (float)oldFOVForScreenSize:(CGSize)screenSize;
- (void)updateCachedImage:(SaveDesignResponse *)saveUrls;
- (BOOL)isEqual:(id)other;
- (BOOL)isEqualToDesign:(SavedDesign *)design;
- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)copyWithZone:(NSZone *)zone;
- (void)loadDataIntoUIImagesForAutosaves;
- (void)loadPreviewImageOnlyIntoUIImage;
- (NSData*)generateConcealRepresentationJSON;
- (BOOL)supportsFullConcealAPI;

@property( nonatomic,strong) SaveReminderItem * saveReminder; 
@property (nonatomic, strong) UIImage* image;
@property (nonatomic, strong) UIImage* originalImage;
@property (nonatomic, strong) UIImage* ImageWithFurnitures;
@property (nonatomic, strong) UIImage* maskImage;
@property (nonatomic, strong) NSString* parentID;
@property (nonatomic, strong) NSString* FormatVersion;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSArray* CubeVerts;
@property (assign) float GlobalScale;
@property (assign) UIImageOrientation Orientation;
@property (nonatomic, strong) NSString* UniqueID;
@property (nonatomic, strong) NSNumber* ServerKey;
@property (nonatomic, strong) NSMutableArray* models;
@property (nonatomic, strong) NSDate* date;
@property (nonatomic, strong) NSNumber* FocalLengthIn35mmFilm;
@property (atomic, assign) BOOL dirty;
@property (nonatomic, strong) NSString* designID;
@property (nonatomic, strong) NSString* publicDesignID; //exists if the design we are editing published
@property (nonatomic) BOOL mustSaveAsNewDesign;
@property (nonatomic, strong) NSString* designDescription;
@property (nonatomic, strong) NSString* designRoomType;
@property (assign) CGSize originalImageSize;
@property (atomic, assign) float bgBrightness;
@property (nonatomic, strong) SavedGyroData *GyroData;
@property (nonatomic, strong) SimpleCamera *camera;
@property(nonatomic) BOOL isScaleLockFoundInData;
@property(nonatomic) BOOL isScalingLocked;
@property(nonatomic) BOOL isPublic;
@property UIImagePickerControllerSourceType originalSourceType; //this should not be saved
@property BOOL isPortrait;
@property (nonatomic, strong) NSString * autoSaveUniqueID;
@property (nonatomic, strong) NSDate * autosaveDate;
@property (nonatomic, strong) NSData * previewImageData;
@property (nonatomic, strong) NSData * ImageData;
@property (nonatomic, strong) NSData * originalImageData;
@property (nonatomic, strong) NSData * maskImageData;

@end
