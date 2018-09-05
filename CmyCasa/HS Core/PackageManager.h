//  Copyright (c) 2008 by Autodesk, Inc.
//  All rights reserved.
//
//  The information contained herein is confidential and proprietary to
//  Autodesk, Inc., and considered a trade secret as defined under civil
//  and criminal statutes.  Autodesk shall pursue its civil and criminal
//  remedies in the event of unauthorized use or misappropriation of its
//  trade secrets.  Use of this information by anyone other than authorized
//  employees of Autodesk, Inc. is granted only under a written non-
//  disclosure agreement, expressly prescribing the scope and manner of
//  such use.
//
//  Written by Avihay Assouline 09/01/2014
//

#import <Foundation/Foundation.h>

///////////////////////////////////////////////////////
//                  INTERFACE                        //
///////////////////////////////////////////////////////

typedef void(^HSProgressBlock)(float precentage);
typedef void(^HSComplitionBlock)(void);

@interface PackageManager : NSObject

@property (nonatomic, strong) NSDictionary * packageDetails;
@property (nonatomic) BOOL isNewFileExist;
@property (nonatomic, strong) NSURLConnection *downloadingConnection;
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSNumber * fileLength;
@property (nonatomic) NSUInteger downloadedBytes;
@property (copy) HSProgressBlock progressCallBack;
@property (copy) HSComplitionBlock complitionCallBack;

#pragma mark - Singleton implementation

/*
 *
 */
+(id)sharedInstance;

#pragma mark - Package management (Loading, Updating,..)

/*
 *  Download a package from a given URL and load it
 */
- (BOOL)loadPackageFromURL:(NSString*)url
             progressBlock:(void (^)(float precentage))progressBlock
           complitionBlock:(void (^)(void))complitionBlock;

/*
 *  Download a package from a given URL and load it with resume option
 */
- (BOOL)loadPackageFromURLExt:(NSString*)url
                progressBlock:(void (^)(float precentage))progressBlock
              complitionBlock:(void (^)(void))complitionBlock;

/*
 *  Loads a package from the delivery package (Part of the app which is
 *  downloaded from the AppStore). By convention, this package is called
 *  Package.zip and can be found under the package directory.
 */
- (BOOL)loadPackageFromDeliveryPackage;

/*
 *  Loads a package from a given local file
 */
- (BOOL)loadPackageFromLocalFile:(NSString*)filePath;

/*
 *  Check if any package was already loaded
 */
- (BOOL)isAnyPackageAvailable;

#pragma mark - API handling

/*
 *  Retrieves a response for a given API. The API name, by convention, is the last part of the API's
 *  URL with as a JSON file. If a given API requires arguments, then they are concatenated with underscore ('_')
 */
- (NSString*)getResponseForAPI:(NSString*)api andArguments:(NSDictionary*)arguments;

#pragma mark - File request handling

/*
 *
 */
- (NSData*)getFileFromPackage:(NSString*)filename;

// By convention, all files inside the pacakge are named as <MD5_SUM_OF_URL>.<ORI_EXT>
// where <MD5_SUM_OF_URL> is the MD5 sum implementation on the entire file name
// (including extension) and <ORI_EXT> is the original extension name.
- (NSData*)getFileByURLString:(NSString*)urlToFile;


/*
 *  Check if the offline exit on device under DOCUMENT folder
 */
-(BOOL)isOffLinePackageExist;

/*
 *  remove offline package
 */
-(void)removeOfflinePackage:(void(^)(void))complitionBlock;

///////////////////////////////////////////////////////
//                  PROPERTIES                       //
///////////////////////////////////////////////////////

@property (atomic, strong) NSMutableDictionary *loadedPackageFiles;

@end
