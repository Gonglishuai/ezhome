//
//  SaveDesignRequestObject.m
//  Homestyler
//
//  Created by Berenson Sergei on 12/3/13.
//
//

#import "SaveDesignRequestObject.h"
#import "SavedDesign.h"

@implementation SaveDesignRequestObject

-(instancetype)initWithDesignObject:(SavedDesign*)design{
    self = [super init];
    
    if (self) {
        self.roomType = design.designRoomType;
        self._description = design.designDescription;
        self.name = design.name;
        self.parentId = design.parentID;
        self.originalImage = design.originalImage;
        self.imageWithFurnitures = design.ImageWithFurnitures;
        self.editedImage = design.image;
        self.in_maskImage = design.maskImage;
        self.designId = (design.designID!=nil) ? design.designID:@"";
    }
   
    return self;
}

@end
