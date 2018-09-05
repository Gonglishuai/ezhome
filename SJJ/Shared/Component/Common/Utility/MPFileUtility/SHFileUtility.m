//
//  MPFileUtility.m
//  MarketPlace
//
//  Created by Nilesh Kuber on 2/16/16.
//
//

#import "SHFileUtility.h"

@implementation SHFileUtility


#pragma mark - generic functions

//return nil if unsuccessful
+ (NSString *) getDocumentDirectory;
{
    NSString *docDir = [NSString stringWithFormat:@"%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]];
    [SHFileUtility logFilepath:docDir];
    return docDir;
}


+ (NSString *) getFileNameFromFilePath:(NSString *)fileFullPath
{
    if (fileFullPath)
        return ([fileFullPath lastPathComponent]);
    
    return nil;
}


+ (NSString *) getDirecoryPathFromFilePath:(NSString *)fileFullPath
{
    if (fileFullPath)
    {
        //extract folder path from full path
        NSString *directory = fileFullPath;
        
        NSString *fileName = [directory lastPathComponent];
        
        NSRange range = [directory rangeOfString:fileName];
        
        if (range.location != NSNotFound)
        {
            directory = [directory substringToIndex:range.location];
            return directory;
        }
    }
    
    return nil;
}


//Filepath can be directory or file
//
+ (BOOL) isFileExist:(NSString *)filePath
{
    return ([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
}


+ (NSString *) getUniqueFileName
{
    return [[NSUUID new] UUIDString];
}


+ (NSString *) getUniqueFileNameWithExtension:(NSString*)extension
{
    NSString* uniqueFileName = [SHFileUtility getUniqueFileName];
    return [NSString stringWithFormat:@"%@.%@", uniqueFileName, extension];
}


+ (BOOL) isDirectoryExist:(NSString *)filePath
{
    if (filePath)
    {
        //Value of bStaus is undefined upon return when path does not exist
        // so just return with NO if path is not found
        BOOL bStatus = NO;
        BOOL bExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&bStatus];
        
        if (bExists)
            return bStatus;
    }
    
    return NO;
}

+ (NSString *) writeData:(NSData *)fileData
                filePath:(NSString *)filePath
{
    if (fileData && filePath)
    {
        NSString *folderPath = [filePath stringByDeletingLastPathComponent];

        BOOL doesDirectoryExist = [SHFileUtility isDirectoryExist:folderPath];

        if (doesDirectoryExist)
        {
            BOOL bStatus = [fileData writeToFile:filePath atomically:YES];

            if (bStatus)
                return filePath;
        }
    }

    return nil;
}

+ (NSString *) writeImage:(UIImage *)image
             withFilePath:(NSString *)filePath
           andCompression:(CGFloat)compression
{
    NSData *data =  UIImageJPEGRepresentation(image, compression);

    return [SHFileUtility writeData:data
                           filePath:filePath];
}

+ (BOOL) moveFile:(NSString *)sourcePath toFile:(NSString *)targetPath
{
    BOOL success = NO;

    if (sourcePath && [SHFileUtility isFileExist:sourcePath] && targetPath)
    {
        NSError *error;

        success = [[NSFileManager defaultManager] moveItemAtPath:sourcePath
                                                          toPath:targetPath
                                                           error:&error];

        if (error)
            success = NO;
    }

    return success;
}

#pragma mark - functions related to folder in Doc directory

+ (BOOL) isFolderExistInDocDir:(NSString *)folderName
{
    if (folderName)
    {
        NSString *rootDir = [SHFileUtility getDocumentDirectory];
        NSString *folderPath = [rootDir stringByAppendingPathComponent:folderName];
        
        return [SHFileUtility isDirectoryExist:folderPath];

    }
    
    return NO;
}

+ (BOOL) removeFile:(NSString *)filePath
{
    BOOL bStatus = NO;

    if (filePath)
    {
        if ([SHFileUtility isDirectoryExist:filePath])
        {
            SHLog(@"%@ path is directory path not file path", filePath);
            return bStatus;
        }

        NSError *err = nil;
        bStatus = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&err];
    }

    return bStatus;
}


+ (NSString *) saveData:(NSData *)data
      inDocFolder:(NSString *)folderName
     withFileName:(NSString *)fileName
{
    if (folderName)
    {
        NSString *rootDir = [SHFileUtility getDocumentDirectory];
        NSString *folderPath = [rootDir stringByAppendingPathComponent:folderName];
        
        NSString *filePath = [folderPath stringByAppendingPathComponent:(fileName != nil ? fileName : [SHFileUtility getUniqueFileName])];
        BOOL bStatus = [data writeToFile:filePath atomically:YES];
        
        if (bStatus)
        {
            [SHFileUtility logFilepath:filePath];
            return filePath;
        }
        
        
    }
    
    return nil;
}


+ (BOOL) removeFile:(NSString *)fileName
            fromDocFolder:(NSString *)folderName
{
    BOOL bStatus = NO;
    
    if (fileName)
    {
        NSString *rootDir = [SHFileUtility getDocumentDirectory];
        NSString *folderPath = [rootDir stringByAppendingPathComponent:folderName];
        NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
        
        NSError *err = nil;
        bStatus = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&err];
        
        if (!bStatus)
            [self logError:err];
    }
    
    
    return bStatus;
}


+ (NSString *) createFolderInDocDir:(NSString *) folderName;
{
    if (folderName)
    {
        NSString *rootDir = [SHFileUtility getDocumentDirectory];
        
        if ([SHFileUtility isDirectoryExist:rootDir])
        {
            //create folder
            NSString *folderPath = [rootDir stringByAppendingPathComponent:folderName];
            [SHFileUtility logFilepath:folderPath];
            
            if (![SHFileUtility createDirectory:folderPath])
                return nil;
            
            return folderPath;
        }
    }

    return nil;
}


+ (BOOL) removeFolderFromDocDir:(NSString *)folderName
{
    if (folderName)
    {
        NSString *folderPath = [[SHFileUtility getDocumentDirectory] stringByAppendingPathComponent:folderName];
        return ([SHFileUtility removeDirectory:folderPath]);
    }
    
    return NO;
}

+ (BOOL) copyFolderWithName:(NSString *)srcName
                     toName:(NSString *)dstName
{
    BOOL bSuccess = NO;
    if (srcName && dstName)
    {
        NSString *srcPath = [[SHFileUtility getDocumentDirectory] stringByAppendingPathComponent:srcName];
        NSString *dstPath = [[SHFileUtility getDocumentDirectory] stringByAppendingPathComponent:dstName];
        
        if ([SHFileUtility isDirectoryExist:srcPath])
        {
            [SHFileUtility removeDirectory:dstPath];
            NSError *error = nil;
            bSuccess = [[NSFileManager defaultManager]
                        copyItemAtPath:srcPath
                        toPath:dstPath
                        error:&error];
            if (!bSuccess)
                [SHFileUtility logError:error];
        }
    }
    return bSuccess;
}

#pragma mark - private methods


+ (BOOL) createDirectory:(NSString *)folderFullpath
{
    BOOL bSuccess = NO;
    
    if (folderFullpath)
    {
        if (![SHFileUtility isDirectoryExist:folderFullpath])
        {
            NSError *err = nil;
            bSuccess = [[NSFileManager defaultManager] createDirectoryAtPath:folderFullpath
                                                 withIntermediateDirectories:YES
                                                                  attributes:nil
                                                                       error:&err];
            if (!bSuccess)
                [SHFileUtility logError:err];
        }
        else
            bSuccess = YES;
        
    }

    return bSuccess;
}


+ (BOOL) removeDirectory:(NSString *)folderFullpath
{
    BOOL bSuccess = NO;
    
    if (folderFullpath)
    {
        NSError *err = nil;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:folderFullpath])
            bSuccess = [[NSFileManager defaultManager] removeItemAtPath:folderFullpath
                                                                  error:&err];
        
        if (!bSuccess)
            [self logError:err];
    }

    return bSuccess;
}



#pragma mark - logging methods

+ (void) logError:(NSError *)error
{
    if (!error)
        SHLog(@"Error = %@", error.localizedDescription);
}


+ (void) logFilepath:(NSString *)filePath
{
//    SHLog(@"path = %@", filePath);
}


@end
