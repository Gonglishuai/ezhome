//
//  ApiAction.m
//  Homestyler
//

#import "ApiAction.h"

@implementation ApiAction

/////////////////////////////////////////////////////////////////////////

-(instancetype)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init]) {
        self.action = [dict objectForKey:@"action"];
        self.isHttps = [[dict objectForKey:@"https"] boolValue];
        self.isCloud = [[dict objectForKey:@"cloud"] boolValue];
    }

    return self;
}

-(instancetype)initWithAction:(NSString*)action
                        https:(BOOL)isHttps
                        cloud:(BOOL)isCloud
                     serverV2:(BOOL)isServerV2{
    
    if (self = [super init]) {
        self.action = action;
        self.isHttps = isHttps;
        self.isCloud = isCloud;
        self.isServerV2 = isServerV2;
        self.isSSOServer = NO;
    }
    
    return self;
}

-(instancetype)initWithAction:(NSString*)action
                    ssoserver:(BOOL)isSSOServer{
    
    if (self = [super init]) {
        self.action = action;
        self.isHttps = NO;
        self.isCloud = NO;
        self.isServerV2 = NO;
        self.isSSOServer = isSSOServer;
    }
    
    return self;
}

/////////////////////////////////////////////////////////////////////////

-(NSString*)description
{
    return [NSString stringWithFormat:@"{Action: %@, https:%d, cloud:%d }",self.action,self.isHttps,self.isCloud];
}

/////////////////////////////////////////////////////////////////////////

-(RKObjectManager*)getManagerForSelfAction
{
    
    RKObjectManager *manager = nil;
    if (self.isCloud && self.isHttps) {
        manager = [AppCore httpsRKManager];
    }
    if (self.isCloud && !self.isHttps) {
        manager = [AppCore httpRKManager];
    }
    if (!self.isCloud && !self.isHttps) {
        manager = [AppCore httpCloudlessRKManager];
    }
    if (!self.isCloud && self.isHttps) {
        manager = [AppCore httpsCloudlessRKManager];
    }
    if (self.isServerV2 == YES && self.isCloud)
    {
        manager = [AppCore httpRKManagerV2];
    }
    if (self.isServerV2 == YES && !self.isCloud)
    {
        manager = [AppCore httpCloudlessRKManagerV2];
    }
    if (self.isSSOServer)
    {
        manager = [AppCore httpSSORKManager];
    }
    
    return manager;
}
@end
