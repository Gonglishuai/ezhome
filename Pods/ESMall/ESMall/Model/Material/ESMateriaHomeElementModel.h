
#import "ESBaseModel.h"

@interface ESMateriaHomeElementModel : ESBaseModel

@property (nonatomic, copy) NSString *subTitle;
@property (nonatomic, copy) NSString *mainTitle;
@property (nonatomic, copy) NSString *categoryId;
@property (nonatomic, retain) NSArray *elementList;

@end
