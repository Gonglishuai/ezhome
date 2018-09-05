//
//  DataManager.h
//  Homestyler
//
//  Created by Tomer Har Yoffi on 1/7/16.
//
//

#import <Foundation/Foundation.h>


@interface DataManger : NSObject

+ (DataManger*)sharedInstance;


////////////////////////////////////////////////////
-(void)populateLanguagesFromBundle;
-(void)setLangComponentIndex:(NSInteger)index;
-(void)setCurrentLangValue:(NSString*)value;
-(NSString*)getCurrentLangValue;
-(NSString*)getLangAtIndex:(NSInteger)index;
-(NSString*)getSelecectedLang;
-(NSInteger)getLangArrayCount;
-(NSInteger)getLangComponentIndex;
-(NSArray*)getLangArray;
-(void)saveLangToDeviceStorage:(NSString*)langName;
-(BOOL)isLangArray;
-(NSString*)loadLanfFromDeviceStorage;

////////////////////////////////////////////////////
-(void)populateCountry;
-(NSArray*)getCountryArray;
-(NSString*)getCurrentCountryValue;
-(void)setCurrentCountryValue:(NSString*)value;
-(BOOL)isCountryArray;
-(NSInteger)getCountryComponentIndex;
-(void)setCountryComponentIndex:(NSInteger)index;
-(void)saveCountryToDeviceStorage:(NSString*)langName;
-(NSString*)getSelecectedCountry;
-(NSString*)getCountrySymboleForCountyName:(NSString*)name;
-(NSString*)loadCountryFromDeviceStorage;
-(NSInteger)getCountryArrayCount;
-(NSString*)getCountryAtIndex:(NSInteger)index;
-(NSString*)validateSymbole:(NSString*)symbole;

////////////////////////////////////////////////////
- (NSString *)designSource;
- (void)setDesignSource:(NSString*)source;
- (NSString *)category;
- (void)setCategory:(NSString *)newValue;
- (NSString *)subCategory;
- (void)setSubCategory:(NSString *)newValue;
- (NSString *)brand;
- (void)setBrand:(NSString *)newValue;
- (NSString *)productId;
- (void)setProductId:(NSString *)newValue;
- (NSString *)productName;
- (void)setProductName:(NSString *)newValue;

@end
