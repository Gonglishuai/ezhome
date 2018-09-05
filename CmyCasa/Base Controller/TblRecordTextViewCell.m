//
//  TblRecordTextViewCell.m
//  Homestyler
//
//  Created by Berenson Sergei on 12/19/13.
//
//

#import "TblRecordTextViewCell.h"
#import "ProfileUserDetailsViewController_iPad.h"
#import "UserDO.h"
@implementation TblRecordTextViewCell


- (id)init
{
    if (IS_IPAD) {
        self = [[NSBundle mainBundle] loadNibNamed:@"RecordTextViewCell_iPad" owner:self options:nil][0];
    }else{
        self = [[NSBundle mainBundle] loadNibNamed:@"RecordTextViewCell_iPhone" owner:self options:nil][0];
    }
    [self setBackgroundColor:[UIColor clearColor]];
     self.selectionStyle=UITableViewCellSelectionStyleNone;
    [self.tblRecordText setTextColor:(IS_IPAD)?RECORD_TITLE_COLOR:RECORD_TITLE_COLOR_IPHONE];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChanged:) name:UITextViewTextDidChangeNotification object:nil];

    
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
    
    
    if (values && [values isKindOfClass:[NSString class]]) {
        self.tblRecordText.text=(NSString*)values;
    }
    if ([self.tblRecordText.text length]==0) {
        self.tblRecordText.text=[self getPlaceHolderMessageForField];
        [self.tblRecordText setTextColor:RECORD_PLACEHOLDER_TITLE_COLOR];
    }else{
        [self.tblRecordText setTextColor:(IS_IPAD)?RECORD_TITLE_COLOR:RECORD_TITLE_COLOR_IPHONE];
        
    }
}

-(void)startEditMode{
    [super startEditMode];
    [self.tblRecordText setEditable:YES];
}

-(void)stopEditMode{
    [super stopEditMode];
        [self.tblRecordText setEditable:NO];
}

-(void)performAction{
    [super performAction];
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    
    if([self.profileDetailsDelegate respondsToSelector:@selector(restoreViewForFieldInput)]){
        [self.profileDetailsDelegate restoreViewForFieldInput];
    }

    if ([self.tblRecordText.text length]==0) {
        self.tblRecordText.text=[self getPlaceHolderMessageForField];
        [self.tblRecordText setTextColor:RECORD_PLACEHOLDER_TITLE_COLOR];
    }else{
        [self.tblRecordText setTextColor:(IS_IPAD)?RECORD_TITLE_COLOR:RECORD_TITLE_COLOR_IPHONE];
        
    }
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    
    if ([self.tblRecordText.text isEqualToString:[self getPlaceHolderMessageForField]]) {
        self.tblRecordText.text=@"";
        [self.tblRecordText setTextColor:(IS_IPAD)?RECORD_TITLE_COLOR:RECORD_TITLE_COLOR_IPHONE];
        
    }
    if (self.profileDetailsDelegate && [self.profileDetailsDelegate respondsToSelector:@selector(adjustViewForFieldInput:)]) {
        if (IS_IPAD) {
            [self.profileDetailsDelegate adjustViewForFieldInput:self.frame];
        }else{
            [self.profileDetailsDelegate adjustViewForField:self];
        }
    }
}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
   
    return YES;
}

-(void)textViewDidChanged:(NSNotification*)notification
{
    UITextView* textView = (UITextView*)notification.object;
    NSString* text = textView.text;
    
    if(IS_IPHONE && [text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return;
    }

    UITextView * texld=[UITextView  new];
    texld.text=text;

    
    if([text length]==0 && [texld.text length]>0)
    {//removed one char

            texld.text=[texld.text substringToIndex:texld.text.length-1];
    }
       
    BOOL inputValid=[self validateInputLimitForField:texld.text andType:self.comboType];


    if ([text length]>1 && inputValid==NO){

        textView.text= [self cutTextToReachLimitForField:texld.text andType:self.comboType];
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

}


@end
