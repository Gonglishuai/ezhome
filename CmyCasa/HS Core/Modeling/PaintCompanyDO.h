//
//  PaintCompanyDO.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/12/13.
//
//

#import <Foundation/Foundation.h>
#import "CompanyBaseDO.h"


@interface PaintCompanyDO : CompanyBaseDO

@property (nonatomic) NSMutableArray * categories;
@property (nonatomic) NSMutableDictionary * categoryColorPallets;
@property (nonatomic) NSMutableArray * flatAllPallets;
@property (nonatomic) NSString * companyName;
@property (nonatomic) NSString * iconRetinaUrl;
@property (strong, nonatomic) UIImage *logo;

- (UIImage*)getLogo;
@end
