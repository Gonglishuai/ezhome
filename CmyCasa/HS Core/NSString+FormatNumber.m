//
//  NSString+FormatNumber.m
//  HomeStyler
//
//  Created by Eric Dong on 05/17/18.
//

#import "NSString+FormatNumber.h"
#import "NSBundle+Language.h"

@implementation NSString (FormatNumber)

+ (NSString *)formatNumber:(NSInteger)num {
    if (num <= 0){
        return @"0";
    }

    NSString *languageCode = [[NSBundle mainBundle] getLanguageCode];

    NSLocale *locale = [NSLocale currentLocale];
    NSString* countryCode = [locale objectForKey:NSLocaleCountryCode];
    NSString *localeId = [NSString stringWithFormat:@"%@_%@", languageCode, countryCode/*locale.countryCode*/];
    locale = [NSLocale localeWithLocaleIdentifier:localeId];

    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.locale = locale;
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;

    if (num < 1e4) {
        return [NSString stringWithFormat:@"%ld", num];
    }

    if ([languageCode isEqualToString:@"zh"] || [languageCode isEqualToString:@"ja"]) {
        NSString *unitTenK = NSLocalizedString(@"number_unit_ten_thousand", @"");
        float kv = num * 0.0001f;
        if (num < 1e5) {
            [numberFormatter setPositiveFormat:@"0.0"];
            NSString *numStr = [numberFormatter stringFromNumber:@(kv)];
            return [NSString stringWithFormat:@"%@%@", numStr, unitTenK];
        }

        [numberFormatter setPositiveFormat:@"0"];
        if (num < 1e8) {
            [numberFormatter setPositiveFormat:@"0"];
            NSString *numStr = [numberFormatter stringFromNumber:@(kv)];
            return [NSString stringWithFormat:@"%@%@", numStr, unitTenK];
        }

        NSString *unitHundredM = NSLocalizedString(@"number_unit_hundred_m", @"");
        kv *= 0.0001f;
        if (num < 1e10) {
            NSString *numStr = [numberFormatter stringFromNumber:@(kv)];
            return [NSString stringWithFormat:@"%@%@", numStr, unitHundredM];
        }
        NSString *numStr = [numberFormatter stringFromNumber:@(kv)];
        return [NSString stringWithFormat:@"%@%@+", numStr, unitHundredM];
    } else {
        NSString *unitK = NSLocalizedString(@"k", @"k");
        float kv = num * 0.001f;
        if (num < 1e5) {
            [numberFormatter setPositiveFormat:@"0.0"];
            NSString *numStr = [numberFormatter stringFromNumber:@(kv)];
            return [NSString stringWithFormat:@"%@%@", numStr, unitK];
        }

        [numberFormatter setPositiveFormat:@"0"];
        if (num < 1e6) {
            NSString *numStr = [numberFormatter stringFromNumber:@(kv)];
            return [NSString stringWithFormat:@"%@%@", numStr, unitK];
        }

        kv *= 0.001f;
        NSString *unitM = NSLocalizedString(@"m", @"m");
        if (num < 1e9) {
            NSString *numStr = [numberFormatter stringFromNumber:@(kv)];
            return [NSString stringWithFormat:@"%@%@", numStr, unitM];
        }

        kv *= 0.001f;
        NSString *unitB = NSLocalizedString(@"b", @"b");
        if (num < 1e10) {
            NSString *numStr = [numberFormatter stringFromNumber:@(kv)];
            return [NSString stringWithFormat:@"%@%@", numStr, unitB];
        }
        NSString *numStr = [numberFormatter stringFromNumber:@(kv)];
        return [NSString stringWithFormat:@"%@%@+", numStr, unitB];
    }
}

@end
