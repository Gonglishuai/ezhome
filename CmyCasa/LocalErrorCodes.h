//
//  LocalErrorCodes.h
//  Homestyler
//
//  Created by Berenson Sergei on 3/11/13.
//
//




typedef enum  HSServerErrorCodes
{
     HSERR_NO_ERROR =                             -1,
     HSERR_UNKNOWN_ERROR =                        0,
     HSERR_CONSUMER_KEY_DOES_NOT_EXIST =          1,
     HSERR_MISSING_REQUIRED_API_PARAMETER =       2,
     HSERR_UNAUTHORIZED_API_ACCESS =              3,
     HSERR_REQUIRED_OAUTH_INFORMATION_MISSING =   4,
     HSERR_ACCESS_TOKEN_MISSING =                 5,
     HSERR_OAUTH_REQUEST_EXPIRED =                6,
     HSERR_API_NAME_IS_INVALID =                  7,
     HSERR_OAUTH_SIGNATURE_INVALID =              8,
     HSERR_USERID_IS_REQUIRED =                   9,
     HSERR_USERID_IS_INVALID =                    10,
     HSERR_LOGIN_TYPE_IS_REQUIRED =               11,
     HSERR_ACCESS_EMAIL_IS_REQUIRED =             12,
     HSERR_ACCESS_PASSWORD_IS_REQUIRED =          13,
     HSERR_ACCESS_SEESION_ID_IS_REQUIRED =        14,
     HSERR_TOKEN_IS_INVALID =                     15,
     HSERR_LOGIN_FAILED =                         16,
     HSERR_REGISTER_FAILED =                      17,
     HSERR_FACEBOOK_USER_AUTHENTICATION_FAILED =  18,
     HSERR_SESSION_IS_FAILED =                    19,
     HSERR_EMAIL_ADDRESS_IS_FAILED =              20,
     HSERR_EDIT_USER_ACCOUNT_FAILED =             21,
     HSERR_REMOVE_USER_ACCOUNT_FAILED =           22,
     HSERR_USER_HAS_BEEN_REGISTERED =             23,
     HSERR_SNAPSHOTID_IS_REQUIRED =               24,
     HSERR_IMAGEGALLERYID_IS_REQUIRED =           25,
     HSERR_IMAGEDESIGN_IS_EMPTY =                 26,
     HSERR_IMAGEDESIGN_HAS_BEEN_PUBLISHED =       27,
     HSERR_GETMETHOD_IS_NOT_ALLOWED =             28,
     HSERR_USER_HAS_BEEN_PUBLISHED =              29,
     HSERR_USER_PUBLISH_FAILED =                  30,
     HSERR_USER_NOT_PUBLISHED =                   31,
     HSERR_DESIGNSETID_IS_REQUIRED =              32,
     HSERR_DESIGNSETID_IS_INVALID =               33,
     HSERR_DESIGNSET_HAS_BEEN_PUBLISHED =         34,
     HSERR_EMAIL_ALREADY_EXISTS =                 35,
     HSERR_EMAIL_ADDDRESS_INVALID =               123,
     HSERR_DESIGN_NOT_FOUND =                     124,
     HSERR_GALLERY_ITEM_NOT_FOUND =               125,
     HSERR_PROFESSIONAL_NOT_FOUND =               126,
     HSERR_PRODUCT_NOT_FOUND =                    127,
     HSERR_LIKE_NOT_FOUND =                       128,
     HSERR_ARTICLE_NOT_FOUND =                    129,
     HSERR_SIMPLE_DESIGN_NOT_FOUND =              130,
     HSERR_CATEGORY_NOT_FOUND =                   131,
     HSERR_PROJECT_NOT_FOUND =                    133,
     HSERR_ASSET_DOESNT_BELONG_TO_USER =          134,
     HSERR_AMAZON_ERR =                           135,
     HSERR_OPERATION_NOT_ALLOWED_ON_THIS_STATUS = 136,
     HSERR_ASSET_ALREADY_PUBLISHED =              137,
     HSERR_GENERIC_ADA_ERROR =                    138,
     HSERR_REQUEST_NOT_ALLOWED_FROM_USER =        139,
     HSERR_OPERATION_NOT_ALLOWED_ON_DELETED_ITEM =140,
     HSERR_WRONG_STATUS =                         141,
     HSERR_CONCURRENCY_ERROR =                    142,
     HSERR_GENERIC_HS_ERROR =                     143,
     HSERR_WRONG_TYPE_REQUESTED =                 144,
     HSERR_ADA_ID_DUPLICATE =                     145,
     HSERR_EMPTY_ADA_ID =                         146,
     HSERR_DUPLICATE_OPEN_ID =                    147,
     HSERR_DUPLICATE_OPEN_ID_TOKEN =              148,
    
   /*Local errors*/
    HSERR_LOCAL_ERROR_PARSE_JSON =                900,
    HSERR_LOCAL_ERROR_TRY_EXCEPTION =             901,
    HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL =          902,
    HSERR_LOCAL_ERROR_ACCEPT_TERMS =              903,
    HSERR_LOCAL_ERROR_GENERIC_ERROR=              904,
    HSERR_LOCAL_ERROR_NO_NETWORK =                905,
    HSERR_LOCAL_ERROR_FAILED_GET_FRIENDS =        906,
    HSERR_LOCAL_ERROR_FAILED_FB_INVITE =          907,
    HSERR_LOCAL_ERROR_FAILED_FB_LOGIN =           908,
     HSERR_LOCAL_ERROR_FAILED_FB_POST =          909,
    HSERR_LOCAL_ERROR_FAILED_FB_LIKE =          910,
    HSERR_LOCAL_ERROR_FAILED_TW_GET_ACCESS =      911,
    HSERR_LOCAL_ERROR_FAILED_TW_POST =      912,
    
    
    
    
    
}HSServerErrorCode;