//
//  TblRecordLocationCell.m
//  Homestyler
//
//  Created by Berenson Sergei on 1/6/14.
//
//

#import "TblRecordLocationCell.h"
#import "ProfileUserDetailsViewController_iPad.h"

#define kSpaceBetweenButtons 25

@implementation TblRecordLocationCell

- (id)init
{
    if (IS_IPAD) {
        self = [[NSBundle mainBundle] loadNibNamed:@"RecordLocationCell_iPad" owner:self options:nil][0];
    }else{
        self = [[NSBundle mainBundle] loadNibNamed:@"RecordLocationCell_iPhone" owner:self options:nil][0];
    }
    
    self.selectionStyle=UITableViewCellSelectionStyleNone;
    
    [self.removeLocationButton setTitle:NSLocalizedString(@"get_location_hide_title", @"") forState:UIControlStateNormal];
    [self.getUpdateLocationButton setTitle:NSLocalizedString(@"get_location_title", @"") forState:UIControlStateNormal];
    [self.tblLocationField setTextColor:(IS_IPAD)?RECORD_TITLE_COLOR:RECORD_TITLE_COLOR_IPHONE];
    [self setBackgroundColor:[UIColor clearColor]];

    return self;
}

-(void)initCellWithData:(NSDictionary *)data{
    [super initCellWithData:data];
    [self.activityIndicator stopAnimating];
     self.removeLocationButton.enabled=YES;
     self.getUpdateLocationButton.enabled=YES;
    id values=[data objectForKey:USER_DETAIL_ROW_TYPE_VALUE];

    if (values) {
        if ([values isKindOfClass:[NSString class]] ) {
            self.tblLocationField.text=(NSString*)values;
        }
        if ([self.tblLocationField.text length]>0) {
               [self uiStateLocationExists];
        }else{
                [self uiStateNoLocation];
        }
     
        
    }else{
        [self uiStateNoLocation];
    }

    self.tblLocationField.placeholder=[self getPlaceHolderMessageForField];
}

-(void)uiStateNoLocation{
    self.tblLocationField.hidden = YES;
    self.removeLocationButton.hidden=YES;
    [self.getUpdateLocationButton setTitle:NSLocalizedString(@"get_location_title", @"") forState:UIControlStateNormal];
}

-(void)uiStateLocationExists{
    self.tblLocationField.hidden = NO;
    self.removeLocationButton.hidden=NO;
    [self.getUpdateLocationButton setTitle:NSLocalizedString(@"update_location_title", @"") forState:UIControlStateNormal];
}

-(void)initWithData:(id)data andDelegate:(id)delegate andProfileUserType:(ProfileUserType)profileType{
    [self initCellWithData:data];
    self.profileDetailsDelegate=delegate;
    
}
 
- (IBAction)removeLocationAction:(id)sender {
    self.tblLocationField.text=@"";
    [self uiStateNoLocation];
    
    if (self.profileDetailsDelegate && [self.profileDetailsDelegate respondsToSelector:@selector(valueChangedTo:forField:)]) {
        
        UserViewField fieldType=kComboUnknown;
        if([self.dictData objectForKey:USER_DETAIL_DATA_MODEL_FIELD]){
            fieldType=(UserViewField)
            [[self.dictData objectForKey:USER_DETAIL_DATA_MODEL_FIELD] intValue];
        }
        [self.profileDetailsDelegate valueChangedTo:@"" forField:fieldType];
        
    }

}


- (IBAction)getUpdateLocationAction:(id)sender {
    if (self.profileDetailsDelegate && [self.profileDetailsDelegate respondsToSelector:@selector(updateOrGetCurrentLocation)]) {
        //Continue only if the location can be updated
        if ([self.profileDetailsDelegate updateOrGetCurrentLocation]) {
            [self.activityIndicator startAnimating];
            // self.tblLocationField.enabled=NO;
            self.getUpdateLocationButton.enabled=NO;
            self.removeLocationButton.enabled=NO;
        }
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
//    if (self.profileDetailsDelegate && [self.profileDetailsDelegate respondsToSelector:@selector(valueChangedTo:forField:)]) {
//        
//        UserViewField fieldType=kComboUnknown;
//        if([self.dictData objectForKey:USER_DETAIL_DATA_MODEL_FIELD]){
//            fieldType=(UserViewField)
//            [[self.dictData objectForKey:USER_DETAIL_DATA_MODEL_FIELD] intValue];
//        }
//        [self.profileDetailsDelegate valueChangedTo:textField.text forField:fieldType];
//        
        if([self.profileDetailsDelegate respondsToSelector:@selector(restoreViewForFieldInput)]){
            [self.profileDetailsDelegate restoreViewForFieldInput];
        }
//    }
    
    
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (self.profileDetailsDelegate && [self.profileDetailsDelegate respondsToSelector:@selector(adjustViewForFieldInput:)]) {
        if (IS_IPAD) {
            [self.profileDetailsDelegate adjustViewForFieldInput:self.frame];
        }else{
            [self.profileDetailsDelegate adjustViewForField:self];
        }
    }
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if (self.profileDetailsDelegate && [self.profileDetailsDelegate respondsToSelector:@selector(restoreViewForFieldInput)]) {
        [self.profileDetailsDelegate restoreViewForFieldInput];
    }
    return YES;
}
#pragma mark- UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    
    UITextField * texld=[UITextField  new];
    
    
    texld.text=[NSString  stringWithFormat:@"%@%@",textField.text,string];
    
    if ([string length]==0 && [texld.text length]>0) {
        //backspace
            texld.text=[texld.text substringToIndex:[texld.text length]-1];
        
    }
    
    
    BOOL inputValid=[self validateInputLimitForField:texld.text andType:self.comboType];
    
    
    if ([string length]>1 && inputValid==NO){
        
        textField.text= [self cutTextToReachLimitForField:texld.text andType:self.comboType];
    }
    
    if (inputValid) {
        
        if (self.profileDetailsDelegate && [self.profileDetailsDelegate respondsToSelector:@selector(valueChangedTo:forField:)]) {
        
                UserViewField fieldType=kComboUnknown;
                if([self.dictData objectForKey:USER_DETAIL_DATA_MODEL_FIELD]){
                    fieldType=(UserViewField)
                    [[self.dictData objectForKey:USER_DETAIL_DATA_MODEL_FIELD] intValue];
                }
                [self.profileDetailsDelegate valueChangedTo:texld.text forField:fieldType];
        
        }
    }
    return inputValid;
}
@end


