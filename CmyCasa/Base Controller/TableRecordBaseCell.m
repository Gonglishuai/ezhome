//
//  TableRecordBaseCell.m
//  Homestyler
//
//  Created by Berenson Sergei on 12/18/13.
//
//

#import "TableRecordBaseCell.h"
#import "UserDO.h"
#import "ProfileUserDetailsViewController_iPad.h"

@interface TableRecordBaseCell()

@property(nonatomic,readwrite)BOOL canPeformAction;
@property(nonatomic,readwrite) BOOL isEditing;
@property(nonatomic,assign) BOOL isAlertMessageActive;

- (BOOL)nameFieldValidation:(id)field;
@end
@implementation TableRecordBaseCell



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark- Init cell
-(void)initCellWithData:(NSDictionary*)data{
   
    if (!data) {
        return;
    }
    
    self.isAlertMessageActive = NO;
    self.dictData=data;
    
   
    self.inputValue=[data objectForKey:USER_DETAIL_ROW_TYPE_VALUE];
    self.inputType=[[data objectForKey:USER_DETAIL_ROW_TYPE_KEY] intValue];

    if([data objectForKey:USER_DETAIL_DATA_MODEL_FIELD]){
        self.comboType=[[data objectForKey:USER_DETAIL_DATA_MODEL_FIELD] intValue];
    }else{
        self.comboType=kComboUnknown;
    }
    self.recordTitle.text=[data objectForKey:USER_DETAIL_ROW_TITLE];
    
    switch (self.inputType) {
        case KUDfieldTextfieldWithAction:
            self.canPeformAction=YES;
            break;
            
        default:
            self.canPeformAction=NO;
            break;
    }
    
    if (self.isEditing) {
        [self startEditMode];
    }else{
        [self stopEditMode];
    }
}

- (void)initWithData:(id)data andDelegate:(id)delegate andProfileUserType:(ProfileUserType)profileType{
    [self initCellWithData:data];

    self.profileDetailsDelegate=delegate;
}

-(UIColor*)getmyBackgroundColor{
    if (self.backgroundColor) {
        return self.backgroundColor;
    }
    
    return [UIColor clearColor];
}

#pragma mark - base methods for start/stop editing


-(void)configEditMode:(BOOL)status{
    
    self.isEditing=status;
}

-(void)startEditMode{
}

-(void)stopEditMode{

}

#pragma mark- perform cell actions
-(void)performAction{
}


-(NSString*)getPlaceHolderMessageForField{

    NSString * placeHolderMessage=@"";
    switch (self.comboType){

        case kComboUnknown:break;
        case kFieldFirstName:break;
        case kFieldLastName:break;
        case kFieldLocation:
            placeHolderMessage= NSLocalizedString(@"user_profile_cell_location_lbl_empty", @"");
            break;
        case kFieldWebsite:
            placeHolderMessage=NSLocalizedString(@"user_profile_cell_website_lbl_empty", @"");
            break;
        case kFieldInterests:
            placeHolderMessage=NSLocalizedString(@"user_profile_cell_interests_lbl_empty", @"");
            
            break;
        case kFieldGender:break;
        case kFieldFullName:break;
        case kFieldDescription:
            
            placeHolderMessage=NSLocalizedString(@"user_profile_cell_description_lbl_empty", @"");
            
            break;
        case kFieldUserTypes:
            placeHolderMessage= NSLocalizedString(@"user_profile_cell_user_types_lbl_empty", @"");
            break;
        case kFieldProfessions:
            placeHolderMessage= NSLocalizedString(@"user_profile_cell_user_types_lbl_empty", @"");
            break;
        case kFieldDesignTools:
            placeHolderMessage= NSLocalizedString(@"user_profile_cell_tools_lbl_empty", @"");
            break;
        case kFieldFavoriteStyles:
            placeHolderMessage= NSLocalizedString(@"user_profile_cell_styles_lbl_empty", @"");
            break;
        case KFieldControls:break;
        case kFieldProfileImage:break;
    }

    return placeHolderMessage;
}

#pragma  mark - Field input validations

-(NSString*)cutTextToReachLimitForField:(NSString*)text andType:(UserViewField)type{

    NSString * cutMessage=text;
    int cutLimitNumber=-1;

    switch (type){

        case kComboUnknown:break;
        case kFieldFirstName:
            cutLimitNumber= NAME_CHAR_LIMIT;
            break;
        case kFieldLastName:
            cutLimitNumber= NAME_CHAR_LIMIT;
            break;
        case kFieldLocation:break;
        case kFieldWebsite:
            cutLimitNumber= WEB_SITE_LINK_LIMIT;
            break;
        case kFieldInterests:break;
        case kFieldGender:break;
        case kFieldFullName:break;
        case kFieldDescription:
            cutLimitNumber= DESCRIPTION_LIMIT;
            break;
        case kFieldUserTypes:break;
        case kFieldProfessions:break;
        case kFieldDesignTools:break;
        case kFieldFavoriteStyles:break;
        case KFieldControls:break;
        case kFieldProfileImage:break;
        default:
            break;
    }

    if(cutLimitNumber!=-1){

        if ([text length]>cutLimitNumber)
        {
            cutMessage=[text substringToIndex:cutLimitNumber];
        }


    }

    return cutMessage;
}

-(BOOL)validateInputLimitForField:(NSString *)field andType:(UserViewField)type{

    BOOL status = YES;
    switch (type){

        case kComboUnknown:break;
        case kFieldFirstName:
            status = [self nameFieldValidation:field];
            break;
        case kFieldLastName:
            status = [self nameFieldValidation:field];
            break;
        case kFieldLocation:
            status = [self locationLimitValidation:field];
            break;
        case kFieldWebsite:
            status = [self websiteLimitValidation:field];
            break;
        case kFieldInterests:break;
        case kFieldGender:break;
        case kFieldFullName:
            status = [self nameFieldValidation:field];
            break;
        case kFieldDescription:
            status = [self descriptionFieldValidation:field];
            break;
        case kFieldUserTypes:break;
        case kFieldProfessions:break;
        case kFieldDesignTools:break;
        case kFieldFavoriteStyles:break;
        case KFieldControls:break;
        case kFieldProfileImage:break;
        default:
            status = YES;
            break;
    }
    
    if (!status && !self.isAlertMessageActive) {
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:NSLocalizedString(@"input_limit_reached",@"")
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn",@"")
                          otherButtonTitles: nil] show];
        
        self.isAlertMessageActive = YES;
    }
    
    return status;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        self.isAlertMessageActive = NO;
    }
}

- (BOOL)nameFieldValidation:(NSString*)field {
    if ([field length]>= NAME_CHAR_LIMIT)
           return NO;
    return YES;
}
- (BOOL)descriptionFieldValidation:(NSString*)field {
    if ([field length]>= DESCRIPTION_LIMIT)
        return NO;
    return YES;
}

-(BOOL)websiteLimitValidation:(NSString*)field{

    if ([field length]>= WEB_SITE_LINK_LIMIT)
        return NO;

    return YES;
}

-(BOOL)locationLimitValidation:(NSString*)field{
    
    if ([field length]>= LOCATION_LINK_LIMIT)
        return NO;
    
    return YES;
}
@end
