//
//  MPFileUtility.h
//  MarketPlace
//
//  Created by Nilesh Kuber on 2/16/16.
//
//

#import <Foundation/Foundation.h>

@interface SHFileUtility : NSObject

+ (NSString *) getDocumentDirectory;

//This function does not check for file existence from given path
+ (NSString *) getFileNameFromFilePath:(NSString *)fileFullPath;

//This function does not check for file existence from given path
+ (NSString *) getDirecoryPathFromFilePath:(NSString *)fileFullPath;

+ (BOOL) isFileExist:(NSString *)filePath;
+ (BOOL) isDirectoryExist:(NSString *)filePath;

//return unique name
// it is just added for getting unique name
+ (NSString *) getUniqueFileName;
+ (NSString *) getUniqueFileNameWithExtension:(NSString*)extension;

+ (BOOL) createDirectory:(NSString *)folderFullpath;
+ (BOOL) removeDirectory:(NSString *)folderFullpath;

+ (NSString *) writeData:(NSData *)fileData
                filePath:(NSString *)filePath;

+ (NSString *) writeImage:(UIImage *)image
             withFilePath:(NSString *)filePath
           andCompression:(CGFloat)compression;

+ (BOOL) removeFile:(NSString *)filePath;

+ (BOOL) moveFile:(NSString *)sourcePath toFile:(NSString *)targetPath;

/******************************************************
 // Following functions are working on folder in 
 // the Document directory
*******************************************************/

+ (BOOL) isFolderExistInDocDir:(NSString *)folderName;

+ (NSString *) saveData:(NSData *)data
            inDocFolder:(NSString *)folderName
           withFileName:(NSString *)fileName;
+ (BOOL) removeFile:(NSString *)fileName
      fromDocFolder:(NSString *)folderName;
+ (NSString *) createFolderInDocDir:(NSString *) folderName;
+ (BOOL) removeFolderFromDocDir:(NSString *)folderName;
+ (BOOL) copyFolderWithName:(NSString *)srcName
                   toName:(NSString *)dstName;

@end
