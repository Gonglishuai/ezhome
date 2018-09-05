//
//  CloudFrontCacheMap.m
//  Homestyler
//
//  Created by Berenson Sergei on 3/28/13.
//
//

#import "CloudFrontCacheMap.h"
#import "HelpersRO.h"
@implementation CloudFrontCacheMap
@synthesize getCommentsCacheTimeoutMins;
@synthesize commentsCacheMap,saveDesignsMap;
-(id)initWithDict:(NSMutableDictionary*)dict{
    
    self=[super init];
    
    self.getCommentsCacheTimeoutMins=[[dict objectForKey:@"cache"] objectForKey:@"getComments_cache_interval"];
     self.commentsCacheMap= [NSMutableDictionary dictionaryWithCapacity:0];
    self.saveDesignsMap=[NSMutableDictionary dictionaryWithCapacity:0];
    return  self;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
    //Encode the properties of the object
    [encoder encodeObject:self.commentsCacheMap forKey:@"commentsCacheMap"];
   [encoder encodeObject:self.saveDesignsMap forKey:@"savedesignsCacheMap"];

}

-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if ( self != nil )
    {
        //decode the properties
        self.getCommentsCacheTimeoutMins=[[[[ConfigManager sharedInstance] getMainConfigDict] objectForKey:@"cache"] objectForKey:@"getComments_cache_interval"];
        
        self.commentsCacheMap = [decoder decodeObjectForKey:@"commentsCacheMap"];
        self.saveDesignsMap = [decoder decodeObjectForKey:@"savedesignsCacheMap"];
        
    }
    return self;
}

- (void)saveCustomObject {
    NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:myEncodedObject forKey:@"cloudCache"];
    [defaults synchronize];
}

+ (CloudFrontCacheMap *)loadCustomObject{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *myEncodedObject = [defaults objectForKey:@"cloudCache"];
    if (myEncodedObject==nil) {
        return nil;
    }
    CloudFrontCacheMap *obj = (CloudFrontCacheMap *)[NSKeyedUnarchiver unarchiveObjectWithData: myEncodedObject];
    return obj;
}



-(NSString*)generateRequestTimestampForDesignID:(NSString*)designID{
    
    
    NSString * timestp=[NSString stringWithFormat:@"%@_%@",[HelpersRO getTimestampInMiliSeconds],designID];
    
    [self.saveDesignsMap setObject:timestp forKey:designID];
    
    return timestp;
}
-(NSString*)getRequestTimestampForDesignID:(NSString*)designID{
    if ([self.saveDesignsMap objectForKey:designID]) {
         return [self.saveDesignsMap objectForKey:designID];
    }
    return nil;
}
@end
