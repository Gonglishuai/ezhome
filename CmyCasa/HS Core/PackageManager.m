//
//  PackageManager.m
//  Homestyler
//
//  Created by Avihay Assouline on 8/31/14.
//
//

#import "PackageManager.h"
#import "HSMacros.h"
#import "zipZap/zipZap.h"
#import "HelpersRO.h"
#import "ConfigManager.h"

#define OFFLINE_PACKAGE_NAME        @"/PackagesFolder/Package.zip"
#define OFFLINE_TEMP_PACKAGE_NAME   @"/PackagesFolder/Downloading.zip"
#define PACKAGE_JSON_URL            @"https://prod-hsm-assets.s3.amazonaws.com/Packages/packageDetails.json"
#define PACKAGE_DETAILS_NAME        @"packageDetails.json"
#define PACKAGE_FILES_DICT          @"package_file_dict"

@implementation PackageManager

/////////////////////////////////////////////////////////////////////////

static PackageManager *sharedInstance = nil;

/////////////////////////////////////////////////////////////////////////

+ (PackageManager*)sharedInstance
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[PackageManager alloc] init];
        sharedInstance.loadedPackageFiles = [NSMutableDictionary dictionary];
        [sharedInstance fetchPackageDetailFromServer];
    });
    
    return sharedInstance;
}

/////////////////////////////////////////////////////////////////////////

- (BOOL)loadPackageFromDeliveryPackage
{
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* offline = [documentsPath stringByAppendingPathComponent:OFFLINE_PACKAGE_NAME];
    
    if (!offline)
        return NO;
    
    [sharedInstance loadPackageFromLocalFile:offline];
    
    return YES;
}

/////////////////////////////////////////////////////////////////////////

- (BOOL)loadBasicPackageFromLocalFile
{
    NSString* jsonFilePath = [[NSBundle mainBundle] pathForResource:@"Package"
                                                             ofType:@"zip"];
    
    RETURN_ON_NIL(jsonFilePath, NO);
        
    [sharedInstance loadPackageFromLocalFile:jsonFilePath];
    
    return YES;
}

/////////////////////////////////////////////////////////////////////////

- (BOOL)loadPackageFromURL:(NSString*)url
             progressBlock:(void (^)(float precentage))progressBlock
           complitionBlock:(void (^)(void))complitionBlock
{
    NSURL * urlObj = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlObj];
    
    
    AFRKURLConnectionOperation *operation = [[AFRKHTTPRequestOperation alloc] initWithRequest:request];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:OFFLINE_TEMP_PACKAGE_NAME];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    
    __block float progress = 0.0;
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
    {
        if (progressBlock) {
            progressBlock(((float)totalBytesRead / (float)totalBytesExpectedToRead) * 100);
        }
        progress = (float)totalBytesRead / (float)totalBytesExpectedToRead;
    }];
    
    [operation setCompletionBlock:^{
        if (complitionBlock && progress > 0.99)
        {
            [self renameFileName];
            complitionBlock();
        }
    }];
    
    [operation start];
    
    RETURN_ON_NIL(url, NO);
    
    return YES;
}

/////////////////////////////////////////////////////////////////////////

-(void)renameFileName
{
    NSError * err = nil;

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *tempFile = [[paths objectAtIndex:0] stringByAppendingPathComponent:OFFLINE_TEMP_PACKAGE_NAME];
    NSString *completeFileName = [[paths objectAtIndex:0] stringByAppendingPathComponent:OFFLINE_PACKAGE_NAME];
    NSFileManager * fm = [[NSFileManager alloc] init];
    
    BOOL result = [fm moveItemAtPath:tempFile toPath:completeFileName error:&err];
    
    if(!result){
        if ([ConfigManager isPackageManagerLogActive]) {
            HSMDebugLog(@"================================================================================================");
            HSMDebugLog(@"Error: %@", err);
            HSMDebugLog(@"================================================================================================");
        }
    }
}

/////////////////////////////////////////////////////////////////////////

- (BOOL)isAnyPackageAvailable
{
    return ([sharedInstance.loadedPackageFiles count] > 0);
}


/////////////////////////////////////////////////////////////////////////

-(BOOL)isOffLinePackageExist
{
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* offline = [documentsPath stringByAppendingPathComponent:OFFLINE_PACKAGE_NAME];
    return [[NSFileManager defaultManager] fileExistsAtPath:offline];
}

/////////////////////////////////////////////////////////////////////////

-(void)removeOfflinePackage:(void(^)(void))complitionBlock
{
    sharedInstance.loadedPackageFiles = [NSMutableDictionary dictionary];
    
    NSString * folderPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"/PackagesFolder/"];
    NSError *error = nil;
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:&error]) {
        
        if ([ConfigManager isPackageManagerLogActive]) {
            HSMDebugLog(@"================================================================================================");
            HSMDebugLog(@"SUCCSESS TO REMOVE FILE %@", file);
            HSMDebugLog(@"================================================================================================");
        }
        
        [[NSFileManager defaultManager] removeItemAtPath:[folderPath stringByAppendingPathComponent:file] error:&error];
    }
    
    //Remove key from NSUserDefaults
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PACKAGE_FILES_DICT];
    
    complitionBlock();
}

/////////////////////////////////////////////////////////////////////////

- (BOOL)loadPackageFromLocalFile:(NSString*)filePath
{
    RETURN_ON_NIL(filePath, NO);
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths lastObject];
    
    //check if we saved before the dictionary
    self.loadedPackageFiles = [[NSUserDefaults standardUserDefaults] objectForKey:PACKAGE_FILES_DICT];
    
    if (!self.loadedPackageFiles) {
        self.loadedPackageFiles = [NSMutableDictionary dictionary];
        ZZArchive* za = [ZZArchive archiveWithURL:[NSURL fileURLWithPath:filePath] error:nil];
        for (ZZArchiveEntry* entry in za.entries) {
            NSString *path = [[documentsDirectory stringByAppendingString:@"/PackagesFolder/"] stringByAppendingString:[entry.fileName lowercaseString]];
            NSData * data = [entry newDataWithError:nil];

            BOOL writeSuccess = [data writeToFile:path atomically:YES];
            
            if(!writeSuccess)
                return NO;
            
            [self.loadedPackageFiles setObject:path forKey:[entry.fileName lowercaseString]];
        }
        
        //save the dictionary for next sessions
        if ([self.loadedPackageFiles count] > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:self.loadedPackageFiles forKey:PACKAGE_FILES_DICT];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    return YES;
}

/////////////////////////////////////////////////////////////////////////

- (NSData*)getFileFromPackage:(NSString*)filename
{
    RETURN_ON_NIL(filename, nil);
    RETURN_ON_NIL(self.loadedPackageFiles, nil);
    
    NSString* fileEntry = [self.loadedPackageFiles objectForKey:[filename lowercaseString]];
    
    RETURN_ON_NIL(fileEntry, nil);
    
    return [NSData dataWithContentsOfFile:fileEntry];
}

/////////////////////////////////////////////////////////////////////////

- (NSString*)getResponseForAPI:(NSString*)api andArguments:(NSDictionary*)arguments
{
    RETURN_ON_NIL(api, nil);
    
    // The API's name by convention is the last part of the API
    NSArray *fullAPISeperated = [api componentsSeparatedByString: @"/"];
    NSString *lastPartOfAPIString = [fullAPISeperated lastObject];
    
    NSArray *argumentArray = [arguments allKeys];
    
    if (arguments && [arguments count] == 1)
    {
        NSString *arg = [arguments objectForKey:[argumentArray firstObject]];
        lastPartOfAPIString = [[lastPartOfAPIString stringByAppendingString:@"_"] stringByAppendingString:arg];
    }
    
    NSString *APIName = [[lastPartOfAPIString stringByAppendingString:@".json"] lowercaseString];
    
    NSString *responseFileString = nil;
    NSData *fileData = [self getFileFromPackage:APIName];
    
    RETURN_ON_NIL(fileData, nil);
    
    responseFileString = [[NSString alloc]initWithData:fileData
                                              encoding:NSUTF8StringEncoding];
    
    return responseFileString;
}

/////////////////////////////////////////////////////////////////////////

- (NSData*)getFileByURLString:(NSString*)urlToFile
{
    RETURN_ON_NIL(urlToFile, nil);
    
    // By convention, all files inside the pacakge are named as <MD5_SUM_OF_URL>.<ORI_EXT>
    // where <MD5_SUM_OF_URL> is the MD5 sum implementation on the entire file name
    // (including extension) and <ORI_EXT> is the original extension name.
    NSString *md5String = [HelpersRO encodeMD5:urlToFile];
    NSArray *fullAPISeperated = [urlToFile componentsSeparatedByString: @"."];
    NSString *lastPartOfAPIString = [fullAPISeperated lastObject];
    
    // Add the extension the the MD5 filename
    NSString *fileAsMD5 = [[md5String stringByAppendingString:@"."] stringByAppendingString:lastPartOfAPIString];
    
    NSData *fileData = [self getFileFromPackage:fileAsMD5];
    
    RETURN_ON_NIL(fileData, nil);
    
    return fileData;
}

//////////////////////////////////////////////////////////////////////////

-(void)fetchPackageDetailFromServer
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/PackagesFolder"];
    NSError *error = nil;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    
    NSURL *url = [[NSURL alloc] initWithString:PACKAGE_JSON_URL];
    
    NSURLResponse * response = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url]
                                          returningResponse:&response
                                                      error:&error];
    
    if (error == nil)
    {
        self.packageDetails = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (self.packageDetails) {
            // save file to nsdefults
            NSDictionary * pervDetails = [[NSUserDefaults standardUserDefaults] objectForKey:PACKAGE_DETAILS_NAME];
            if (!pervDetails) {
                //no file exist under userdefaults  save it
                self.isNewFileExist = NO;
            }else{
                NSInteger  prvPkgVersion = [[pervDetails objectForKey:@"version"] integerValue];
                NSInteger  curPkgVersion = [[self.packageDetails objectForKey:@"version"] integerValue];
                
                self.isNewFileExist = (curPkgVersion > prvPkgVersion) ? YES : NO;
            }
            
            [self savePackageDetailsToDevice];
        }else{
            if ([ConfigManager isPackageManagerLogActive]) {
                HSMDebugLog(@"================================================================================================");
                HSMDebugLog(@"Failed to save Package details to nsdefualts");
                HSMDebugLog(@"================================================================================================");
            }
        }
    }
}

-(void)savePackageDetailsToDevice{
    [[NSUserDefaults standardUserDefaults] setObject:self.packageDetails forKey:PACKAGE_DETAILS_NAME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)loadPackageFromURLExt:(NSString*)url
             progressBlock:(void (^)(float precentage))progressBlock
              complitionBlock:(void (^)(void))complitionBlock{
    
    //holds the callback blocks
    self.progressCallBack = progressBlock;
    self.complitionCallBack = complitionBlock;
    
    // create a request
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: url]
                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                              timeoutInterval:30.0];
    
    if (![NSURLConnection canHandleRequest:req]) {
        // Handle the error
        if ([ConfigManager isPackageManagerLogActive]) {
            HSMDebugLog(@"================================================================================================");
            HSMDebugLog(@"Failed to handel request");
            HSMDebugLog(@"================================================================================================");
        }
    }
    
    //generate file path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:OFFLINE_TEMP_PACKAGE_NAME];
    
    self.downloadedBytes = 0;
    NSFileManager *fm = [NSFileManager defaultManager];
    
    //check if file exist on the device
    if ([fm fileExistsAtPath:filePath]) {
        NSError *error = nil;
        NSDictionary *fileDictionary = [fm attributesOfItemAtPath:filePath error:&error];
        if (!error && fileDictionary){
            //read how much data we read
            self.downloadedBytes = (NSUInteger)[fileDictionary fileSize];
        }
    } else {
        //file not exist let create it!
        [fm createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    //we found that we allready read some data lets create new header for the request indicate the location in file.
    if (self.downloadedBytes > 0) {
        NSString *requestRange = [NSString stringWithFormat:@"bytes=%lu-", (unsigned long)self.downloadedBytes];
        [req setValue:requestRange forHTTPHeaderField:@"Range"];
    }
    
    //create connection.... let's go!
    NSURLConnection *conn = [NSURLConnection connectionWithRequest:req delegate:self];
    self.downloadingConnection = conn;
    [conn start];
    return NO;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.downloadingConnection = nil;
    // Show an alert for the error
    if ([ConfigManager isPackageManagerLogActive]) {
        HSMDebugLog(@"================================================================================================");
        HSMDebugLog(@"Connection Failed %@", error);
        HSMDebugLog(@"================================================================================================");
    }
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    if (![httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        // I don't know what kind of request this is!
        return;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:OFFLINE_TEMP_PACKAGE_NAME];

    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:filePath];
    self.fileHandle = fh;
    
    switch (httpResponse.statusCode) {
        case 200: {
            //first time we run, we store the file size
            self.fileLength = [NSNumber  numberWithLongLong:[response expectedContentLength]];
            [[NSUserDefaults standardUserDefaults] setObject:self.fileLength forKey:@"file_size"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
        }
        case 206: {
            //resume download we need to find the exact location in file
            self.fileLength = [[NSUserDefaults standardUserDefaults] objectForKey:@"file_size"];
            
            NSString *range = [httpResponse.allHeaderFields valueForKey:@"Content-Range"];
            NSError *error = nil;
            NSRegularExpression *regex = nil;
            
            // Check to see if the server returned a valid byte-range
            regex = [NSRegularExpression regularExpressionWithPattern:@"bytes (\\d+)-\\d+/\\d+"
                                                              options:NSRegularExpressionCaseInsensitive
                                                                error:&error];
            if (error) {
                [fh truncateFileAtOffset:0];
                break;
            }
            
            // If the regex didn't match the number of bytes, start the download from the beginning
            NSTextCheckingResult *match = [regex firstMatchInString:range
                                                            options:NSMatchingAnchored
                                                              range:NSMakeRange(0, range.length)];
            if (match.numberOfRanges < 2) {
                [fh truncateFileAtOffset:0];
                break;
            }
            
            // Extract the byte offset the server reported to us, and truncate our
            // file if it is starting us at "0".  Otherwise, seek our file to the
            // appropriate offset.
            NSString *byteStr = [range substringWithRange:[match rangeAtIndex:1]];
            NSInteger bytes = [byteStr integerValue];
            if (bytes <= 0) {
                [fh truncateFileAtOffset:0];
                break;
            } else {
                [fh seekToFileOffset:bytes];
            }
            break;
        }
            
        default:
            [fh truncateFileAtOffset:0];
            break;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [self.fileHandle writeData:data];
    [self.fileHandle synchronizeFile];
    
    if(self.data == nil)
    {
        self.data = [[NSMutableData alloc] init];
    }
    
    [self.data appendData:data];
    
    //calculate download progress
    float progress = ((float)((float)[self.data length] + (float)self.downloadedBytes) / [self.fileLength floatValue]);
    
    if ([ConfigManager isPackageManagerLogActive]) {
        HSMDebugLog(@"================================================================================================");
        HSMDebugLog(@"Progress %.f%%", progress * 100);
        HSMDebugLog(@"================================================================================================");
    }

    self.progressCallBack(progress * 100);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    [self renameFileName];
    self.complitionCallBack();
    
    //cleanup
    [self.fileHandle closeFile];
    self.fileHandle = nil;
    self.downloadingConnection = nil;
    self.progressCallBack = nil;
    self.complitionCallBack = nil;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"file_size"];
}

@end
