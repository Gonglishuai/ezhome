
#import "ESBaseModel.h"

@interface ESProductImagesModel : ESBaseModel

/**
 imageUrl (string, optional),
 usage (string, optional),
 description (string, optional),
 sequence (number, optional)
 */

@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *usage;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *sequence;

@end
