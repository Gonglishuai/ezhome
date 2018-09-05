//
//  ESCaseDetailViewController.h
//  Consumer
//
//  Created by jiang on 2017/8/15.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "MPBaseViewController.h"

typedef NS_ENUM(NSInteger, CaseStyleType) {
    CaseStyleType2D, //2D
    CaseStyleType3D //3D
};

typedef NS_ENUM(NSInteger, CaseSourceType) {
    CaseSourceTypeBySearch,     //从索引所搜
    CaseSourceTypeBy3D          //从3D搜索
};

typedef NS_ENUM(NSInteger, CaseCategory) {
    CaseCategoryNormal,     /// 普通案例
    CaseCategoryPackage,    /// 套餐样板间(套餐)
    CaseCategoryFitting     /// 家装试衣间(商品)
};

@interface ESCaseDetailViewController : MPBaseViewController

@property (nonatomic, copy) NSString *brandId;

/**
 进入案例详情传参

 @param caseId 案例id
 @param caseStyle 2D还是3D
 */
- (void)setCaseId:(NSString *)caseId
        caseStyle:(CaseStyleType)caseStyle
       caseSource:(CaseSourceType)source
     caseCategory:(CaseCategory)category;

@end
