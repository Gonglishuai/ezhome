//
//  TblRecordLabelCell.m
//  Homestyler
//
//  Created by Berenson Sergei on 12/31/13.
//
//

#import "TblRecordLabelCell.h"
#import "UILabel+Size.h"
#import "ProfileUserDetailsBaseViewController.h"

@interface TblRecordLabelCell()

@end
@implementation TblRecordLabelCell

- (id)init
{
    if (IS_IPAD) {
        self = [[NSBundle mainBundle] loadNibNamed:@"RecordLabelCell_iPad" owner:self options:nil][0];
    }else{
        self = [[NSBundle mainBundle] loadNibNamed:@"RecordLabelCell_iPhone" owner:self options:nil][0];
    }
    [self setBackgroundColor:[UIColor greenColor]];
     self.selectionStyle=UITableViewCellSelectionStyleNone;  
 
    return self;
}

-(void)initCellWithData:(NSDictionary*)data{
    [super initCellWithData:data];
    //clear previos editing state
    
    //Only on iPhone, if this is the "I Am" cell, display the top seperator
    //It's hidden by default
    if (IS_IPHONE) {
        id fieldType = [data objectForKey:USER_DETAIL_DATA_MODEL_FIELD];
        if (fieldType && [fieldType integerValue] == kFieldUserTypes) {
            self.topSeperator.hidden = NO;
        }
    }
    
    id values=[data objectForKey:USER_DETAIL_ROW_TYPE_VALUE];


    if (values && [values isKindOfClass:[NSString class]]) {
        self.tblRecordText.text=(NSString*)values;
    }
    if (values && [values isKindOfClass:[NSMutableAttributedString class]]) {
        self.tblRecordText.attributedText=(NSMutableAttributedString*)values;
    }


    BOOL titleUsed=NO;
    int firstIndex=0;
        if (values && [values isKindOfClass:[NSArray class]]) {
            NSArray *arrValues=(NSArray*)values;

            NSMutableString * combined=[[NSMutableString alloc] init];
            for (int i=0;i<[arrValues count];i++) {
                
                if ([self.recordTitle.text length]==0 && i==0) {
                    titleUsed=YES;
                    firstIndex=1;
                    self.recordTitle.text=[arrValues objectAtIndex:i];
                }else{
                    if (i==firstIndex) {
                        [combined appendString:[arrValues objectAtIndex:i]];
                    }else{
                          [combined appendString:[NSString stringWithFormat:@", %@",[arrValues objectAtIndex:i]]];
                    }
                
                }
                
            }
            
            self.tblRecordText.text=combined;
        }
        
    if (self.isEditing) {
        [self startEditMode];
    }else{
        [self stopEditMode];
        if (IS_IPAD) {
           [self formatForReadOnly]; 
        }else
        {
            
        }
    }
}

-(void)initWithData:(id)data andDelegate:(id)delegate andProfileUserType:(ProfileUserType)profileType{

    [self initCellWithData:data];
    self.profileDetailsDelegate=delegate;
}

-(void)startEditMode{
    [super startEditMode];
}

-(void)formatForReadOnly{
  
    //reposition Label as part of total row display, when label empty it will shrink
    CGSize originalSize = self.recordTitle.frame.size;
    
    [self.recordTitle sizeToFit];
    if (self.recordTitle.frame.size.width > 300)
    {
        self.recordTitle.frame = CGRectMake(self.recordTitle.frame.origin.x, self.recordTitle.frame.origin.y, 300, originalSize.height);
    }
    else
    {
        self.recordTitle.frame = CGRectMake(self.recordTitle.frame.origin.x, self.recordTitle.frame.origin.y, self.recordTitle.frame.size.width, originalSize.height);
    }
    
    CGRect frame=self.recordTitle.frame;
    
    //reposition tbl record text
    CGRect frame2=self.tblRecordText.frame;
    
    float newX = (frame.size.width>0)?frame.origin.x+frame.size.width+5:frame.origin.x;

    frame2.origin.x = newX;
    if (IS_IPAD) {
        if (frame.size.width == 0) {
            frame2.size.width=620;
        }
    }

    self.tblRecordText.frame=frame2;

}

-(void)stopEditMode{
    [super stopEditMode];
}

@end




