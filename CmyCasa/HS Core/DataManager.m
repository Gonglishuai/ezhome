//
//  DataManager.m
//  Homestyler
//
//  Created by Tomer Har Yoffi on 1/7/16.
//
//

#import "DataManager.h"

@implementation DataManger{
    NSMutableArray * _languagesArray;
    NSMutableArray * _languagesSymboleArray;
    NSInteger _selectedLangComponentIndex;
    NSString * _currentLanguageValue;

    NSMutableArray * _countryArray;
    NSMutableArray * _countrySymboleArray;
    NSInteger _selectedCountryComponentIndex;
    NSString * _currentCountryValue;

    NSString * _designSource;
    NSString * _category;
    NSString * _subCategory;
    NSString * _brand;
    NSString * _productId;
    NSString * _productName;

}

static DataManger *sharedInstance = nil;

+ (DataManger *)sharedInstance {
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[DataManger alloc] init];
    });
    
    return sharedInstance;
}

//////////////////////////// LANGUAGES //////////////////////////////////

-(void)populateLanguagesFromBundle{
    _languagesArray = [[NSMutableArray alloc] init];
    _languagesSymboleArray = [[NSMutableArray alloc] init];
    
    NSArray *  localizationsArray = [[NSBundle mainBundle] localizations];
    if (localizationsArray) {
        for (int i = 0; i < [localizationsArray count]; i++) {
            NSString * currLang = [localizationsArray objectAtIndex:i];
            if (currLang) {
                NSString * fullName = [[NSLocale localeWithLocaleIdentifier:currLang] displayNameForKey:NSLocaleIdentifier value:currLang];
                if (fullName) {
                    [_languagesArray addObject:[fullName capitalizedString]];
                    [_languagesSymboleArray addObject:currLang];
                }
            }
        }
        
        //check selected lang
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString * langSymbole = [defaults objectForKey:@"lang_symbole"];
        
        // If language symbol is nil, we need to take the system language
        if (!langSymbole)
            langSymbole = [[NSLocale preferredLanguages] objectAtIndex:0];
        
        if (langSymbole) {
            for (int i = 0; i < [_languagesSymboleArray count]; i++) {
                NSString * curSymbole = [_languagesSymboleArray objectAtIndex:i];
                if ([curSymbole isEqualToString:langSymbole]) {
                    _selectedLangComponentIndex = i;
                    return;
                }
            }
            
            // If this code part is reached, the user is using a non-supported
            // language by the system. Here the default should be English according to product spec
            // TODO (AVIHAY): Refactor this part to avoid code repetition
            langSymbole = @"en";
            for (int i = 0; i < [_languagesSymboleArray count]; i++) {
                NSString * curSymbole = [_languagesSymboleArray objectAtIndex:i];
                if ([curSymbole isEqualToString:langSymbole]) {
                    _selectedLangComponentIndex = i;
                    return;
                }
            }
            
        }else{
            //no local need to set default index
            _selectedLangComponentIndex = 0;
        }
    }else{
        //no local need to set default index
        _selectedLangComponentIndex = 0;
    }
}

-(void)setCurrentLangValue:(NSString*)value{
    _currentLanguageValue = value;
}

-(NSString*)getCurrentLangValue;{
    return _currentLanguageValue;
}

-(void)setLangComponentIndex:(NSInteger)index{
    _selectedLangComponentIndex = index;
}

-(NSInteger)getLangComponentIndex{
    return _selectedLangComponentIndex;
}

-(BOOL)isLangArray{
    if (_languagesArray && [_languagesArray count] > 0) {
        return YES;
    }else{
        return NO;
    }
}

-(void)saveLangToDeviceStorage:(NSString*)langName{
    NSInteger index = 0;
    for (int i = 0; i < [_languagesArray count]; i++) {
        NSString * lang = [_languagesArray objectAtIndex:i];
        if ([langName isEqualToString:lang]) {
            index = i;
            break;
        }
    }
    
    NSString * ls = [_languagesSymboleArray objectAtIndex:index];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:ls forKey:@"lang_symbole"];
    [defaults synchronize];
}

-(NSArray*)getLangArray{
    return _languagesArray;
}

-(NSString*)getSelecectedLang{
    return [_languagesArray objectAtIndex:_selectedLangComponentIndex];
}

-(NSString*)getLangAtIndex:(NSInteger)index{
    return [_languagesArray objectAtIndex:index];
}

-(NSInteger)getLangArrayCount{
    return [_languagesArray count];
}

-(NSString*)loadLanfFromDeviceStorage{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * langSymbole = [defaults objectForKey:@"lang_symbole"];
    NSString * fullName = [[NSLocale localeWithLocaleIdentifier:langSymbole] displayNameForKey:NSLocaleIdentifier value:langSymbole];
    return fullName;
}

//////////////////////////// COUNTRY //////////////////////////////////

-(void)populateCountry{
    _countryArray = [[NSMutableArray alloc] initWithObjects:@"FRANCE", @"UNITED KINGDOM", nil];
    _countrySymboleArray = [[NSMutableArray alloc] initWithObjects:@"FR",@"GB", nil];
    
    //check selected lang
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * countrySymbole = [defaults objectForKey:@"country_symbole"];
    
    // If country symbol is nil, we use GB as default
    if (!countrySymbole)
        countrySymbole = @"GB";
    
    if (countrySymbole) {
        for (int i = 0; i < [_countrySymboleArray count]; i++) {
            NSString * curSymbole = [_countrySymboleArray objectAtIndex:i];
            if ([curSymbole isEqualToString:countrySymbole]) {
                _selectedCountryComponentIndex = i;
                return;
            }
        }
    }
}

-(NSArray*)getCountryArray{
    return _countryArray;
}

-(NSString*)getCurrentCountryValue{
    return _currentCountryValue;
}

-(void)setCurrentCountryValue:(NSString*)value{
    _currentCountryValue = value;
}

-(BOOL)isCountryArray{
    if (_countryArray && [_countryArray count] > 0) {
        return YES;
    }else{
        return NO;
    }
}

-(NSInteger)getCountryComponentIndex{
    return _selectedCountryComponentIndex;
}

-(void)saveCountryToDeviceStorage:(NSString*)langName{
    NSInteger index = 0;
    for (int i = 0; i < [_countryArray count]; i++) {
        NSString * lang = [_countryArray objectAtIndex:i];
        if ([langName isEqualToString:lang]) {
            index = i;
            break;
        }
    }
    
    NSString * ls = [_countrySymboleArray objectAtIndex:index];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:ls forKey:@"country_symbole"];
    [defaults synchronize];
}

-(NSString*)getSelecectedCountry{
    NSString * countrySymboleFromDeviceStorage = [self loadCountryFromDeviceStorage];
    if (countrySymboleFromDeviceStorage) {
       
        for (int i = 0; i < [_countrySymboleArray count]; i++) {
            NSString * curSymbole = [_countrySymboleArray objectAtIndex:i];
            if ([curSymbole isEqualToString:countrySymboleFromDeviceStorage]) {
                _selectedCountryComponentIndex = i;
                break;
            }
        }
    }
    
    return [_countryArray objectAtIndex:_selectedCountryComponentIndex];
}

-(NSString*)getCountrySymboleForCountyName:(NSString*)name{
    NSString* countrySymbole = @"GB";
    
    for (int i = 0; i < [_countryArray count]; i++) {
        NSString * curName = [_countryArray objectAtIndex:i];
        if ([curName isEqualToString:name]) {
            countrySymbole = [_countrySymboleArray objectAtIndex:i];
            return countrySymbole;
        }
    }
    return countrySymbole;
}

-(NSString*)loadCountryFromDeviceStorage{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * countrySymbole = [defaults objectForKey:@"country_symbole"];
    return countrySymbole;
}

-(void)setCountryComponentIndex:(NSInteger)index{
    _selectedCountryComponentIndex = index;
}

-(NSInteger)getCountryArrayCount{
    return [_countryArray count];
}

-(NSString*)getCountryAtIndex:(NSInteger)index{
    return [_countryArray objectAtIndex:index];
}

-(NSString*)validateSymbole:(NSString*)symbole{
    NSString * resSymbole = @"GB";
    
    for (int i =0; i < [_countrySymboleArray count]; i++) {
        NSString * curSymbole = [_countrySymboleArray objectAtIndex:i];
        if ([curSymbole isEqualToString:symbole]) {
            resSymbole = curSymbole;
        }
    }
    
    return resSymbole;
}

//////////////////////////// SEGMENT //////////////////////////////////

- (NSString *)designSource {
    return _designSource;
}

- (void)setDesignSource:(NSString *)designSource {
    _designSource = designSource;
}

- (NSString *)category {
    return _category;
}

- (void)setCategory:(NSString *)newValue {
    _category = newValue;
}

- (NSString *)subCategory {
    return _subCategory;
}

- (void)setSubCategory:(NSString *)newValue {
    _subCategory = newValue;
}

- (NSString *)brand {
    return _brand;
}

- (void)setBrand:(NSString *)newValue {
    _brand = newValue;
}

- (NSString *)productId {
    return _productId;
}

- (void)setProductId:(NSString *)newValue {
    _productId = newValue;
}

- (NSString *)productName {
    return _productName;
}

- (void)setProductName:(NSString *)newValue {
    _productName = newValue;
}

@end