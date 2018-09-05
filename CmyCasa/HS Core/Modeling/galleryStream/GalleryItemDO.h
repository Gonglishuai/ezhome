//
//  GalleryItemDO.h
//  CmyCasa
//
//  Created by Berenson Sergei on 2/11/13.
//
//

#import <Foundation/Foundation.h>
#import "DesignBaseClass.h"

@interface GalleryItemDO : DesignBaseClass<NSCoding>

-(id)initWithDictionary:(NSMutableDictionary*)dict;
-(id)createEmptyDesignWithType:(ItemType)tp;

@end
