
#import "SHModel.h"

@protocol MPCaseImageModel <NSObject>

@end

@interface MPCaseImageModel : SHModel

//"file_id" : "17975068",
//"file_name" : "image01.jpg",
//"file_url" : "https://static.spark.autodesk.com/Beta/2016/01/27__15_36_05/image01.jpg4f71b65a-c5ce-11e5-8ceb-22000b27b5ec",
//"is_primary" : true
@property (nonatomic, copy) NSString *file_id;
@property (nonatomic, copy) NSString *file_name;
@property (nonatomic, copy) NSString *file_url;
@property (nonatomic, assign) BOOL is_primary;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
