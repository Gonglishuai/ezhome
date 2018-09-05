
/// 样板间列表
#import "ESBaseModel.h"

/**
 SampleRoomDto {
 caseId (integer, optional): 案例ID ,
 caseType (integer, optional): 1,2D 2,3D ,
 caseVersion (integer, optional): 1,旧版案例库 2,新版案例库 ,
 caseDescription (string, optional): 描述，拼接字符串 ,
 caseName (string, optional): 案例名称 ,
 defaultImg (string, optional): 案例图片 ,
 pvNum (integer, optional): PV数量 ,
 designerName (string, optional): 设计师名称 ,
 designerAvatar (string, optional): 设计师头像 ,
 feature (Array[string], optional): 特色标签组合，最多显示三个
 }
 */

typedef NS_ENUM(NSInteger, CaseType)
{
    CaseTypeUnKnow = 0,
    CaseType2D,     //2D
    CaseType3D      //3D
};

typedef NS_ENUM(NSInteger, CaseVersion) {
    CaseVersionUnknow = 0,
    CaseVersionOld,     // 旧
    CaseVersionNew      // 新
};

@interface ESFittingSampleRoomModel : ESBaseModel

@property (nonatomic, copy) NSString *caseId;
@property (nonatomic, copy) NSString *caseType;
@property (nonatomic, copy) NSString *caseVersion;
@property (nonatomic, copy) NSString *caseDescription;
@property (nonatomic, copy) NSString *caseName;
@property (nonatomic, copy) NSString *defaultImg;
@property (nonatomic, copy) NSString *pvNum;
@property (nonatomic, copy) NSString *designerName;
@property (nonatomic, copy) NSString *designerAvatar;
@property (nonatomic, copy) NSString *brandId;

// 我的新增
@property (nonatomic, assign) CGFloat rightLabelWidth;
@property (nonatomic, copy) NSString *rightLabelText;
@property (nonatomic, assign) CGFloat midLabelWidth;
@property (nonatomic, copy) NSString *midLabelText;
@property (nonatomic, assign) CGFloat leftLabelWidth;
@property (nonatomic, copy) NSString *leftLabelText;
@property (nonatomic, assign) CaseType caseEnumType;
@property (nonatomic, assign) CaseVersion caseEnumVersion;

@end
