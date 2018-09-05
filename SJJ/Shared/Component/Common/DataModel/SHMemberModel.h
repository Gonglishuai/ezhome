/**
 * @file    MPMemberModel.h
 * @brief   the view of MPMemberModel
 * @author  fu
 * @version 1.0
 * @date    2015-12-29
 */

#import "SHModel.h"

@interface SHMemberModel : SHModel

/// memeber center address.
@property (nonatomic,copy)NSString *address;
/// member center head icon.
@property (nonatomic,copy)NSString *avatar;
/// member center suaname.
@property (nonatomic,copy)NSString *first_name;
/// member center gender.
@property (nonatomic,copy)NSString *gender;
/// member center phone number.
@property (nonatomic,copy)NSString *mobile_number;
/// member center nickname.
@property (nonatomic,copy)NSString *nick_name;
/// memeber center email.
@property (nonatomic,copy)NSString *user_email;
/// member center certification code.
@property (nonatomic,copy)NSString *certificate_code;
/// member center certification type.
@property (nonatomic,copy)NSString *certificate_type;
/// member center true name.
@property (nonatomic,copy)NSString *true_name;
/// memeber center acount.
@property (nonatomic,copy)NSString *acount;
/// member center email.
@property (nonatomic,copy)NSString *email;
/// member center head icon url.
@property (nonatomic,copy)NSString *hitachi_account;
/// member center province.
@property (nonatomic,copy)NSString *province;
/// member center city.
@property (nonatomic,copy)NSString *city;
/// member center town.
@property (nonatomic,copy)NSString *town;
/// member center district.
@property (nonatomic,copy)NSString *district;
/// member center province name.
@property (nonatomic,copy)NSString *province_name;
/// member center city name.
@property (nonatomic,copy)NSString *city_name;
/// member center district name.
@property (nonatomic,copy)NSString *district_name;
/// member center home phone.
@property (nonatomic,copy)NSString *home_phone;
/// member center birthday.
@property (nonatomic,copy)NSString *birthday;
/// member center zip code.
@property (nonatomic,copy)NSString *zip_code;
/// member center id card.
@property (nonatomic,copy)NSString *id_card;
/// member center measurement price.
@property (nonatomic,copy)NSString *measurement_price;
/// member center design price max.
@property (nonatomic,copy)NSString *design_price_max;
/// member center design price min.
@property (nonatomic,copy)NSString *design_price_min;
/// member center is loho.
@property (nonatomic,copy)NSString *is_loho;
/// member center style long name.
@property (nonatomic,copy)NSString *style_long_names;
/// member center introduction.
@property (nonatomic,copy)NSString *introduction;
/// member center experience.
@property (nonatomic,copy)NSString *experience;
/// member center case count.
@property (nonatomic,copy)NSString *case_count;
/// member center personal honour.
@property (nonatomic,copy)NSString *personal_honour;
/// member center DIY count.
@property (nonatomic,copy)NSString *diy_count;
/// member center theme pic.
@property (nonatomic,copy)NSString *theme_pic;
/// validate phone number,0 is unbinding, 1 is binded,2 is after unbinding.
@property (nonatomic, copy) NSString *validate_by_mobile;

@property (nonatomic, copy) NSString *is_email_binding;

@property (nonatomic, copy) NSString *thread_id;

@property (nonatomic, copy) NSString *pointAmount;

@property (nonatomic, copy) NSString *couponsAmount;
/**
 * @brief MemberWithDict:(NSDictionary *)dict.
 *
 * @param  dict dictionary data.
 *
 * @return id.
 */
+ (instancetype)MemberWithDict:(NSDictionary *)dict;
/**
 * @brief MemberInformation:(NSString *)member_id.
 *
 * @param  member_id  the member id.
 *
 * @return void.
 */


@end
