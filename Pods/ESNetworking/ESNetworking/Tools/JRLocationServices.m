//
//  JRLocationServices.m
//  Consumer
//
//  Created by jiang on 2017/6/19.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "JRLocationServices.h"
//#import "AMapLocationKit.h"
//#import "AMapFoundationKit.h"
//#import <AMapLocationKit/AMapLocationKit.h>
//#import <AMapFoundationKit/AMapFoundationKit.h>
#import "ESAddrerssAPI.h"
#import "ESRegionManager.h"
#import "JRNetEnvConfig.h"
#import "ESHTTPSessionManager.h"

#define WS(weakSelf)  __weak __block __typeof(&*self)weakSelf = self;
@interface JRLocationServices()
@property(strong, nonatomic) AMapLocationManager *locationManager;
@property(strong, nonatomic) LocationBlock myLocationBlock;
@end

@implementation JRLocationServices

+ (instancetype)sharedInstance
{
    static JRLocationServices *locationServices = nil;
    static dispatch_once_t s_predicate;
    dispatch_once(&s_predicate, ^{
        locationServices = [[super allocWithZone:NULL]init];
    });
    
    return locationServices;
}


///override the function of allocWithZone:.
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    return [JRLocationServices sharedInstance];
}


///override the function of copyWithZone:.
- (instancetype)copyWithZone:(struct _NSZone *)zone {
    
    return [JRLocationServices sharedInstance];
}

- (void)setUpApiKey {
    //test:  2a9b49d56f42ce615f142232037e5973
    //production: 77c6f8aa2516780356f8eb2ca9473566
    [AMapServices sharedServices].apiKey = [JRNetEnvConfig sharedInstance].netEnvModel.mapServicesApiKey;// @"2a9b49d56f42ce615f142232037e5973";
    self.locationCityInfo = [[JRCityInfo alloc]init];
    self.currentCityInfo = [[JRCityInfo alloc]init];
    self.locationManager = [[AMapLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    self.locationManager.allowsBackgroundLocationUpdates = NO;
    self.locationManager.locationTimeout = 3;
    self.locationManager.reGeocodeTimeout = 3;
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *status = [userDefaults objectForKey:@"app_location_key"];
    if (status
        && [status isKindOfClass:[NSString class]]
        && [status isEqualToString:@"NO"])
    {
        self.locationCityInfo.cityCode = @"110100";
    }
}

- (void)requestLocation:(LocationBlock)block  {
    _myLocationBlock = block;
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *status = [userDefaults objectForKey:@"app_location_key"];
        if (status
            && [status isKindOfClass:[NSString class]]
            && [status isEqualToString:@"NO"])
        {
            self.locationCityInfo.cityCode = @"110100";
            if (_myLocationBlock) {
                _myLocationBlock(self.locationCityInfo);
            }
            return;
        }
        
        if (error) {
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            
            if (error.code == AMapLocationErrorLocateFailed) {
                if (_myLocationBlock) {
                    _myLocationBlock(nil);
                }
                return;
            }
        }
        
        //处理直辖市
        if (regeocode) {
            NSString *cityName = regeocode.city ? regeocode.city : @"";
            if ([cityName isEqualToString:@""]) {
                NSString *replaceCityName = regeocode.province ? regeocode.province : @"";
                if (![replaceCityName isEqualToString:@""]) {
                    cityName = replaceCityName;
                }
            }
            
            //            //处理city code
            //            NSString *cityCode = regeocode.adcode ? regeocode.adcode : @"";
            //            if ([cityName isEqualToString:@""]) {
            //                NSString *chineseCityCode = [self getCityCodeWithCityName:cityName];
            //                if (![chineseCityCode isEqualToString:@""]) {
            //                    cityCode = chineseCityCode;
            //                }
            //            } else {
            //                if (cityCode.length-4>0) {
            //                    [cityCode stringByPaddingToLength: 4 withString: @"0" startingAtIndex: 0];
            //                }
            //            }
            WS(weakSelf)
            [ESRegionManager getRegionInfoWithCityName:cityName
                                      withDistrictCode:regeocode.adcode
                                           withSuccess:^(ESRegionModel *province, ESRegionModel *city, ESRegionModel *district) {
                                               weakSelf.locationCityInfo.locatedCityName = cityName;
                                               weakSelf.locationCityInfo.longitude = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
                                               weakSelf.locationCityInfo.latitude = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
                                               weakSelf.locationCityInfo.district = regeocode.district;
                                               
                                               if (city == nil) {
                                                   if (_myLocationBlock) {
                                                       _myLocationBlock(weakSelf.locationCityInfo);
                                                   }
                                               } else {
                                                   
                                                   weakSelf.locationCityInfo.province = province.name;
                                                   weakSelf.locationCityInfo.provinceCode = province.rid;
                                                   
                                                   weakSelf.locationCityInfo.locatedCityName = city.name;
                                                   weakSelf.locationCityInfo.cityCode = city.rid;
                                                   
                                                   weakSelf.locationCityInfo.district = district.name;
                                                   weakSelf.locationCityInfo.districtCode = district.rid;
                                                   
                                                   [[ESHTTPSessionManager sharedInstance].defaultHeader setValue:city.rid?:@"" forKey:@"X-Region"];
                                                   if (_myLocationBlock) {
                                                       _myLocationBlock(weakSelf.locationCityInfo);
                                                   }
                                               }
                                               
                                               
                                           }];
        }else {
            if (_myLocationBlock) {
                _myLocationBlock(nil);
            }
        }
    }];
}

@end

