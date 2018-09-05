//
//  ProfessionalFIlterDO.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/8/13.
//
//

#import <Foundation/Foundation.h>


@interface ProfessionalFilterDO : NSObject <NSCoding>



-(id)initWithStartIndex:(int)_startIndex withLimit:(int)limit forProfKey:(NSString*)profkey forLocKey:(NSString*)lockey;


@property(nonatomic) NSString * locationFilter;
@property(nonatomic) NSString * professionFilter;
@property(nonatomic) NSNumber * startIndex;
@property(nonatomic) NSNumber * count;
@property(nonatomic) NSMutableArray * professionals;
@end
