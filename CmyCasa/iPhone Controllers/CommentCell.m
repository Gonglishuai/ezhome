 //
//  CommentCell.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/23/13.
//
//

#import "CommentCell.h"

#import "NSString+Time.h"

#import "UIImageView+ViewMasking.h"
#import "UILabel+Size.h"
#import "UIView+Alignment.h"
#import "UIView+ReloadUI.h"

#import "NUISettings.h"

#import <QuartzCore/QuartzCore.h>

@interface CommentCell ()

@property (weak, nonatomic) IBOutlet UIView *mainContainer;

@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *readOnlycommentBody;
@property (weak, nonatomic) IBOutlet UILabel *dateLbl;

@end

@implementation CommentCell


-(void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)initWithComment:(CommentDO*)comment{
    
    [self.userAvatar setMaskToCircleWithBorderWidth:1.0f andColor:[UIColor colorWithRed:232.0/255 green:232.0/255 blue:232.0/255 alpha:1.0]];

    self.mycomment = comment;

    if (comment.parentDisplayName != nil) {
        [self.userName setValue:@"nui_ignore" forKey:@"nuiClass"];
        NSString *nuiClass = @"Text_Body1";
        UIFont *font = [NUISettings getFontWithClass:nuiClass];
//        UIColor *color = [NUISettings getColor:@"font-color" withClass:nuiClass];
        UIColor *color = [UIColor clearColor];

        NSMutableAttributedString *text = [[NSMutableAttributedString alloc]
                                           initWithString:comment.displayName
                                           attributes:@{NSFontAttributeName:font,
                                                        NSForegroundColorAttributeName:color}];

        nuiClass = @"Text_Body1_Yellow";
        UIFont *font2  = [NUISettings getFontWithClass:nuiClass];
//        UIColor *color2 = [NUISettings getColor:@"font-color" withClass:nuiClass];
        UIColor *color2 = [UIColor clearColor];

        [text appendAttributedString:[[NSAttributedString alloc]
                                      initWithString:@" @ "
                                      attributes:@{NSFontAttributeName:font2,
                                                   NSForegroundColorAttributeName:color2}]];

        [text appendAttributedString:[[NSAttributedString alloc]
                                      initWithString:comment.parentDisplayName
                                      attributes:@{NSFontAttributeName: font,
                                                   NSForegroundColorAttributeName:color}]];

        self.userName.text = nil;
        self.userName.attributedText = text;
    } else {
        [self.userName setValue:@"Text_Body1" forKey:@"nuiClass"];
        self.userName.attributedText = nil;
        self.userName.text = comment.displayName;
    }

    self.readOnlycommentBody.text = comment.body;
    
    self.dateLbl.text =  [comment.strTimestamp smartTime];

    [self reloadUI];
}

- (IBAction)commentProfileClicked:(id)sender {
    
    if(self.mycomment.uid)
        [[UIMenuManager sharedInstance] openProfilePageForsomeUser:self.mycomment.uid];
}

- (IBAction)writeReplyComment:(id)sender{
    
    if (self.delegate) {
        if (self.mycomment.tempComment) {
             [self.delegate moveTableViewForLastIndexPath:self.mycomment];
        }else{
            [self.delegate createTempCommentForComment:self.mycomment];
        }
    }
}

- (IBAction)writeNewComment:(id)sender {
    
    if ((self.delegate) && ([self.delegate respondsToSelector:@selector(createNewComment)]))
    {
        [self.delegate createNewComment];
    }
}

- (IBAction)saveComment:(id)sender {
    if ([[UserManager sharedInstance] isLoggedIn]) {

        if ([self.commentBodytf.text length]==0) {
            return;
        }
        
        self.mycomment.body=self.commentBodytf.text;
    }
    
    [self.commentBodytf resignFirstResponder];
    if (self.delegate) {
        
        [self.delegate publishComment:self.mycomment];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if (!(([text isEqualToString:@""]))) {//not a backspace, else `characterAtIndex` will crash.
        unichar unicodevalue = [text characterAtIndex:0];
        if (unicodevalue == 55357) {
            return NO;
        }
    }
    
    if ([text isEqualToString:@"\n"]) {
        if (self.mycomment.isTempComment) {
            [self.mycomment setBody:self.commentBody.text];
        }
        
        [textView resignFirstResponder];
        
        if (self.delegate) {
            [self.delegate moveTableViewForInitialFrame];
        }
        return NO;
    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    if (self.delegate) {
        
        if (self.mycomment.isTempComment) {
            if ([self.delegate respondsToSelector:@selector(moveTableViewForWritingCommentFrame)])
            {
                [self.delegate moveTableViewForWritingCommentFrame];
            }
        }
        if ([self.delegate respondsToSelector:@selector(moveTableViewForVisibleInput:)])
        {
            [self.delegate moveTableViewForVisibleInput:self];
        }
    }
    return YES;
}

-(void)prepareForReuse {
    [super prepareForReuse];
    self.seperateBarImage.hidden = NO;
    self.seperateView.hidden = NO;
}



@end
