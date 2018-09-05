
#import "SHModel.h"

@protocol MPDesignerModel <NSObject>

@end

@interface MPDesignerModel : SHModel

//"case_count" : null,
//"design_price_max" : null,
//"design_price_min" : null,
//"diy_count" : null,
//"experience" : null,
//"graduate_from" : null,
//"introduction" : null,
//"is_loho" : null,
//"is_real_name" : 0,
//"measurement_price" : null,
//"personal_honour" : null,
//"studio" : null,
//"style_long_names" : "欧式风格,日式风格",
//"style_names" : "日式,欧式",
//"styles" : "japanese,european"

@property (nonatomic, retain) NSNumber *acs_member_id;

@property (nonatomic, retain) NSNumber *case_count;
@property (nonatomic, retain) NSNumber *design_price_max;
@property (nonatomic, retain) NSNumber *design_price_min;
@property (nonatomic, retain) NSNumber *diy_count;
@property (nonatomic, retain) NSNumber *experience;
@property (nonatomic, copy) NSString *graduate_from;
@property (nonatomic, copy) NSString *introduction;
@property (nonatomic, retain) NSNumber *is_loho;
@property (nonatomic, retain) NSNumber *is_real_name;
@property (nonatomic, retain) NSNumber *measurement_price;
@property (nonatomic, copy) NSString *personal_honour;
@property (nonatomic, copy) NSString *studio;
@property (nonatomic, copy) NSString *style_long_names;
@property (nonatomic, copy) NSString *style_names;
@property (nonatomic, copy) NSString *styles;
@property (nonatomic, copy) NSString *evalution_avg_scores;
@property (nonatomic, copy) NSString *evalution_count;
@property (nonatomic, copy) NSString *theme_pic;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
