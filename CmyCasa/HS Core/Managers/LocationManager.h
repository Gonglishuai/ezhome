//
//  LocationManager.h
//  PokerFace
//
//  Created by Tomer Har Yoffi on 1/17/15.
//  Copyright (c) 2015 Tomer Har Yoffi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define kGOOGLE_API_KEY @"AIzaSyCPEaEFsjH-86nM8b00tajfhyXEr0QsEAA"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@protocol LocationManagerDelegate <NSObject>
@optional
-(void)doneRetriveLoactionAddress:(NSString*)formatedAddress;
-(void)doneRetriveLoactionForText:(NSArray*)places;
@end

@interface LocationManager : NSObject <CLLocationManagerDelegate>
{
    CLLocationManager * _locationManager;
    
    CLLocationCoordinate2D _currentCentre;
    int _currenDist;
    BOOL _firstLaunch;
    NSArray * _places;
}

@property (nonatomic, weak) id <LocationManagerDelegate> locationDelegate;

+ (id)sharedInstance;
-(void)queryGoogleForCurrentLocation;
-(void)queryGoogleForText:(NSString*)search;
-(void)whereAmI;
@end
