//
//  LocationManager.h
//  Homestyler
//
//  Created by Berenson Sergei on 1/5/14.
//
//

#import "BaseManager.h"
#import <CoreLocation/CoreLocation.h>

@protocol LocationManagerDelegate <NSObject>

-(void)gpsLocationAscquired:(CLLocationCoordinate2D)location;

@end

@interface LocationManager : BaseManager<CLLocationManagerDelegate>{
    CLLocationCoordinate2D _currentCentre;
}

@property (nonatomic,strong) CLLocation * lastLocation;
@property (nonatomic,strong) CLPlacemark * lastAddress;
@property (nonatomic, strong)id<LocationManagerDelegate> delegate;
@property (nonatomic,strong) HSCompletionBlock locationCompleteBlock;

+(LocationManager *)sharedInstance;

-(void)getLocation:(HSCompletionBlock)block;
-(void)getLocationApi:(HSCompletionBlock)block;
-(void)geocodeLocation:(CLLocation*)location withCompletion:(HSCompletionBlock)completeBlock;

@end
