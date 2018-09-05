//
//  NoCommentCell.m
//  EZHome
//
//  Created by xiefei on 9/10/17.
//

#import "NoCommentCell.h"

@interface NoCommentCell ()
@property (weak, nonatomic) IBOutlet UILabel *tip;
@end

@implementation NoCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.tip.text = NSLocalizedString(@"commentString",@"");
}

- (void)setTipText:(NSString *)text {
    self.tip.text = text;
}

@end


@interface PrivateDesignNoCommentCell ()
@property (weak, nonatomic) IBOutlet UILabel *tip;
@end

@implementation PrivateDesignNoCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.tip.text = NSLocalizedString(@"cannot_comment_private_design", @"Private design can't be commented");
}

@end
