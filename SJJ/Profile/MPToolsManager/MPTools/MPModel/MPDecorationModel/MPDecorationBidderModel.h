
#import "SHModel.h"
#import "MPBidderOrderModel.h"
#import "MPDecoWkSubNodeIds.h"
#import "MPDesiContractModel.h"

@protocol MPDecorationBidderModel <NSObject>

@end

@interface MPDecorationBidderModel : SHModel

//"avatar" : "http://cas.juranzx.com.cn/null",
//"current_actions" : null,
//"declaration" : "应标宣言",
//"design_contract" :
//"designer_id" : 20730187,
//"join_time" : "2016-02-25 02:12:47",
//"measure_time" : null,
//"measurement_fee" : null,
//"orders" :
//"refused_time" : null,
//"selected_time" : null,
//"status" : "1",
//"uid" : "a25fd718-348b-4021-becc-f3c5d0399141",
//"user_name" : null,
//"wk_cur_node_id" : "3",
//"wk_cur_sub_node_id" : "31",
//"wk_current_step_id" : null,
//"wk_id" : "1475",
//"wk_next_possible_sub_node_ids" :
//"wk_steps" : null
//"design_price_max" = 120;
//"design_price_min" = 60;

@property (nonatomic, copy) NSString *design_thread_id;

@property (nonatomic, copy) NSString *need_id;

@property (nonatomic, copy) NSString *design_price_max; 
@property (nonatomic, copy) NSString *design_price_min;
@property (nonatomic, copy) NSString *style_names; //null

@property (nonatomic, copy) NSString *avatar; //null
@property (nonatomic, copy) NSString *current_actions; //null
@property (nonatomic, copy) NSString *declaration;

@property (nonatomic, retain) MPDesiContractModel *design_contract;

@property (nonatomic, retain) NSNumber *designer_id;
@property (nonatomic, copy) NSString *join_time;
@property (nonatomic, copy) NSString *measure_time;
@property (nonatomic, copy) NSString *measurement_fee; //量房费

@property (nonatomic, retain) NSArray<MPBidderOrderModel> *orders;

@property (nonatomic, copy) NSString *refused_time; //null
@property (nonatomic, copy) NSString *selected_time; //null
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *user_name;
@property (nonatomic, copy) NSString *wk_cur_node_id;
@property (nonatomic, copy) NSString *wk_cur_sub_node_id;
@property (nonatomic, copy) NSString *wk_current_step_id; //null
@property (nonatomic, copy) NSString *wk_id;

@property (nonatomic, retain) NSArray<MPDecoWkSubNodeIds> *wk_next_possible_sub_node_ids;

/// 
@property (nonatomic, copy) NSString *template_id;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
