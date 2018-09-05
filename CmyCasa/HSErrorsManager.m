//
//  HSErrorsManager.m
//  Homestyler
//
//  Created by Berenson Sergei on 3/11/13.
//
//

#import "HSErrorsManager.h"

@interface HSErrorsManager ()

@property(nonatomic) NSMutableDictionary * existingErrors;
@property(nonatomic) NSMutableDictionary * lookupErrorsTable;

@end
@implementation HSErrorsManager

static HSErrorsManager *sharedInstance = nil;



+ (HSErrorsManager *)sharedInstance {
    
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedInstance = [[HSErrorsManager alloc] init];
        
        sharedInstance.existingErrors=[NSMutableDictionary dictionaryWithCapacity:0];
        sharedInstance.lookupErrorsTable=[NSMutableDictionary dictionaryWithCapacity:0];
        
            NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"ErrorsLookupTable" ofType:@"plist"];
            sharedInstance.lookupErrorsTable=[NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
        
        
    });
    
    return sharedInstance;
}

-(NSString*)addErrorFromServer:(ErrorDO*)error withPrevGuid:(NSString*)_guid{
    
    if (error==nil) {
        error=[[ErrorDO alloc] initErrorWithDetails:NSLocalizedString(@"erh_unknown_error_msg", "") withErrorCode:HSERR_LOCAL_ERROR_GENERIC_ERROR];
    }
    
    
    if (_guid==nil) {
        
        error.errorGuid=[HSErrorsManager GetUUID];
        [sharedInstance.existingErrors setObject:error forKey:error.errorGuid];
        
        NSDictionary * errorDescription= [sharedInstance.lookupErrorsTable objectForKey:
                                          [NSString stringWithFormat:@"%d", error.errorCode]];
     
        error.needRetry=[[errorDescription objectForKey:@"needRetry"] boolValue];
        error.needSilentLogin=[[errorDescription objectForKey:@"silentLogin"] boolValue];
        
        return error.errorGuid;
    }else{
        ErrorDO * existing_error=[sharedInstance.existingErrors objectForKey:_guid];
        
        if (existing_error) {
            existing_error.currentRetryCount++;
           
        }else{
            
            error.errorGuid=_guid;
            [sharedInstance.existingErrors setObject:error forKey:error.errorGuid];
            
        }
         return _guid;
    }

    
    return  nil;
}

-(NSString*)getErrorByGuid:(NSString*)guid{
    
    if (guid) {
        ErrorDO* err=[sharedInstance.existingErrors objectForKey:guid];
        NSDictionary * errorDescription= [sharedInstance.lookupErrorsTable objectForKey:
                                         [NSString stringWithFormat:@"%d", err.errorCode]];
        //if no predefined error message found return message from server
        if (errorDescription==nil) {
            return err.message;
        }
        return  [errorDescription objectForKey:@"localyzed_key"];
    }
    
    return nil;
}
-(HSServerErrorCode)getErrorCodeByGuid:(NSString*)guid{
    
    if (guid) {
        ErrorDO* err=[sharedInstance.existingErrors objectForKey:guid];
        return  err.errorCode;
        
    }
    
    return -1;
}
-(NSString*)getErrorByGuidLocalized:(NSString*)guid{
    
    if (guid) {
        ErrorDO* err=[sharedInstance.existingErrors objectForKey:guid];
        NSDictionary * errorDescription= [sharedInstance.lookupErrorsTable objectForKey:
                                          [NSString stringWithFormat:@"%d", err.errorCode]];
        //if no predefined error message found return message from server
        if (errorDescription==nil) {
            return NSLocalizedString(@"erh_unknown_error_msg",@"") ;
        }
        NSString * key=[errorDescription objectForKey:@"localyzed_key"];
        
        return NSLocalizedString(key,@"") ;
          
    }
    
    return nil;
}

-(BOOL)needRetryAfterErrorForGuid:(NSString*)guid{

    if (guid) {
        ErrorDO* err=[sharedInstance.existingErrors objectForKey:guid];
        NSDictionary * errorDescription= [sharedInstance.lookupErrorsTable objectForKey:
                                          [NSString stringWithFormat:@"%d", err.errorCode]];
        //if no predefined error message found return message from server
        if (errorDescription==nil) {
            return YES;
        }
        return  [[errorDescription objectForKey:@"needRetry"] boolValue];
    }
    
    return YES;

}


+ (NSString *)GetUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return  (__bridge_transfer NSString *)string;
}
@end
