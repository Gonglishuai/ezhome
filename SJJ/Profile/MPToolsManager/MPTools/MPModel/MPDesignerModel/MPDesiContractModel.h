
#import "SHModel.h"

@interface MPDesiContractModel : SHModel

//"contract_charge" : "4000",
//"contract_data" : "[{key:value},{key1:value1},{key2:value2}]",
//"contract_first_charge" : "3000",
//"contract_no" : "100001",
//"contract_template_url" : "www.baidu.com",
//"contract_type" : 0,
//"designer_id" : 20730187
@property (nonatomic, copy) NSString *contract_charge;
@property (nonatomic, copy) NSString *contract_data;
@property (nonatomic, copy) NSString *contract_first_charge;
@property (nonatomic, copy) NSString *contract_no;
@property (nonatomic, copy) NSString *contract_template_url;
@property (nonatomic, retain) NSNumber *contract_type;
@property (nonatomic, retain) NSNumber *designer_id;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
