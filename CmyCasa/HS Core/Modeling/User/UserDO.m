//
//  UserDO.m
//  Homestyler
//
//  Created by Berenson Sergei on 7/23/13.
//
//

#import "UserDO.h"
#import "UserExtendedDetails.h"

#import "NSString+Contains.h"
#import "UserComboDO.h"
#define RECORD_TITLES_COLORING ([UIColor colorWithRed:90.0f/255.f green:91.0f/255.f blue:93.0f/255.f alpha:1.0f])

@implementation
UserDO




-(instancetype)init{
    
    self=[super init];
    
    self.extendedDetails=[UserExtendedDetails  new];
    
    self.allowEmails=YES;
    return self;
}

+ (RKObjectMapping*)jsonMapping{
    
    //{"s":"EF368FAFCD3CE2B9EA2D4DE3D63A42F2.workera","utype":1,"firstname":"s","lastname":"sss","photo":"","accepted":true,"pro":false,"uid":"M6UECTKHG7I4IV1","allowEmails":true,"location":"","following":["MHHYYL8HHVOE49G","MHEO9QHHHVOGTQQ","M90M1FXHHVOEGGG","MLJK5Z6HHVOGDM1"],"description":"","er":-1,"erMessage":""}
    
    RKObjectMapping* entityMapping = [super jsonMapping];
    
    [entityMapping addAttributeMappingsFromDictionary:
     @{
       @"uid" : @"userID",
       @"s" : @"sessionId",
       @"firstname" : @"firstName",
       @"lastname" : @"lastName",
       @"s" : @"userID",
       @"s" : @"userEmail",
       @"photo" : @"userProfileImage",
       @"pro" : @"isProfessional",
       @"accepted" : @"termsAccepted",
       @"allowEmails" : @"allowEmails",
       @"description" : @"userDescription",
       @"utype" : @"serverUserType",
       
       }];
    
    
    
    return entityMapping;
}

- (void)applyPostServerActions{
    //The user type is default value the actual caller facebook/google/ will set its actual user type
    self.usertype=kUserTypeEmail;
    
    if (self.userDescription==nil) {
        self.userDescription=@"";
    }
    if (self.firstName==nil) {
        self.firstName=@"";
    }
    if (self.lastName==nil) {
        self.lastName=@"";
    }
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.firstName];
    [aCoder encodeObject:self.lastName];
    [aCoder encodeObject:self.userID];
    [aCoder encodeObject:self.userEmail];
    [aCoder encodeObject:self.webLoginExternalSessionId];
    //    [aCoder encodeObject:self.sessionId];
    [aCoder encodeObject:self.userPassword];
    [aCoder encodeObject:self.userPhone];
    [aCoder encodeObject:self.umsToken];
    [aCoder encodeObject:self.userProfileImage];
    [aCoder encodeObject:self.userDescription];
    [aCoder encodeObject:self.serverUserType];
    [aCoder encodeObject:self.userProfession];
    [aCoder encodeBool:self.allowEmails forKey:@"allowEmails"];
    [aCoder encodeBool:self.isProfessional forKey:@"isProfessional"];
    [aCoder encodeBool:self.termsAccepted forKey:@"termsAccepted"];
    [aCoder encodeInt:self.usertype forKey:@"usertype"];
    [aCoder encodeObject:self.extendedDetails];
}


- (id)copyWithZone:(NSZone *)zone {
    UserDO *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy != nil) {
        copy.firstName = [self.firstName copy];
        copy.lastName = [self.lastName copy];
        copy.userID = [self.userID copy];
        copy.userEmail = [self.userEmail copy];
        copy.userProfession = [self.userProfession copy];
        copy.sessionId = [self.sessionId copy];
        copy.userPassword = [self.userPassword copy];
        copy.userPhone = [self.userPhone copy];
        copy.umsToken = [self.umsToken copy];
        copy.userProfileImage = [self.userProfileImage copy];
        copy.userDescription = [self.userDescription copy];
        copy.serverUserType = [self.serverUserType copy];
        copy.extendedDetails = [self.extendedDetails copy];
        copy.usertype = self.usertype;
        copy.allowEmails = self.allowEmails;
        copy.isProfessional = self.isProfessional;
        copy.termsAccepted = self.termsAccepted;
        copy.webLoginExternalSessionId = self.webLoginExternalSessionId;
    }
    
    return copy;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self=[super init];
    
    [self setFirstName:[aDecoder decodeObject]];
    [self setLastName:[aDecoder decodeObject]];
    [self setUserID:[aDecoder decodeObject]];
    [self setUserEmail:[aDecoder decodeObject]];
    [self setWebLoginExternalSessionId:[aDecoder decodeObject]];
    //   [self setSessionId:[aDecoder decodeObject]];
    [self setUserPassword:[aDecoder decodeObject]];
    [self setUserPhone:[aDecoder decodeObject]];
    [self setUmsToken:[aDecoder decodeObject]];
    [self setUserProfileImage:[aDecoder decodeObject]];
    [self setUserDescription:[aDecoder decodeObject]];
    [self setServerUserType:[aDecoder decodeObject]];
    [self setUserProfession:[aDecoder decodeObject]];
    [self setAllowEmails:[aDecoder decodeBoolForKey:@"allowEmails"]];
    [self setIsProfessional:[aDecoder decodeBoolForKey:@"isProfessional"]];
    [self setTermsAccepted:[aDecoder decodeBoolForKey:@"termsAccepted"]];
    [self setUsertype:[aDecoder decodeIntForKey:@"usertype"]];
    [self setExtendedDetails:[aDecoder decodeObject]];

    //TODO: add extended data if needed.
    return self;
}

-(NSString*)getUserFullName{
    
    NSString * fname=self.firstName;
    NSString * lname=self.lastName;
    NSString* fullname=@"";
    if ([fname length]==0 && [lname length]==0) {
        
        
    }else if ([fname length]!=0 && [lname length]==0)
        fullname=[NSString stringWithFormat:@"%@",fname];
    else if([fname length]==0 && [lname length]!=0)
        fullname=[NSString stringWithFormat:@"%@",lname];
    else
        fullname=[NSString stringWithFormat:@"%@ %@",fname, lname];
    
    return fullname;
}



-(NSMutableArray*)getUserProfileDetails:(BOOL)editMode{
    
    NSMutableArray * userSections=[NSMutableArray array];
    
    
    //TODO: Sergei remove me
    
    
    //    self.extendedDetails=[[UserExtendedDetails alloc] init];
    //
    //    self.extendedDetails.website=@"http://www.walla.com";
    //    UserComboDO * prof1=[UserComboDO new];
    //    [prof1 setComboName:@"Grapthic Designer"];
    //
    //
    //    self.extendedDetails.proffessions=[NSMutableArray arrayWithObjects:prof1, nil];
    //    UserComboDO * interest1=[UserComboDO new];
    //    [interest1 setComboName:@"TV"];
    //
    //    self.extendedDetails.interests=[NSMutableArray arrayWithObjects:interest1, nil];
    //
    //    UserComboDO * mayaCombo=[UserComboDO new];
    //    [mayaCombo setComboName:@"Maya"];
    //
    //    self.extendedDetails.designingTools=[NSMutableArray arrayWithObjects:mayaCombo, nil];
    //
    //    UserComboDO * style1=[UserComboDO new];
    //    [style1 setComboName:@"Modern"];
    //    self.extendedDetails.favoriteStyles=[NSMutableArray arrayWithObjects:style1, nil];
    //
    //    self.extendedDetails.userType=@"Expert";
    //    self.extendedDetails.gender=[UserComboDO new];
    //    self.extendedDetails.gender.comboName=@"male";
    //    self.userDescription=@"Lorem ipsum dolor sit amet, graece voluptatibus ut vis. Ad dolor consetetur eos, at iuvaret suavitate omittantur ius. Id ipsum omittantur per, per no dolor vituperata. Sed minim nonumy id. Dictas pericula philosophia sea ne, ea esse partem vituperatoribus qui, unum choro quidam ut qui. Ne eum facer interesset.Lorem ipsum dolor sit amet, graece voluptatibus ut vis. Ad dolor consetetur eos, at iuvaret suavitate omittantur ius. Id ipsum omittantur per, per no dolor vituperata. Sed minim nonumy id. Dictas pericula philosophia sea ne, ea esse partem vituperatoribus qui, unum choro quidam ut qui. Ne eum facer interesset.Lorem ipsum dolor sit amet, graece voluptatibus ut vis. Ad dolor consetetur eos, at iuvaret suavitate omittantur ius. Id ipsum omittantur per, per no dolor vituperata. Sed minim nonumy id. Dictas pericula philosophia sea ne, ea esse partem vituperatoribus qui, unum choro quidam ut qui. Ne eum facer interesset.";
    //
    //    self.extendedDetails.location=@"Tel- Aviv, Israel";
    //
    //generate base section
    
    
    
    if (editMode) {
        
        //PROFILE IMAGE
        NSDictionary * image= @{USER_DETAIL_ROW_TYPE_KEY:[NSNumber numberWithInt:KUDfieldUserProfile],
                                USER_DETAIL_ROW_TYPE_VALUE:(self.userProfileImage)?self.userProfileImage:@"",
                                USER_DETAIL_TEMP_IMAGE:(self.tempEditProfileImage)?self.tempEditProfileImage:[NSNull null],
                                USER_TYPE_VALUE:  [NSNumber numberWithInt:self.usertype],
                                USER_DETAIL_DATA_MODEL_FIELD:[NSNumber numberWithInt:kFieldProfileImage]
                                };
        [userSections addObject:[NSMutableDictionary dictionaryWithDictionary:image]];
        
        //PROFILE NAME
        if (![NSString isNullOrEmpty:self.firstName] && ![NSString isNullOrEmpty:self.lastName]) {
            [self createUIItemForUserParameter:userSections rowType:KUDfieldComposite2Texts rowVal:[NSArray arrayWithObjects:self.firstName,self.lastName, nil]
                                      rowTitle:NSLocalizedString(@"user_profile_cell_Name_lbl", @"") modelField:kFieldFullName];
        } else{
            if (![NSString isNullOrEmpty:self.firstName]) {
                
                [self createUIItemForUserParameter:userSections rowType:KUDfieldComposite2Texts rowVal:[NSArray arrayWithObjects:self.firstName,@"", nil]
                                          rowTitle:NSLocalizedString(@"user_profile_cell_Name_lbl", @"") modelField:kFieldFullName];
                
                
            }else
                
                if (![NSString isNullOrEmpty:self.lastName]) {
                    [self createUIItemForUserParameter:userSections rowType:KUDfieldComposite2Texts rowVal:[NSArray arrayWithObjects:@"",self.lastName, nil]
                                              rowTitle:NSLocalizedString(@"user_profile_cell_Name_lbl", @"") modelField:kFieldFullName];
                    
                    
                }else{
                    [self createUIItemForUserParameter:userSections rowType:KUDfieldComposite2Texts rowVal:[NSArray arrayWithObjects:@"",@"", nil]
                                              rowTitle:NSLocalizedString(@"user_profile_cell_Name_lbl", @"") modelField:kFieldFullName];
                }
            
        }
        
        if (IS_IPHONE) {
            
//            //WEB site
//            [self createUIItemForUserParameter:userSections rowType:KUDfieldTextfield rowVal:(self.extendedDetails.website)?self.extendedDetails.website:@""
//                                      rowTitle:NSLocalizedString(@"user_profile_cell_website_lbl", @"") modelField:kFieldWebsite];
            
            //GENDER
            UserComboDO * gender=[UserComboDO new];
            gender.comboName=@"O";
            
            
            [self createUIItemForUserParameter:userSections rowType:KUDfieldGenderSelection rowVal:(self.extendedDetails.gender)?self.extendedDetails.gender:gender
                                      rowTitle:NSLocalizedString(@"user_profile_cell_gender_lbl", @"") modelField:kFieldGender];
            
            //Location
            [self createUIItemForUserParameter:userSections rowType:KUDLocation rowVal:(self.extendedDetails.location && self.extendedDetails.locationVisible==YES)?self.extendedDetails.location:@""
                                      rowTitle:NSLocalizedString(@"user_profile_cell_location_lbl", @"") modelField:kFieldLocation];
            
            //Description
            [self createUIItemForUserParameter:userSections rowType:KUDfieldLongText rowVal:(self.userDescription)?self.userDescription:@""
                                      rowTitle:NSLocalizedString(@"user_profile_cell_description_lbl", @"") modelField:kFieldDescription];
            
//            //User Type
//            
//            [self createUIItemForUserParameter:userSections rowType:KUDfieldTextfieldWithAction rowVal:(self.extendedDetails.userType) ? self.extendedDetails.userType : @""
//                                      rowTitle:NSLocalizedString(@"user_profile_cell_usertype_lbl", @"") modelField:kFieldUserTypes];
//            
//            //Profession
//            [self createUIItemForUserParameter:userSections rowType:KUDfieldTextfieldWithAction rowVal:(self.extendedDetails.proffessions) ? self.extendedDetails.proffessions : [NSArray array]
//                                      rowTitle:NSLocalizedString(@"user_profile_cell_profession_lbl", @"") modelField:kFieldProfessions];
//            
//            
//            //Other tools
//            [self createUIItemForUserParameter:userSections rowType:KUDfieldTextfieldWithAction rowVal:(self.extendedDetails.designingTools) ? self.extendedDetails.designingTools : [NSArray array]
//                                      rowTitle:NSLocalizedString(@"user_profile_cell_tools_lbl", @"") modelField:kFieldDesignTools];
//            
//            //Favorite styles
//            [self createUIItemForUserParameter:userSections rowType:KUDfieldTextfieldWithAction rowVal:(self.extendedDetails.favoriteStyles) ? self.extendedDetails.favoriteStyles : [NSArray array]
//                                      rowTitle:NSLocalizedString(@"user_profile_cell_favstyles_lbl", @"") modelField:kFieldFavoriteStyles];
//            
//            //Interests
//            [self createUIItemForUserParameter:userSections rowType:KUDfieldLongText rowVal:(self.extendedDetails.interests)?self.extendedDetails.interests:@""
//                                      rowTitle:NSLocalizedString(@"user_profile_cell_interests_lbl", @"") modelField:kFieldInterests];
        }
        else {
            
            //GENDER
            UserComboDO * gender=[UserComboDO new];
            gender.comboName=@"O";
            
            
            [self createUIItemForUserParameter:userSections rowType:KUDfieldGenderSelection rowVal:(self.extendedDetails.gender)?self.extendedDetails.gender:gender
                                      rowTitle:NSLocalizedString(@"user_profile_cell_gender_lbl", @"") modelField:kFieldGender];
            
            //Location
            [self createUIItemForUserParameter:userSections rowType:KUDLocation rowVal:(self.extendedDetails.location && self.extendedDetails.locationVisible==YES)?self.extendedDetails.location:@""
                                      rowTitle:NSLocalizedString(@"user_profile_cell_location_lbl", @"") modelField:kFieldLocation];
            
            //Description
            [self createUIItemForUserParameter:userSections rowType:KUDfieldLongText rowVal:(self.userDescription)?self.userDescription:@""
                                      rowTitle:NSLocalizedString(@"user_profile_cell_description_lbl", @"") modelField:kFieldDescription];
            
//            //User Type
//            
//            [self createUIItemForUserParameter:userSections rowType:KUDfieldTextfieldWithAction rowVal:(self.extendedDetails.userType) ? self.extendedDetails.userType : @""
//                                      rowTitle:NSLocalizedString(@"user_profile_cell_usertype_lbl", @"") modelField:kFieldUserTypes];
//            
//            //Profession
//            [self createUIItemForUserParameter:userSections rowType:KUDfieldTextfieldWithAction rowVal:(self.extendedDetails.proffessions) ? self.extendedDetails.proffessions : [NSArray array]
//                                      rowTitle:NSLocalizedString(@"user_profile_cell_profession_lbl", @"") modelField:kFieldProfessions];
//            
//            //WEB site
//            [self createUIItemForUserParameter:userSections rowType:KUDfieldTextfield rowVal:(self.extendedDetails.website)?self.extendedDetails.website:@""
//                                      rowTitle:NSLocalizedString(@"user_profile_cell_website_lbl", @"") modelField:kFieldWebsite];
//            
//            //Other tools
//            [self createUIItemForUserParameter:userSections rowType:KUDfieldTextfieldWithAction rowVal:(self.extendedDetails.designingTools) ? self.extendedDetails.designingTools : [NSArray array]
//                                      rowTitle:NSLocalizedString(@"user_profile_cell_tools_lbl", @"") modelField:kFieldDesignTools];
//            
//            //Favorite styles
//            [self createUIItemForUserParameter:userSections rowType:KUDfieldTextfieldWithAction rowVal:(self.extendedDetails.favoriteStyles) ? self.extendedDetails.favoriteStyles : [NSArray array]
//                                      rowTitle:NSLocalizedString(@"user_profile_cell_favstyles_lbl", @"") modelField:kFieldFavoriteStyles];
//            
//            //Interests
//            [self createUIItemForUserParameter:userSections rowType:KUDfieldLongText rowVal:(self.extendedDetails.interests)?self.extendedDetails.interests:@""
//                                      rowTitle:NSLocalizedString(@"user_profile_cell_interests_lbl", @"") modelField:kFieldInterests];
            
        }
        
        
//        //Add finish Controls
//        if(IS_IPAD){
//            [self createUIItemForUserParameter:userSections rowType:KUDControls rowVal:@""
//                                      rowTitle:@"" modelField:KFieldControls];
//        }
        
    }else {
        
        if (IS_IPAD) {
            return [self generateReadOnlyIpadUserDetails];
        }
        if (IS_IPHONE) {
            return [self generateReadOnlyIphoneUserDetails];
        }
        
    }
    
    
    
    
    
    
    return userSections;
}
-(NSMutableArray*)generateReadOnlyIphoneUserDetails{
    //Read only mode
    NSMutableArray * userSections=[NSMutableArray array];
    
    //Full name
    NSString * userComposedName=[self getUserFullName];
    
    NSMutableDictionary * compositeUserDetails=[NSMutableDictionary dictionary];
    
    if([userComposedName length]>0)
    {
        NSString *professionString = userComposedName;
        
        
        [compositeUserDetails setObject:professionString forKey:@"fullname"];
    }
    
    //PROFILE IMAGE
    if (![NSString isNullOrEmpty:self.userProfileImage]) {
        [compositeUserDetails setObject:self.userProfileImage forKey:@"image"];
    }
    
    //profession
    UserComboDO * profession;
    if ([self.extendedDetails.proffessions count]>0) {
        profession=[self.extendedDetails.proffessions objectAtIndex:0];
        if (!profession) {
            profession=[UserComboDO new];
            profession.comboName=@"";
        }
        
        NSString *professionString = profession.comboName;
        
        [compositeUserDetails setObject:professionString forKey:@"profession"];
        
    }
    
    [self createUIItemForUserParameter:userSections rowType:KUDfieldUserProfileIphone rowVal:compositeUserDetails
                              rowTitle:@"" modelField:kFieldProfileImage];
    
    
    
    //Description
    
    if (![NSString isNullOrEmpty:self.userDescription]) {
        
        [self createUIItemForUserParameter:userSections rowType:KUDfieldReadDynamicLabelText rowVal:self.userDescription
                                  rowTitle:NSLocalizedString(@"user_profile_cell_description_lbl_read", @"") modelField:kFieldDescription];
        
        
        
    }else{
        NSString* rowText=NSLocalizedString(@"user_profile_cell_description_lbl_read", @"");
        NSMutableAttributedString * attrString=[[NSMutableAttributedString alloc] initWithString:rowText attributes:@{}];
        
        [attrString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.f]} range: [rowText rangeOfString:NSLocalizedString(@"user_profile_cell_description_lbl_read", @"")]];
        
        [self createUIItemForUserParameter:userSections rowType:KUDfieldReadDynamicLabelText rowVal:attrString
                                  rowTitle:@"" modelField:kFieldDescription];
    }
    
    
    //WEB site
    if(![NSString isNullOrEmpty:self.extendedDetails.website]){
        [self createUIItemForUserParameter:userSections rowType:KUDfieldWebLink rowVal:self.extendedDetails.website
                                  rowTitle:@"" modelField:kFieldWebsite];
    }else{
        [self createUIItemForUserParameter:userSections rowType:KUDfieldWebLink rowVal:@""
                                  rowTitle:@"" modelField:kFieldWebsite];
    }
    
    //Gender
    NSString *gender = [NSString string];
    if ([self.extendedDetails.gender.comboName isEqualToString:@"M"]) {
        gender = NSLocalizedString(@"Male_segment_option", @"");
    }
    else if ([self.extendedDetails.gender.comboName isEqualToString:@"F"]){
        gender = NSLocalizedString(@"Female_segment_option", @"");
    }else{
        gender = @"";
    }
    [self createUIItemForUserParameter:userSections rowType:KUDfieldReadOnlyIcon rowVal:gender
                              rowTitle:@"" modelField:kFieldGender];
    
    //Location
    if (![NSString isNullOrEmpty:self.extendedDetails.location]) {
        
        [self createUIItemForUserParameter:userSections rowType:KUDfieldReadOnlyIcon rowVal:self.extendedDetails.location
                                  rowTitle:@"" modelField:kFieldLocation];
        
    }
    else {
        
        [self createUIItemForUserParameter:userSections rowType:KUDfieldReadOnlyIcon rowVal:@""
                                  rowTitle:@"" modelField:kFieldLocation];
    }
    
    //user type
    //  if (![NSString isNullOrEmpty:self.extendedDetails.userType]) {
    
    
    NSString *iAmString = (self.extendedDetails.userType)?self.extendedDetails.userType.comboName:@"";
    NSString * rowText=[NSString stringWithFormat:@"%@\n%@",NSLocalizedString(@"user_profile_cell_usertype_lbl_read", @""),iAmString];
    NSMutableAttributedString * attrString=[[NSMutableAttributedString alloc] initWithString:rowText attributes:@{}];
    
    [attrString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14.f], NSForegroundColorAttributeName : [UIColor colorWithRed:69.f/255.f green:69.f/255.f blue:69.f/255.f alpha:1.f]} range: [rowText rangeOfString:NSLocalizedString(@"user_profile_cell_usertype_lbl_read", @"")]];
    [attrString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.f], NSForegroundColorAttributeName : [UIColor colorWithRed:142.f/255.f green:142.f/255.f blue:142.f/255.f alpha:1.f]} range: [rowText rangeOfString:iAmString]];
    
    [self createUIItemForUserParameter:userSections rowType:KUDfieldReadLabelText rowVal:attrString
                              rowTitle:@"" modelField:kFieldUserTypes];
    // }
    
    //Other tools
    // if (self.extendedDetails.designingTools) {
    
    NSMutableString *  str=[NSMutableString string];
    for(UserComboDO * combo in self.extendedDetails.designingTools)
    {
        if ([str length]==0)
        {
            [str appendString:combo.comboName];
        }else{
            [str appendString:[NSString stringWithFormat:@", %@",combo.comboName]];
        }
        
    }
    
    rowText=[NSString stringWithFormat:@"%@\n%@",NSLocalizedString(@"user_profile_cell_tools_lbl_read", @""),str];
    
    
    attrString=[[NSMutableAttributedString alloc] initWithString:rowText attributes:@{}];
    
    [attrString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14.f], NSForegroundColorAttributeName : [UIColor colorWithRed:69.f/255.f green:69.f/255.f blue:69.f/255.f alpha:1.f]} range: [rowText rangeOfString:NSLocalizedString(@"user_profile_cell_tools_lbl_read", @"")]];
    [attrString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.f], NSForegroundColorAttributeName : [UIColor colorWithRed:142.f/255.f green:142.f/255.f blue:142.f/255.f alpha:1.f]} range: [rowText rangeOfString:str]];
    
    [self createUIItemForUserParameter:userSections rowType:KUDfieldReadLabelText rowVal:attrString
                              rowTitle:@"" modelField:kFieldDesignTools];
    
    //  }
    
    //Favorite styles
    // if (self.extendedDetails.favoriteStyles) {
    
    str=[NSMutableString string];
    for(UserComboDO * combo in self.extendedDetails.favoriteStyles)
    {
        if ([str length]==0)
        {
            [str appendString:combo.comboName];
        }else{
            [str appendString:[NSString stringWithFormat:@", %@",combo.comboName]];
        }
        
    }
    
    rowText=[NSString stringWithFormat:@"%@\n%@",NSLocalizedString(@"user_profile_cell_favstyles_lbl_read", @""),str];
    
    
    attrString=[[NSMutableAttributedString alloc] initWithString:rowText attributes:@{}];
    
    [attrString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14.f], NSForegroundColorAttributeName : [UIColor colorWithRed:69.f/255.f green:69.f/255.f blue:69.f/255.f alpha:1.f]} range: [rowText rangeOfString:NSLocalizedString(@"user_profile_cell_favstyles_lbl_read", @"")]];
    [attrString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.f], NSForegroundColorAttributeName : [UIColor colorWithRed:142.f/255.f green:142.f/255.f blue:142.f/255.f alpha:1.f]} range: [rowText rangeOfString:str]];
    
    
    [self createUIItemForUserParameter:userSections rowType:KUDfieldReadLabelText rowVal:attrString
                              rowTitle:@"" modelField:kFieldFavoriteStyles];
    //   }
    
    
    
    NSString *interests = (self.extendedDetails.interests)?self.extendedDetails.interests:@"";
    rowText=[NSString stringWithFormat:@"%@\n%@",NSLocalizedString(@"user_profile_cell_interests_lbl_read", @""),interests];
    
    attrString=[[NSMutableAttributedString alloc] initWithString:rowText attributes:@{}];
    [attrString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14.f], NSForegroundColorAttributeName : [UIColor colorWithRed:69.f/255.f green:69.f/255.f blue:69.f/255.f alpha:1.f]} range: [rowText rangeOfString:NSLocalizedString(@"user_profile_cell_interests_lbl_read", @"")]];
    [attrString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.f], NSForegroundColorAttributeName : [UIColor colorWithRed:142.f/255.f green:142.f/255.f blue:142.f/255.f alpha:1.f]} range: [rowText rangeOfString:interests]];
    
    
    //        [self createUIItemForUserParameter:userSections rowType:KUDfieldReadLabelText rowVal:attrString
    //                                  rowTitle:@"" modelField:kFieldInterests];
    
    // }
    
    
    
    [self createUIItemForUserParameter:userSections rowType:KUDfieldReadDynamicLabelText rowVal:attrString
                              rowTitle:@"" modelField:kFieldInterests];
    
    
    
    
    return userSections;
}

-(NSMutableArray*)generateReadOnlyIpadUserDetails{
    //Read only mode
    NSMutableArray * userSections=[NSMutableArray array];
    
    //Full name // Profession
    NSString * userComposedName=[self getUserFullName];
    if([userComposedName length]>0)
    {
        UserComboDO * profession;
        if ([self.extendedDetails.proffessions count]>0) {
            profession=[self.extendedDetails.proffessions objectAtIndex:0];
        }
        if (!profession) {
            profession=[UserComboDO new];
            profession.comboName=@"";
        }
        
        userComposedName = [NSString stringWithFormat:@"%@ //", userComposedName];
        
        [self createUIItemForUserParameter:userSections rowType:KUDfieldFullNameAndProfession rowVal:profession.comboName
                                  rowTitle:userComposedName modelField:kFieldFullName];
    }
    
    //WEB site
    if(![NSString isNullOrEmpty:self.extendedDetails.website]){
        [self createUIItemForUserParameter:userSections rowType:KUDfieldWebLink rowVal:self.extendedDetails.website
                                  rowTitle:@"" modelField:kFieldWebsite];
    }else{
        [self createUIItemForUserParameter:userSections rowType:KUDfieldWebLink rowVal:@""
                                  rowTitle:@"" modelField:kFieldWebsite];
    }
    
    //Gender
    NSString *gender = [NSString string];
    if ([self.extendedDetails.gender.comboName isEqualToString:@"M"]) {
        gender = NSLocalizedString(@"Male_segment_option", @"");
    }
    else if ([self.extendedDetails.gender.comboName isEqualToString:@"F"]){
        gender = NSLocalizedString(@"Female_segment_option", @"");
    }else{
        gender = @"";
    }
    [self createUIItemForUserParameter:userSections rowType:KUDfieldReadOnlyIcon rowVal:gender
                              rowTitle:@"" modelField:kFieldGender];
    
    //Location
    if (![NSString isNullOrEmpty:self.extendedDetails.location]) {
        
        [self createUIItemForUserParameter:userSections rowType:KUDfieldReadOnlyIcon rowVal:self.extendedDetails.location
                                  rowTitle:@"" modelField:kFieldLocation];
        
    }
    else {
        
        [self createUIItemForUserParameter:userSections rowType:KUDfieldReadOnlyIcon rowVal:@""
                                  rowTitle:@"" modelField:kFieldLocation];
    }
    
    
    //Description
    NSString * rowText;
    if (![NSString isNullOrEmpty:self.userDescription]) {
        
        [self createUIItemForUserParameter:userSections rowType:KUDfieldReadDynamicLabelText rowVal:self.userDescription
                                  rowTitle:@"" modelField:kFieldDescription];
        
    }else{
        [self createUIItemForUserParameter:userSections rowType:KUDfieldReadDynamicLabelText rowVal:@""
                                  rowTitle:@"" modelField:kFieldDescription];
    }
    
    
    //user type
    rowText=[NSString stringWithFormat:@"%@",(self.extendedDetails.userType)?self.extendedDetails.userType.comboName:@""];
    
    
    [self createUIItemForUserParameter:userSections rowType:KUDfieldReadLabelText rowVal:rowText
                              rowTitle:NSLocalizedString(@"user_profile_cell_usertype_lbl_read", @"") modelField:kFieldUserTypes];
    
    //Favorite styles
    NSMutableString *favoriteStyles = [NSMutableString string];
    for(UserComboDO * combo in self.extendedDetails.favoriteStyles)
    {
        if ([favoriteStyles length]==0)
        {
            [favoriteStyles appendString:combo.comboName];
        }else{
            [favoriteStyles appendString:[NSString stringWithFormat:@", %@",combo.comboName]];
        }
        
    }
    
    [self createUIItemForUserParameter:userSections rowType:KUDfieldReadLabelText rowVal:favoriteStyles
                              rowTitle:NSLocalizedString(@"user_profile_cell_favstyles_lbl_read", @"") modelField:kFieldFavoriteStyles];
    
    //Other tools
    
    NSMutableString *  str=[NSMutableString string];
    for(UserComboDO * combo in self.extendedDetails.designingTools)
    {
        if ([str length]==0)
        {
            [str appendString:combo.comboName];
        }else{
            [str appendString:[NSString stringWithFormat:@", %@",combo.comboName]];
        }
        
    }
    
    [self createUIItemForUserParameter:userSections rowType:KUDfieldReadLabelText rowVal:str
                              rowTitle:NSLocalizedString(@"user_profile_cell_tools_lbl_read", @"") modelField:kFieldDesignTools];
    
    
    
    //Interests
    
    rowText=[NSString stringWithFormat:@"%@", (self.extendedDetails.interests)?self.extendedDetails.interests:@""];
    
    [self createUIItemForUserParameter:userSections rowType:KUDfieldReadLabelText rowVal:rowText
                              rowTitle:NSLocalizedString(@"user_profile_cell_interests_lbl_read", @"") modelField:kFieldInterests];
    
    return userSections;
}


- (void)createUIItemForUserParameter:(NSMutableArray *)userSections rowType:(UserDetailFieldType)kudField rowVal:(id)val rowTitle:(NSString *)title modelField:(UserViewField)field {
    
    
    
    
    NSDictionary * object= @{USER_DETAIL_ROW_TYPE_KEY:[NSNumber numberWithInt:kudField],USER_DETAIL_ROW_TYPE_VALUE:val,
                             USER_DETAIL_ROW_TITLE:title,USER_DETAIL_DATA_MODEL_FIELD:[NSNumber numberWithInt:field],USER_TYPE_VALUE:  [NSNumber numberWithInt:self.usertype]};
    
    
    [userSections addObject: [NSMutableDictionary dictionaryWithDictionary:object]];
}


-(NSMutableDictionary*)generateUpdateJsonDictionary{
    NSMutableDictionary * response=[NSMutableDictionary dictionary];
    
    
    [response setObject:(self.firstName!=nil)?self.firstName:[NSNull null] forKey:@"firstname"];
    [response setObject:(self.lastName!=nil)?self.lastName:[NSNull null] forKey:@"lastname"];
    [response setObject:(self.userEmail!=nil)?self.userEmail:[NSNull null] forKey:@"e"];
    [response setObject:(self.allowEmails==false)?@"false":@"true" forKey:@"allowEmails"];
    [response setObject:(self.userDescription!=nil)?self.userDescription:[NSNull null] forKey:@"description"];
    [response setObject:(self.userPassword!=nil)?self.userPassword:[NSNull null] forKey:@"p"];
    
    //Currently no need to send the url, of the phone because we already uploaded the photo to server
    //[response setObject:(self.userProfileImage!=nil)?self.userProfileImage:[NSNull null] forKey:@"p"];
    
    
    if (self.extendedDetails) {
        [response setObject:(self.extendedDetails.location!=nil)?self.extendedDetails.location:[NSNull null] forKey:@"location"];
        
        NSMutableDictionary * rdata=[self.extendedDetails generateUpdateJsonDictionary];
        
        if (rdata) {
            [response setObject:rdata forKey:@"rData"];
        }
    }
    
    
    return response;
}

-(void)updateLocationWithLocation:(CLLocation*)location andAddress:(CLPlacemark*)addressMark{
    
    self.extendedDetails.gpsAddress=addressMark;
    self.extendedDetails.gpsLocation=location;
    self.extendedDetails.locationVisible=YES;
    self.extendedDetails.locationStatusChanged = YES;
    NSString * freeText=@"";
    
    if (addressMark) {
        
        if (addressMark.country) {
            freeText = [freeText stringByAppendingString:addressMark.country];
        }
        
        if (addressMark.administrativeArea && [addressMark.locality rangeOfString:addressMark.administrativeArea].location==NSNotFound) {
            freeText = [freeText stringByAppendingString:[NSString stringWithFormat:@",%@",addressMark.administrativeArea]];
        }
        
        if (addressMark.locality) {
            freeText = [freeText stringByAppendingString:[NSString stringWithFormat:@",%@",addressMark.locality]];
        }
    }
    
    self.extendedDetails.location=freeText;
    
}


-(void)updateLocalUserDataAfterMetaUpdate:(UserDO*)deltaUser{
    
    if (deltaUser.firstName) {
        self.firstName=[deltaUser.firstName copy];
    }
    if (deltaUser.lastName) {
        self.lastName=[deltaUser.lastName copy];
    }
    
    if (deltaUser.userDescription) {
        self.userDescription=[deltaUser.userDescription copy];
    }
    
    if (deltaUser.userProfileImage && deltaUser.userProfileImage.length > 0) {
        self.userProfileImage=[deltaUser.userProfileImage copy];
    }
    
    if (deltaUser.extendedDetails) {
        [self.extendedDetails updateLocalUserDataAfterMetaUpdate:deltaUser.extendedDetails];
    }
    
    
    
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;
    
    return [self isEqualToADo:other];
}

- (BOOL)isEqualToADo:(UserDO *)aDo {
    if (self == aDo)
        return YES;
    if (aDo == nil)
        return NO;
    if (self.firstName != aDo.firstName && ![self.firstName isEqualToString:aDo.firstName])
        return NO;
    if (self.lastName != aDo.lastName && ![self.lastName isEqualToString:aDo.lastName])
        return NO;
    if (self.userID != aDo.userID && ![self.userID isEqualToString:aDo.userID])
        return NO;
    if (self.userEmail != aDo.userEmail && ![self.userEmail isEqualToString:aDo.userEmail])
        return NO;
    if (self.userProfession != aDo.userProfession && ![self.userProfession isEqualToString:aDo.userProfession])
        return NO;
    if (self.sessionId != aDo.sessionId && ![self.sessionId isEqualToString:aDo.sessionId])
        return NO;
    if (self.userPassword != aDo.userPassword && ![self.userPassword isEqualToString:aDo.userPassword])
        return NO;
    if (self.userPhone != aDo.userPhone && ![self.userPhone isEqualToString:aDo.userPhone])
        return NO;
    if (self.umsToken != aDo.umsToken && ![self.umsToken isEqualToString:aDo.umsToken])
        return NO;
    if (self.userProfileImage != aDo.userProfileImage && ![self.userProfileImage isEqualToString:aDo.userProfileImage])
        return NO;
    if (self.userDescription != aDo.userDescription && ![self.userDescription isEqualToString:aDo.userDescription])
        return NO;
    if (self.serverUserType != aDo.serverUserType && ![self.serverUserType isEqualToString:aDo.serverUserType])
        return NO;
    if (self.extendedDetails != aDo.extendedDetails && ![self.extendedDetails isEqualToDetails:aDo.extendedDetails])
        return NO;
    if (self.usertype != aDo.usertype)
        return NO;
    if (self.allowEmails != aDo.allowEmails)
        return NO;
    if (self.isProfessional != aDo.isProfessional)
        return NO;
    if (self.termsAccepted != aDo.termsAccepted)
        return NO;
    if (self.tempEditProfileImage != aDo.tempEditProfileImage && ![self.tempEditProfileImage isEqual:aDo.tempEditProfileImage])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.firstName hash];
    hash = hash * 31u + [self.lastName hash];
    hash = hash * 31u + [self.userID hash];
    hash = hash * 31u + [self.userEmail hash];
    hash = hash * 31u + [self.userProfession hash];
    hash = hash * 31u + [self.sessionId hash];
    hash = hash * 31u + [self.userPassword hash];
    hash = hash * 31u + [self.userPhone hash];
    hash = hash * 31u + [self.umsToken hash];
    hash = hash * 31u + [self.userProfileImage hash];
    hash = hash * 31u + [self.userDescription hash];
    hash = hash * 31u + [self.serverUserType hash];
    hash = hash * 31u + [self.extendedDetails hash];
    hash = hash * 31u + (NSUInteger) self.usertype;
    hash = hash * 31u + self.allowEmails;
    hash = hash * 31u + self.isProfessional;
    hash = hash * 31u + self.termsAccepted;
    hash = hash * 31u + [self.tempEditProfileImage hash];
    return hash;
}


@end

@implementation SSODO

+ (RKObjectMapping*)jsonMapping{
    RKObjectMapping* entityMapping = [RKObjectMapping mappingForClass:[self class]];
    [entityMapping addAttributeMappingsFromDictionary:
     @{
       @"accessToken" : @"accessToken",
       @"uid": @"uid",
       @"ezUid": @"memberId",
       @"memberType": @"memberType",
       @"userName" : @"userName",
       @"avatar" : @"avatar",
       @"nickName" : @"nickName",
       @"nimToken" : @"nimToken",
       }];
    
    return entityMapping;
}

@end

@implementation PasswordDO

@end
