//
//  ColorsManager.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/12/13.
//
//

#import <Foundation/Foundation.h>
#import "PaintCompanyDO.h"

@interface ColorsManager : NSObject


+ (ColorsManager *)sharedInstance;

@property(nonatomic) NSMutableArray * colorCompanies;


@end
