//
//  TblRecord2TextsFieldsCell.m
//  Homestyler
//
//  Created by Berenson Sergei on 12/19/13.
//
//

#import "TblRecord2TextsFieldsCell.h"
#import "ProfileUserDetailsViewController_iPad.h"
#import "UserDO.h"
@implementation TblRecord2TextsFieldsCell

- (id)init
{
    if (IS_IPAD) {
        self = [[NSBundle mainBundle] loadNibNamed:@"Record2TextfieldsCell_iPad" owner:self options:nil][0];
    }else{
        self = [[NSBundle mainBundle] loadNibNamed:@"Record2TextfieldsCell_iPhone" owner:self options:nil][0];
    }


    [self.txtFieldOne setPlaceholder:NSLocalizedString(@"First_Name_text_placeholder", @"First Name")];
    [self.txtFieldTwo setPlaceholder:NSLocalizedString(@"Last_Name_text_placeholder", @"Last Name")];
    self.selectionStyle=UITableViewCellSelectionStyleNone;
    [self.txtFieldOne setTextColor:(IS_IPAD)?RECORD_TITLE_COLOR:RECORD_TITLE_COLOR_IPHONE];
    [self.txtFieldTwo setTextColor:(IS_IPAD)?RECORD_TITLE_COLOR:RECORD_TITLE_COLOR_IPHONE];
    [self setBackgroundColor:[UIColor clearColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    
    return self;
}

-(void)initCellWithData:(NSDictionary*)data{
    [super initCellWithData:data];
    //clear previos editing state
    if (self.isEditing) {
        [self startEditMode];
    }else{
        [self stopEditMode];
    }
    
    id values=[data objectForKey:USER_DETAIL_ROW_TYPE_VALUE];
    
    if (values && [values isKindOfClass:[NSArray class]]) {
        NSArray *arrValues=(NSArray*)values;
        for (int i=0;i<[arrValues count];i++) {
            if (i==0) {
                self.txtFieldOne.text=[arrValues objectAtIndex:i];
            }
            if (i==1) {
                self.txtFieldTwo.text=[arrValues objectAtIndex:i];
                
            }
        }
       
    }
    //For not email users fullname, description and photo can't be changed
    if ([data objectForKey:USER_TYPE_VALUE] && [[data objectForKey:USER_TYPE_VALUE] intValue]!=kUserTypeEmail
        && [[data objectForKey:USER_TYPE_VALUE] intValue]!=kUserTypePhone
        && self.comboType==kFieldFullName) {
           [self.txtFieldOne setEnabled:NO];
            [self.self.txtFieldTwo setEnabled:NO];
        
    }else
    {
        [self.txtFieldOne setEnabled:YES];
        [self.self.txtFieldTwo setEnabled:YES];
    }
}

#pragma mark- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];

    return YES;
}

- (void)delegateDataUpdate:(UITextField *)textField andText:(NSString*)text{
    UserViewField fieldType=kComboUnknown;

    if([self.dictData objectForKey:USER_DETAIL_DATA_MODEL_FIELD]){
        fieldType=(UserViewField)
        [[self.dictData objectForKey:USER_DETAIL_DATA_MODEL_FIELD] intValue];
    }
    
    if ([textField isEqual:self.txtFieldOne]) {
        if (fieldType==kFieldFullName) {
            fieldType=kFieldFirstName;
        }
    }
    
    if ([textField isEqual:self.txtFieldTwo]) {
        if (fieldType==kFieldFullName) {
            fieldType=kFieldLastName;
        }
    }
    
    if (self.profileDetailsDelegate && [self.profileDetailsDelegate respondsToSelector:@selector(valueChangedTo:forField:)]) {
        [self.profileDetailsDelegate valueChangedTo:text forField:fieldType];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    if([self.profileDetailsDelegate respondsToSelector:@selector(restoreViewForFieldInput)]){
        [self.profileDetailsDelegate restoreViewForFieldInput];
    }
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

- (void)textFieldDidChanged:(NSNotification *)notification
{
    UITextField *textField = (UITextField *)notification.object;
    
    UITextField * texld = [UITextField new];
    texld.text = [NSMutableString stringWithString:textField.text];

    BOOL inputValid=[self validateInputLimitForField:texld.text andType:self.comboType];
    if (inputValid==NO){
        textField.text= [self cutTextToReachLimitForField:texld.text andType:self.comboType];
    }
    
    if (inputValid) {
        [self delegateDataUpdate:textField andText:texld.text];
    }

}

@end
