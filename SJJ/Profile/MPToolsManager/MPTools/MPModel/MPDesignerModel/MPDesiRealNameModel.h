
#import "SHModel.h"

@interface MPDesiRealNameModel : SHModel
//"audit_date" : null,
//"audit_status" : null,
//"auditor" : null,
//"auditor_opinion" : null,
//"birthday" : null,
//"certificate_no" : "123456789987654321",
//"certificate_type" : null,
//"mobile_number" : null,
//"photo_back_end" : null,
//"photo_front_end" : null,
//"photo_in_hand" : null,
//"real_name" : "Hugo.li"
@property (nonatomic, copy) NSString *audit_date;
@property (nonatomic, copy) NSString *audit_status;
@property (nonatomic, copy) NSString *auditor;
@property (nonatomic, copy) NSString *auditor_opinion;
@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, copy) NSString *certificate_no;
@property (nonatomic, copy) NSString *certificate_type;
@property (nonatomic, copy) NSString *mobile_number;
@property (nonatomic, copy) NSString *photo_back_end;
@property (nonatomic, copy) NSString *photo_front_end;
@property (nonatomic, copy) NSString *photo_in_hand;
@property (nonatomic, copy) NSString *real_name;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
