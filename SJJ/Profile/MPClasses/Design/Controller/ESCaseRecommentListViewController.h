//
//  ESCaseRecommentListViewController.h
//  Consumer
//
//  Created by jiang on 2017/8/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "MPBaseViewController.h"

@interface ESCaseRecommentListViewController : MPBaseViewController
- (void)setCaseId:(NSString *)caseId categoryId:(NSString *)categoryId;
@property (assign, nonatomic) NSInteger tag;
@end
