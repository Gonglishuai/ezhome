
#import "SHModel.h"
#import "MPDesignerModel.h"
#import "MPDesiRealNameModel.h"

@protocol MPDesignerInfoModel <NSObject>

@end

@interface MPDesignerInfoModel : SHModel

//"address" : null,
//"avatar" : "http://cas.juranzx.com.cn/null",
//"birthday" : "",
//"city" : "110100",
//"designer" :
//"district" : null,
//"email" : "hui.li@leediancn.com",
//"first_name" : null,
//"gender" : 1,
//"has_secreted" : null,
//"hitachi_account" : "hui.li",
//"home_phone" : "",
//"hs_uid" : null,
//"is_email_binding" : null,
//"is_order_sms" : 0,
//"is_validated_by_mobile" : 0,
//"last_name" : null,
//"member_id" : 1398797,
//"mobile_number" : null,
//"nick_name" : "1398797",
//"province" : null,
//"real_name" :
//"register_date" : null,
//"user_name" : null,
//"zip_code" : ""

@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, copy) NSString *city;

@property (nonatomic, retain) MPDesignerModel *designer;

@property (nonatomic, copy) NSString *district;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *first_name;
@property (nonatomic, copy) NSString *gender;  //0：保密 1：女 2：男
@property (nonatomic, copy) NSString *has_secreted;
@property (nonatomic, copy) NSString *hitachi_account;
@property (nonatomic, copy) NSString *home_phone;
@property (nonatomic, copy) NSString *hs_uid;
@property (nonatomic, copy) NSString *is_email_binding;
@property (nonatomic, retain) NSNumber *is_order_sms;
@property (nonatomic, copy) NSString *is_validated_by_mobile;
@property (nonatomic, copy) NSString *last_name;
@property (nonatomic, retain) NSNumber *member_id;
@property (nonatomic, copy) NSString *mobile_number;
@property (nonatomic, copy) NSString *nick_name;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, retain) MPDesiRealNameModel *real_name;
@property (nonatomic, copy) NSString *register_date;
@property (nonatomic, copy) NSString *user_name;
@property (nonatomic, copy) NSString *zip_code;
@property (nonatomic, copy) NSString *is_following;
@property (nonatomic, retain) NSNumber *evalution_avg_scores;
@property (nonatomic, retain) NSNumber *evalution_count;
@property (nonatomic, copy) NSString *follows;
@property (nonatomic, strong) NSString *jmember_id;

- (instancetype)initWithDictionary:(NSDictionary *)dict;


@end
