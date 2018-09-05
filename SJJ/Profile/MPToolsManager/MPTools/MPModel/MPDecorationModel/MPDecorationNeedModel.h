
#import "SHModel.h"
#import "MPDecorationBidderModel.h"

@protocol MPDecorationNeedModel <NSObject>

@end

@interface MPDecorationNeedModel : SHModel

//"after_bidding_status" : null,
//"bidder_count" : 0,
//"bidders" : [],
//"bidding_status" : null,
//"city" : "北京",
//"click_number" : 0,
//"community_name" : "天长元",
//"consumer_mobile" : "13111111111",
//"consumer_name" : "全流程侧试",
//"contacts_mobile" : "13222222222",
//"contacts_name" : "李四",
//"contract" : null,
//"custom_string_status" : "03",
//"decoration_budget" : "30000",
//"decoration_style" : "欧式",
//"delivery" : null,
//"detail_desc" : "123132",
//"district" : "123",
//"end_day" : "29",
//"house_area" : "120",
//"house_type" : "中式",
//"is_beishu" : "1",
//"is_public" : "0",
//"living_room" : "1",
//"needs_id" : 1549361,
//"province" : "北京",
//"publish_time" : "2016-02-05 16:36:13",
//"room" : "1",
//"toilet" : "1",
//"wk_template_id" : "1"

@property (nonatomic, copy) NSString *beishu_thread_id;

@property (nonatomic, copy) NSString *district_name;
@property (nonatomic, copy) NSString *province_name;
@property (nonatomic, copy) NSString *city_name;

@property (nonatomic, copy) NSString *after_bidding_status; //null
@property (nonatomic, retain) NSNumber *bidder_count;
@property (nonatomic, retain) NSArray<MPDecorationBidderModel *> *bidders;
@property (nonatomic, copy) NSString *bidding_status; //null
@property (nonatomic, copy) NSString *city;
@property (nonatomic, retain) NSNumber *click_number;
@property (nonatomic, copy) NSString *community_name;
@property (nonatomic, copy) NSString *consumer_mobile;
@property (nonatomic, copy) NSString *consumer_name;
@property (nonatomic, copy) NSString *contacts_mobile;
@property (nonatomic, copy) NSString *contacts_name;
@property (nonatomic, copy) NSString *contract; //null
@property (nonatomic, copy) NSString *custom_string_status;
@property (nonatomic, copy) NSString *decoration_budget;
@property (nonatomic, copy) NSString *decoration_style;
@property (nonatomic, copy) NSString *delivery; //null
@property (nonatomic, copy) NSString *detail_desc;
@property (nonatomic, copy) NSString *district;
@property (nonatomic, copy) NSString *end_day;
@property (nonatomic, copy) NSString *house_area;
@property (nonatomic, copy) NSString *house_type;
@property (nonatomic, copy) NSString *is_beishu;
@property (nonatomic, copy) NSString *is_public;
@property (nonatomic, copy) NSString *living_room;
@property (nonatomic, retain) NSNumber *needs_id;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *publish_time;
@property (nonatomic, copy) NSString *room;
@property (nonatomic, copy) NSString *toilet;
@property (nonatomic, copy) NSString *design_budget;
@property (nonatomic, copy) NSString *wk_template_id;
@property (nonatomic, copy) NSString *address;


/// Using the dictionary to initialize the model
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
