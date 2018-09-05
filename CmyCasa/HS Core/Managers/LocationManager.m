//
//  LocationManager.m
//  PokerFace
//
//  Created by Tomer Har Yoffi on 1/17/15.
//  Copyright (c) 2015 Tomer Har Yoffi. All rights reserved.
//

#import "LocationManager.h"

@implementation LocationManager

+ (id)sharedInstance {
    static LocationManager *sharedLogicManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLogicManager = [[self alloc] init];
    });
    return sharedLogicManager;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        //Instantiate a location object.
        _locationManager = [[CLLocationManager alloc] init];
        
        //Make this controller the delegate for the location manager.
        [_locationManager setDelegate:self];
        
        //Set some paramater for the location object.
        [_locationManager setDistanceFilter:kCLDistanceFilterNone];
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        
        //Set the first launch instance variable to allow the map to zoom on the user location when first launched.
        _firstLaunch = YES;
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization];
        }
        
        [_locationManager startUpdatingLocation];
    }
    return self;
}

-(void)queryGoogleForCurrentLocation;
{
    //http://maps.googleapis.com/maps/api/geocode/json?address=reading%201&sensor=false&language=en
    // Build the url string we are going to sent to Google. NOTE: The kGOOGLE_API_KEY is a constant which should contain your own API key that you can obtain from Google. See this link for more info:
    // https://developers.google.com/maps/documentation/places/#Authentication
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f", _currentCentre.latitude, _currentCentre.longitude];
    
    //Formulate the string as URL object.
    NSURL *googleRequestURL = [NSURL URLWithString:url];
    
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}

-(void)queryGoogleForText:(NSString*)search;
{
    NSString *decoded = [search stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // Build the url string we are going to sent to Google. NOTE: The kGOOGLE_API_KEY is a constant which should contain your own API key that you can obtain from Google. See this link for more info:
    // https://developers.google.com/maps/documentation/places/#Authentication
    NSString *url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=false&language=en", decoded];
    
    //Formulate the string as URL object.
    NSURL *googleRequestURL = [NSURL URLWithString:url];
    
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedDataForText:) withObject:data waitUntilDone:YES];
    });
}

- (void)fetchedDataForText :(NSData *)responseData {
    //parse out the json data
    NSError* error;
    
    if (responseData) {
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              
                              options:kNilOptions
                              error:&error];
        
        //The results from Google will be an array obtained from the NSDictionary object with the key "results".
        NSArray* places = [json objectForKey:@"results"];
        if ([places count] > 0) {
            _places = [places copy];
            
            if([self.locationDelegate respondsToSelector:@selector(doneRetriveLoactionForText:)]){
                [self.locationDelegate performSelector:@selector(doneRetriveLoactionForText:) withObject:_places];
            }
        }
    }
}

- (void)fetchedData:(NSData *)responseData {
    if(!responseData)
        return;

    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    NSArray* places = [json objectForKey:@"results"];
    if ([places count] > 0) {
        NSDictionary * location = [places objectAtIndex:0];
        NSString * formattedAddress = [location objectForKey:@"formatted_address"];
        NSLog(@"formatted_address: %@", formattedAddress);
        
        if([self.locationDelegate respondsToSelector:@selector(doneRetriveLoactionAddress:)]){
            [self.locationDelegate performSelector:@selector(doneRetriveLoactionAddress:) withObject:location];
        }
    }
    
    [_locationManager stopUpdatingLocation];
}


// Failed to get current location
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Failed to Get Your Location");
//    UIAlertView *errorAlert = [[UIAlertView alloc]
//                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    // Call alert
//    [errorAlert show];
}

// Got location and now update
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    CLLocation *currentLocation = newLocation;
    _currentCentre = [currentLocation coordinate];
    NSLog(@"currentLocation :%@", currentLocation);

    [_locationManager stopUpdatingLocation];
}

-(void)whereAmI{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:_locationManager.location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       NSLog(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
                       
                       if (error){
                           NSLog(@"Geocode failed with error: %@", error);
                           return;
                           
                       }
                       
                       
                       CLPlacemark *placemark = [placemarks objectAtIndex:0];
                       
                       NSLog(@"placemark.ISOcountryCode %@",placemark.ISOcountryCode);
                       NSLog(@"placemark.country %@",placemark.country);
                       NSLog(@"placemark.postalCode %@",placemark.postalCode);
                       NSLog(@"placemark.administrativeArea %@",placemark.administrativeArea);
                       NSLog(@"placemark.locality %@",placemark.locality);
                       NSLog(@"placemark.subLocality %@",placemark.subLocality);
                       NSLog(@"placemark.subThoroughfare %@",placemark.subThoroughfare);
                       
                   }];

}
@end
