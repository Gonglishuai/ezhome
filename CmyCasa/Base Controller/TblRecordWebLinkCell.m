//
//  TblRecordWebLinkCell.m
//  Homestyler
//
//  Created by Berenson Sergei on 1/2/14.
//
//

#import "TblRecordWebLinkCell.h"

@implementation TblRecordWebLinkCell

- (id)init
{
    if (IS_IPAD) {
        self = [[NSBundle mainBundle] loadNibNamed:@"RecordWebLinkCell_iPad" owner:self options:nil][0];
    }else{
        self = [[NSBundle mainBundle] loadNibNamed:@"RecordWebLinkCell_iPhone" owner:self options:nil][0];
    }
    [self setBackgroundColor:[UIColor clearColor]];
    self.selectionStyle=UITableViewCellSelectionStyleNone;
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

-(void)prepareForReuse{
    [super prepareForReuse];
    self.recordTitle.text=@"";
    [self.tblWebLinkButton setAttributedTitle:[NSAttributedString new] forState:UIControlStateNormal];
    [self.tblWebLinkButton setTitle:@"" forState:UIControlStateNormal];
}

-(void)initCellWithData:(NSDictionary*)data{
    [super initCellWithData:data];
    //clear previos editing state
    
    NSString * title=[data objectForKey:USER_DETAIL_ROW_TITLE];
    NSString * spacedTitle=[NSString stringWithFormat:@"%@ ",title];
    
    id values=[data objectForKey:USER_DETAIL_ROW_TYPE_VALUE];
   
    if (values) {
        
        if ([values isKindOfClass:[NSString class]]) {
            
            self.webURL=(NSString*)values;
            
            if (title && [self.webURL  rangeOfString:title].location!=NSNotFound) {
                
                self.webURL = [self.webURL stringByReplacingOccurrencesOfString:spacedTitle withString:@""];
            }
            
            
            [self.tblWebLinkButton setTitle:self.webURL forState:UIControlStateNormal];
            if (title && [[self.tblWebLinkButton titleForState:UIControlStateNormal]
                 isEqualToString:spacedTitle]) {
                self.webURL=nil;
            }
        }
        
        if ([values isKindOfClass:[NSAttributedString class]]) {
            NSAttributedString * attr=(NSAttributedString*)values;
             self.webURL=[attr string];
            
            if (title && [self.webURL  rangeOfString:title].location!=NSNotFound) {
                
                self.webURL = [self.webURL stringByReplacingOccurrencesOfString:spacedTitle withString:@""];
            }
            
             [self.tblWebLinkButton setAttributedTitle:values forState:UIControlStateNormal];
            
            if (title && [[[self.tblWebLinkButton attributedTitleForState:UIControlStateNormal] string]isEqualToString:spacedTitle]) {
                
                self.webURL=nil;
                
            }
        }
    }
    
    //If there is no website, disable the button
    [self.tblWebLinkButton setEnabled:(self.webURL.length > 0)];
    
    if (self.isEditing) {
        [self startEditMode];
    }else{
        [self stopEditMode];
    }
}

-(void)startEditMode{
    [super startEditMode];
}

-(void)stopEditMode{
    [super stopEditMode];
}

- (IBAction)webLinkActivation:(id)sender {
    if (self.webURL.length) {
        NSString * url=self.webURL;
        if ([url rangeOfString:@"http://"].location==NSNotFound) {
            url=[NSString stringWithFormat:@"http://%@",url];
        }
        if (![NSURL URLWithString:url]) {
            return;
        }
        
        GenericWebViewBaseViewController * web =  [[UIManager sharedInstance] createGenericWebBrowser:url];
        [[[UIManager sharedInstance] pushDelegate] presentViewController:web animated:YES completion:nil];
    }
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
        self.webURL=[NSString stringWithString:textField.text];
    }

    return inputValid;
}


@end
