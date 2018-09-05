//
//  TblRecordTextFieldCell.m
//  Homestyler
//
//  Created by Berenson Sergei on 12/18/13.
//
//

#import "TblRecordReadOnlyTextFieldCell.h"
#import "ProfileUserDetailsViewController_iPad.h"
#import "UserComboDO.h"
#import "UILabel+Size.h"
@implementation TblRecordReadOnlyTextFieldCell


- (id)init
{
    if (IS_IPAD) {
        self = [[NSBundle mainBundle] loadNibNamed:@"RecordReadOnlyTextFieldCell_iPad" owner:self options:nil][0];
        [self.actionButton setTitle:NSLocalizedString(@"edit_button", @"Edit") forState:UIControlStateNormal];
        
    }else{
        self = [[NSBundle mainBundle] loadNibNamed:@"RecordReadOnlyTextFieldCell_iPhone" owner:self options:nil][0];
    }
    [self setBackgroundColor:[UIColor clearColor]];
     self.selectionStyle=UITableViewCellSelectionStyleNone;
    [self.tblRecordText setTextColor:[UIColor colorWithRed:173.f/255.f green:173.f/255.f blue:173.f/255.f alpha:1.f]];
//    [self.tblRecordText setTextColor:(IS_IPAD)?RECORD_TITLE_COLOR:RECORD_TITLE_COLOR_IPHONE];
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
   
    



    id values=[data objectForKey:USER_DETAIL_ROW_TYPE_VALUE];

    if(values){
    if ([values isKindOfClass:[NSString class]]) {
        self.tblRecordText.text=(NSString*)values;
    }
    
    if ( [values isKindOfClass:[NSArray class]]) {
        NSArray *arrValues=(NSArray*)values;
        
        NSMutableString * combined=[[NSMutableString alloc] init];
        for (int i=0;i<[arrValues count];i++) {
            if (i==0) {
                if([[arrValues objectAtIndex:i] isKindOfClass:[UserComboDO class]])
                {
                    UserComboDO * combo=[arrValues objectAtIndex:i];
                    [combined appendString:combo.comboName];
                }
                    if ([[arrValues objectAtIndex:i] isKindOfClass:[NSString class]])
                    {
                        [combined appendString:[arrValues objectAtIndex:i]];
                    }
            }else{
                if([[arrValues objectAtIndex:i] isKindOfClass:[UserComboDO class]])
                {
                    UserComboDO * combo=[arrValues objectAtIndex:i];
                    [combined appendString:[NSString stringWithFormat:@", %@",combo.comboName]];
                }
                if ([[arrValues objectAtIndex:i] isKindOfClass:[NSString class]])
                {
                    [combined appendString:[NSString stringWithFormat:@", %@",[arrValues objectAtIndex:i]]];
                }


            }
          }
        self.tblRecordText.text=combined;
    }
        if ([values isKindOfClass:[UserComboDO class]]) {
            UserComboDO *combo=(UserComboDO*)values;
            self.tblRecordText.text=combo.comboName;
        }
    }
   
    if( self.tblRecordText.text.length==0)
    {
        self.tblRecordText.text=[self getPlaceHolderMessageForField];
    }
    
    if (IS_IPAD) {
          [self updateContentPositioning];
    }else{
        [self iphoneUpdateContentPositioning];
    }
  
}
-(void)iphoneUpdateContentPositioning{
    CGSize size=[self.tblRecordText getActualTextHeightForLabel:54];
  //  CGSize sizeHeight=[self.tblRecordText getActualTextWidthForLabel:54];
    
    int Margin=5;
    CGFloat endPoint=self.recordTitle.frame.origin.y+self.recordTitle.frame.size.height+Margin+size.height;
    if (endPoint>self.frame.size.height) {
        size.height=size.height-(endPoint-self.frame.size.height)-Margin;
    }
    CGRect rect=CGRectMake(self.tblRecordText.frame.origin.x,
                       self.recordTitle.frame.origin.y+self.recordTitle.frame.size.height+Margin,
                       self.tblRecordText.frame.size.width,
                       //size.width,
                       size.height);
    
    self.tblRecordText.frame=rect;
   // self.tblRecordText.backgroundColor=[UIColor redColor];
    
    
}
- (void)updateContentPositioning {
    //TODO: reposition the action button such that it will be aligned to bottom
    //1. get size of
    CGSize size=[self.tblRecordText getActualTextWidthForLabel:364];
    
    self.tblRecordText.frame=CGRectMake(self.tblRecordText.frame.origin.x,
                                        self.tblRecordText.frame.origin.y,
                                        size.width+20,
                                        self.tblRecordText.frame.size.height);
    
    CGRect rect=self.actionButton.frame;
    rect.origin.y=self.tblRecordText.frame.origin.y;
    rect.size.height=self.tblRecordText.frame.size.height;
    
    
    CGFloat position=self.tblRecordText.frame.origin.x+size.width+20;
    
    if (size.width==0) {
        position=self.tblRecordText.frame.origin.x;
    }
    rect.origin.x=position;
    self.actionButton.frame=rect;

}


-(void)startEditMode{
    [super startEditMode];
    
   // [self.tblRecordText setEnabled:YES];
    
    //[self.tblRecordText setBorderStyle:UITextBorderStyleRoundedRect];
}

-(void)stopEditMode{
    [super stopEditMode];
    //[self.tblRecordText setEnabled:NO];
   // [self.tblRecordText setBorderStyle:UITextBorderStyleNone];
    
    
}


-(void)performAction{
    [super performAction];
   //KUDfieldTextfieldWithAction

        if (self.canPeformAction) {
            if (self.profileDetailsDelegate && [self.profileDetailsDelegate respondsToSelector:@selector(openOptionsForField:withCurrentValue:openView:)]) {

                if (self.comboType!=kComboUnknown){
                     id values=[self.dictData objectForKey:USER_DETAIL_ROW_TYPE_VALUE];
                    NSArray * selectedValues;
                    if (values && [values isKindOfClass:[NSArray class]]) {
                        selectedValues=(NSArray*)values;
                    }
                    
                    if (values && [values isKindOfClass:[UserComboDO class]]) {
                        selectedValues=[NSArray arrayWithObject:values];
                    }
                    
                    [self.profileDetailsDelegate openOptionsForField:self.comboType withCurrentValue:selectedValues openView:self];
                }
            }
            
        }
    
}

- (IBAction)actionClick:(id)sender {
    if ([self canPeformAction]) {
        [self performAction];
    }
}


@end
