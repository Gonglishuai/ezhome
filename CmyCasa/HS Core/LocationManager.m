//
//  LocationManager.m
//  Homestyler
//
//  Created by Berenson Sergei on 1/5/14.
//
//

#import "LocationManager.h"

@interface LocationManager ()

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation LocationManager

static LocationManager *sharedInstance = nil;

+ (LocationManager *)sharedInstance {

    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedInstance = [[LocationManager alloc] init];
    });

    return sharedInstance;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        //Instantiate a location object.
        _locationManager = [[CLLocationManager alloc] init];
        
        //Make this controller the delegate for the location manager.
        [_locationManager setDelegate:self];
        
        //Set some paramater for the location object.
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyKilometer];
        
    }
    return self;
}


-(void)getLocation:(HSCompletionBlock)block{

    self.locationCompleteBlock = block;
    
    if(![self isDeterminedLocationServices]){
        
        [_locationManager requestWhenInUseAuthorization];
        return;
    }
    
    if(![self canAccessLocationServices]){
        
        if(block)
        {
            block(nil,NSLocalizedString(@"no_gps_location_enabled",@""));
        }
        return;
    }
    
    [_locationManager startUpdatingLocation];
}

-(void)geocodeLocation:(CLLocation*)location withCompletion:(HSCompletionBlock)completeBlock{
    
    CLGeocoder * coder=[[CLGeocoder alloc] init];
    [coder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error==nil) {
            if (placemarks && [placemarks count]>0) {
                self.lastAddress=[placemarks objectAtIndex:0];
            }
            if (completeBlock) {
                completeBlock(self.lastAddress,nil);
            }
        }else{
               if (completeBlock)
                   completeBlock(nil,NSLocalizedString(@"gps_failed_to_retrieve_location", @""));
        }
        
    }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if(locations && [locations count] > 0){
        
        self.lastLocation=locations[0];
        [manager stopUpdatingLocation];

        [[LocationManager sharedInstance] geocodeLocation:self.lastLocation withCompletion:self.locationCompleteBlock];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self stopUpdatingLocationWithMessage:NSLocalizedString(@"Error", @"Error")];
    
    if (self.locationCompleteBlock) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
            self.locationCompleteBlock(nil, NSLocalizedString(@"no_gps_location_enabled", @""));
        }else {
            self.locationCompleteBlock(nil, NSLocalizedString(@"gps_failed_to_retrieve_location", @""));
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusNotDetermined) {
        return;
    }
    
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        if (self.locationCompleteBlock)
            self.locationCompleteBlock(nil, NSLocalizedString(@"no_gps_location_enabled", @""));
    } else {
        [self.locationManager startUpdatingLocation];
    }

}

- (BOOL)isDeterminedLocationServices
{
    CLAuthorizationStatus authorStatus = [CLLocationManager authorizationStatus];
    if (authorStatus == kCLAuthorizationStatusNotDetermined)
        return NO;
    return YES;
}

- (BOOL)canAccessLocationServices
{
    CLAuthorizationStatus authorStatus = [CLLocationManager authorizationStatus];

    switch (authorStatus){
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
        {
            NSLog(@"return false - kCLAuthorizationStatusRestricted or kCLAuthorizationStatusDenied");
            return NO;
        } break;
        
        default:
            return YES;
    }

    return  YES;
}

- (void)stopUpdatingLocationWithMessage:(NSString *)state {
    [self.locationManager stopUpdatingLocation];
}

-(void)getLocationApi:(HSCompletionBlock)block{
    
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[NSURL
                                         URLWithString:@"https://mkp-be-beta.spark.autodesk.com/api/v1/utils/geoLocation"]
                            cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                        timeoutInterval:10
     ];
    
    [request setHTTPMethod: @"GET"];
    [request setValue:@"MKP" forHTTPHeaderField:@"X-Tenant"];
    
    NSError *requestError = nil;
    NSURLResponse *urlResponse = nil;
    
    
    NSData *response =
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&urlResponse error:&requestError];
    
    NSString* encodeRespose = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    //NSLog(@"encodeRespose %@", encodeRespose);
    
    encodeRespose = [encodeRespose prepareStringForJSON];
    
    NSError * error;
    NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:[encodeRespose dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    
    if (error) {
        if (block) {
            block(nil, @"Fail to parse location");
        }
    }else{
        if (block) {
            block(jsonData, requestError);
        }
    }
}
@end

