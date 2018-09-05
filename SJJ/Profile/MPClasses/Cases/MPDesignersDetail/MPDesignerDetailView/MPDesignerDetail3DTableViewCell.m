//
//  MPDesignerDetail3DTableViewCell.m
//  Consumer
//
//  Created by 董鑫 on 16/8/23.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "MPDesignerDetail3DTableViewCell.h"
#import "MP3DCaseModel.h"
#import "UIImageView+WebCache.h"
#import "MPCaseModel.h"
#import "ESDesignCaseList.h"

@interface  MPDesignerDetail3DTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *caseImageView;
@property (weak, nonatomic) IBOutlet UILabel *caseTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *numLikes;
@property (strong, nonatomic) ESDesignCaseList *myModel3D;

@end
@implementation MPDesignerDetail3DTableViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
//    self.caseTitleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
}

- (void)update3DCellForIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(get3DDesignerDetailModelAtIndex:)]) {
//        MP3DCaseModel *model3D = [self.delegate get3DDesignerDetailModelAtIndex:index];
        ESDesignCaseList *model3D = [self.delegate get3DDesignerDetailModelAtIndex:index];
        self.caseTitleLabel.text = [NSString stringWithFormat:@"%@  %@  %@",
                                    ([model3D.style isEqualToString:@""])?@"其他":model3D.style,
                                    ([model3D.roomType isEqualToString:@""])?@"其他":model3D.roomType,
                                    (model3D.area == nil)?@"0":model3D.area];
        
        self.numLikes.text = [NSString stringWithFormat:@"%@",model3D.favoriteCount];
        
         [_caseImageView sd_setImageWithURL:[NSURL URLWithString:model3D.designCover] placeholderImage:[UIImage imageNamed:HOUSE_DEFAULT_IMAGE]];        
    }
}


- (void)setModel:(ESDesignCaseList *)model3D {
    _myModel3D = model3D;
    self.caseTitleLabel.text = [NSString stringWithFormat:@"%@  %@  %@㎡",
                                ([model3D.style isEqualToString:@""])?@"其他":model3D.style,
                                ([model3D.roomType isEqualToString:@""])?@"其他":model3D.roomType,
                                (model3D.area == nil)?@"0":model3D.area];
    
    self.numLikes.text = [NSString stringWithFormat:@"%@",model3D.favoriteCount];
    [_caseImageView sd_setImageWithURL:[NSURL URLWithString:model3D.designCover] placeholderImage:[UIImage imageNamed:HOUSE_DEFAULT_IMAGE]];

//    if(model3D.images3D){
////        [MPCaseTool show3DCaseImage:_caseImageView caseArray:model3D.images3D];
//    }
}
@end
