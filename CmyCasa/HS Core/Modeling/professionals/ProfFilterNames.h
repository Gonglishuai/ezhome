//
//  ProfFilterNames.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/28/13.
//
//

#import <Foundation/Foundation.h>
#import "ProfFilterNameItemDO.h"

@interface ProfFilterNames : NSObject<NSCoding>

@property(nonatomic)NSMutableArray * locations;
@property(nonatomic)NSMutableArray * professions;

-(id)initWithDict:(NSArray * )dictList;
-(BOOL)isFiltersReady;
@end
