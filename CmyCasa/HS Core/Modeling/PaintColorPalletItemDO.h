//
//  PaintColorPalletItemDO.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/12/13.
//
//

#import <Foundation/Foundation.h>

@class PaintColorDO;
@interface PaintColorPalletItemDO : NSObject


@property(nonatomic,readonly)NSString * categoryID;

-(id)initWithDict:(NSDictionary*)dict;

-(NSArray*)getColorsForPallet;

-(PaintColorDO*)getPaintColorObjectByName:(NSString*)name;
@end
