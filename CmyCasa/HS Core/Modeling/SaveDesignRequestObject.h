//
//  SaveDesignRequestObject.h
//  Homestyler
//
//  Created by Berenson Sergei on 12/3/13.
//
//

#import <Foundation/Foundation.h>
@class SavedDesign;
@interface SaveDesignRequestObject : NSObject


-(instancetype)initWithDesignObject:(SavedDesign*)design;

@property(nonatomic,strong)NSString * name;
@property(nonatomic,strong)NSString * _description;
@property(nonatomic,strong)NSString * json;
@property(nonatomic,strong)NSString * designId;
@property(nonatomic)BOOL isNewDesign;
@property(nonatomic)BOOL isPublished;
@property(nonatomic,strong)NSString * roomType;
@property(nonatomic,strong)UIImage * originalImage;
@property(nonatomic,strong)UIImage * editedImage;
@property(nonatomic,strong)UIImage * imageWithFurnitures;
@property(nonatomic,strong)UIImage * in_maskImage;
@property(nonatomic,strong)NSString * parentId;






@end
