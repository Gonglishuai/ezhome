//
//  TblRecordTextFieldCell.m
//  Homestyler
//
//  Created by Berenson Sergei on 12/18/13.
//
//

#import "TblRecordTextFieldCell.h"
#import "ProfileUserDetailsViewController_iPad.h"
#import "UserDO.h"

#import "UserComboDO.h"

@implementation TblRecordTextFieldCell


- (id)init
{
    if (IS_IPAD) {
        self = [[NSBundle mainBundle] loadNibNamed:@"RecordTextFieldCell_iPad" owner:self options:nil][0];
    }else{
        self = [[NSBundle mainBundle] loadNibNamed:@"RecordTextFieldCell_iPhone" owner:self options:nil][0];
    }
    [self setBackgroundColor:[UIColor clearColor]];
    [self.validateButton setTitle:NSLocalizedString(@"Validate_web_link_button", @"Validate") forState:UIControlStateNormal];
     self.selectionStyle=UITableViewCellSelectionStyleNone;
    [self.tblRecordText setTextColor:(IS_IPAD)?RECORD_TITLE_COLOR:RECORD_TITLE_COLOR_IPHONE];
  
    
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
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

    self.tblRecordText.placeholder=[self getPlaceHolderMessageForField];
    
    id values=[data objectForKey:USER_DETAIL_ROW_TYPE_VALUE];

   
    if (values && [values isKindOfClass:[NSString class]]) {
        self.tblRecordText.text=(NSString*)values;
    }
    
    if (values && [values isKindOfClass:[NSArray class]]) {
        NSArray *arrValues=(NSArray*)values;
        
        NSMutableString * combined=[[NSMutableString alloc] init];
        for (int i=0;i<[arrValues count];i++) {
            if (i==0) {
              
                    if ([[arrValues objectAtIndex:i] isKindOfClass:[NSString class]])
                    {
                        [combined appendString:[arrValues objectAtIndex:i]];
                    }
            }else{
              
                if ([[arrValues objectAtIndex:i] isKindOfClass:[NSString class]])
                {
                    [combined appendString:[NSString stringWithFormat:@", %@",[arrValues objectAtIndex:i]]];
                }
            }
          }
        self.tblRecordText.text=combined;
    }

    if([self.tblRecordText.text length]==0)
    {
        
    }else{
        //show validate button for web link only
        self.validateButton.hidden=self.comboType!=kFieldWebsite;
    }
}

-(void)startEditMode{
    [super startEditMode];
    
    [self.tblRecordText setEnabled:YES];
}

-(void)stopEditMode{
    [super stopEditMode];
    [self.tblRecordText setEnabled:NO];
}

-(void)performAction{
    [super performAction];   
}

- (IBAction)actionClick:(id)sender {
    if ([self canPeformAction]) {
        [self performAction];
    }
}


#pragma mark- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    return YES;
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

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

    if([textField.text length]>0 && self.comboType==kFieldWebsite){
        self.validateButton.hidden=NO;
    }else{
        self.validateButton.hidden=YES;
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

- (IBAction)validateFieldAction:(id)sender {
   
    NSString * error=nil;
    if([self.tblRecordText.text length]>0){
               NSString * _url=self.tblRecordText.text;
        if ([_url rangeOfString:@"http://"].location==NSNotFound) {
            _url=[NSString stringWithFormat:@"http://%@",_url];
        }
        
        NSURL * url=[NSURL URLWithString:_url];
        

        if(url){
            [[UIApplication sharedApplication] openURL:url];
            return;
        }else{
            error= NSLocalizedString(@"Invalide_website_link_format", @"Invalide website link format");
        }

    }else{
        error= NSLocalizedString(@"No_link_provided", @"No link provided");
    }
    if(error)
    [[[UIAlertView alloc] initWithTitle:@"" message:error delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"")
                      otherButtonTitles:nil] show];

}
@end
