//
//  ESUniversalLinkManager.m
//  Consumer
//
//  Created by xiefei on 4/5/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESUniversalLinkManager.h"
#import "ESCaseDetailViewController.h"
#import "ESRecommendDetailViewController.h"
#import "ESBrandRecommendDetailViewController.h"


#import "NSString+ESUtils.h"

@implementation ESUniversalLinkManager

+(id)createNativeDetailsController:(NSString *)urlPath {
    if ([urlPath containsString:@"case"]) {
        ESCaseDetailViewController *vc = [[ESCaseDetailViewController alloc] init];
        NSString *str;
        CaseStyleType StyleType;
        CaseSourceType SourceType;
        if ([urlPath containsString:@"2d"]) {
            str = [urlPath substringFromIndex:[urlPath rangeOfString:@"2d"].location + 1];
            StyleType = CaseStyleType2D;
            SourceType = CaseSourceTypeBySearch;
        }else{
            str = [urlPath substringFromIndex:[urlPath rangeOfString:@"3d"].location + 1];
            StyleType = CaseStyleType3D;
            SourceType = CaseSourceTypeBy3D;
        }
        [vc setCaseId:[str getURLNumber] caseStyle:StyleType caseSource:SourceType caseCategory:CaseCategoryNormal];
        return vc;
    }else if ([urlPath containsString:@"brandRecom"]){
        ESBrandRecommendDetailViewController *vc = [[ESBrandRecommendDetailViewController alloc] init];
        [vc setRecommendId:[urlPath getURLNumber]];
        return vc;
    }else if ([urlPath containsString:@"recommendDetail"]){
        ESRecommendDetailViewController *vc = [[ESRecommendDetailViewController alloc] init];
        [vc setRecommendId:[urlPath getURLNumber]];
        return vc;
    }else if ([urlPath containsString:@"profile"]){//外部链接-->设计师详情
        NSString *fileName = @"profile";
        NSString *designerId = [[urlPath substringFromIndex:[urlPath rangeOfString:@"profile"].location + fileName.length + 1] getURLNumber];
//        MPDesignerDetailViewController* vc = [[MPDesignerDetailViewController alloc] initWithIsDesignerCenter:NO member_id:designerId isConsumerNeeds:NO];//@"432980583899021312"
        
        NSDictionary *dict = [NSDictionary dictionaryWithObject:designerId forKey:@"designId"];
        [MGJRouter openURL:@"/Design/DesignerDetail" withUserInfo:dict completion:nil];
        
        return nil;
    }
    return nil;
}

@end
