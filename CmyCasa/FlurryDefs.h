//
//  FlurryDefs.h
//  CmyCasa
//
//  Created by Tomer Galon on 9/13/12.
//
//

#ifndef CmyCasa_FlurryDefs_h
#define CmyCasa_FlurryDefs_h
//#import "Flurry.h"
#import "AppDelegate.h"


#define FLURRY_TIME             (@("Total time spent"))
#define FLURRY_DEVICE_TYPE      (@("DeviceType"))

// Genic
#define EVENT_PARAM_NAME_LOAD_ORIGIN    (@("Click Origin"))
#define EVENT_PARAM_NAME_CLICK_OPTION   (@("Click Option"))

// Settings
#define FLURRY_SETTING_MENU_CLICK           (@("settings menu"))
#define FLURRY_SETTING_DATA_COLLECTION_OFF  (@("data collection off"))
#define FLURRY_SETTING_CLEAR_CACHE          (@("clear cache"))
#define FLURRY_READ_ABOUT_CLICK             (@("read about"))
#define FLURRY_READ_POLICY_CLICK            (@("read policy"))
#define FLURRY_READ_TERMS_CLICK             (@("read terms"))


// User Profile
#define FLURRY_PROFILE_EDIT_IMAGE_CLICK (@("user profile edit image click"))
#define FLURRY_CHANGE_PROFILE_IMAGE         (@("user changed profile image"))
#define FLURRY_SIGNOUT                      (@("user signout"))


// login
#define EVENT_NAME_VIEW_SIGNIN_DIALOG   (@("Sign Up Screen"))

#define EVENT_PARAM_SIGNUP_TRIGGER      (@("signup trigger"))

#define EVENT_PARAM_LOAD_ORIGIN_MENU        (@("Main Menu / Home Screen"))
#define EVENT_PARAM_LOAD_ORIGIN_SAVEDESIGN  (@("Save Design"))
#define EVENT_PARAM_VAL_LOAD_ORIGIN_COMMENT (@("Comment"))
#define EVENT_PARAM_VAL_LOAD_ORIGIN_LIKE    (@("Like"))
#define EVENT_PARAM_VAL_LOAD_ORIGIN_FOLLOW  (@("Follow"))
#define EVENT_PARAM_VAL_LOAD_ORIGIN_FOLLOWING_FEED  (@"Following feed")

#define EVENT_PARAM_VAL_FOLLOW_USER (@("follow user"))


// Home Screen
#define EVENT_NAME_HOME_SCREEN      (@("Home Screen"))

#define FLURRY_NEW_DESIGN_MENU_CLICK    (@("new design menu click"))
#define FLURRY_3DDESIGN_HOME_CLICK      (@("Design Stream home type selection"))
#define FLURRY_NEW_DESIGN_CLICK         (@("new design option click"))

#define EVENT_LABEL_CAMERA          (@("Camera"))
#define EVENT_LABEL_PHOTOS          (@("Photos"))
#define EVENT_LABEL_EMPTY_ROOM      (@("Empty Room"))
#define EVENT_LABEL_AR              (@("AR"))
#define EVENT_LABEL_COMMUNITY       (@("Community"))
#define EVENT_LABEL_CATALOG         (@("Catalog"))
#define EVENT_LABEL_USER_PROFILE    (@("User Profile"))


// Design
#define FLURRY_DESIGN_SHARE_FACEBOOK_SEND   (@("design share facebook send"))
#define FLURRY_DESIGN_SHARE_EMAIL_SEND      (@("design share email send"))
#define FLURRY_DESIGN_SAVED                 (@("design save"))
#define FLURRY_DESIGN_RESAVED               (@("design save override"))

#define FLURRY_CONCEAL_TOOL_FAILED_INIT     (@("failed to open conceal tool"))
#define FLURRY_CONCEAL_TOOL_SUCCESS_INIT    (@("success to open conceal tool"))

#define FLURRY_3D_ANALYSIS_REQUEST          (@("3D Analysis Requset"))
#define FLURRY_3D_ANALYSIS                  (@("3D Analysis"))

#define FLURRY_LOAD_MODEL_FAILED            (@("failed to load model"))

#define FLURRY_PAINT_CLICK              (@("paint click"))
#define FLURRY_PAINT_SELECT             (@("paint select"))
#define FLURRY_PAINT_OPTION             (@("paint option"))
#define FLURRY_PAINT_COLOR_SELECT       (@("paint color selected"))
#define FLURRY_PAINT_WALLPAPPER_CLICK   (@("paint wallpaper select"))
#define FLURRY_PAINT_FLOORTILE_CLICK    (@("paint floortile select"))


//Product tag category
#define EVENT_PRODUCT_DETAIL            (@"Product Detail")
#define EVENT_NAME_PRODUCT_DETAILS      (@"product details")

#define EVENT_NAME_DUPLICATE_PRODUCT    (@"duplicate product")
#define EVENT_NAME_RESTORE_SCALE        (@"restore scale")
#define EVENT_NAME_BRIGHTNESS           (@"brightness")
#define EVENT_NAME_SWIPE_PRODUCT_IMAGE  (@"swipe product image")
#define EVENT_NAME_DELETE_PRODUCT       (@"Product Deleted")
#define EVENT_NAME_DETAIL_PRODUCT       (@"Product Detail")
#define EVENT_NAME_CLICK_BRAND_LINK     (@"Click to Brand")

#define EVENT_PARAM_VAL_LOAD_ORIGIN_HIGHLIGHT_PRODUCT (@("Highlight Product"))

#define EVENT_PARAM_PRODUCT_ID          (@"product ID")
#define EVENT_PARAM_CONTENT_ID          (@"Content ID")
#define EVENT_PARAM_CONTENT_BRAND       (@"Content Brand")



// Catalog
#define FLURRY_REDESIGN_OPEN_CATALOG_CLICK  (@("redesign open catalog"))

#define FLURRY_CATALOG_ROOT_CATEGORY_CLICK  (@("Root Catalog Clicked"))
#define FLURRY_CATALOG_SUB_CATEGORY_CLICK   (@("Catalog Clicked"))
#define FLURRY_CATALOG_PRODUCT_SELECT_CLICK (@("Product Added"))
#define FLURRY_CATALOG_PRODUCT_VIEWD        (@"Product Viewed")
#define FLURRY_CATALOG_ROOT_WISHLIST_CLICK  (@("wishlist root category choose"))

#define EVENT_ACTION_CATALOG_NAME           (@("Catalog Name"))


#define FLURRY_DESIGN_STREAM_ITEM_VIEW  (@"design stream item click")

#define FLURRY_DESIGN_LIKE_CLICK        (@"design like click")
#define FLURRY_DESIGN_COMMENT_SEND      (@"design comment send")
#define EVENT_NAME_FOLLOW_CLICK         (@"follow click")


#define FLURRY_ADD_COMMENT      (@("user added comment"))
#define FLURRY_LIKE             (@("user liked item"))


#define FLURRY_SHOPPING_LIST_VISITED    (@("open shopping list"))
#define FLURRY_SHOPPING_LIST_SHARE      (@("share shopping list"))
#define FLURRY_SHOPPING_LIST_WEBSITE    (@("open product site from shopping list"))


// Event search
#define EVENT_NAME_SEARCH_STRING (@("Search"))
#define EVENT_PARAM_SEARCH_KEYWORD (@("Keyword"))


// Event AR
#define EVENT_AR                    (@("AR"))
#define EVENT_LABEL_AR_SCREENSHOT   (@("Screen Shot"))
#define EVENT_LABEL_AR_SCREENRECORD (@("Screen Record"))
#define EVENT_LABEL_AR_PRODUCT_INFO (@("Product Info"))


// Gallery Stream
#define EVENT_NAME_COMMUNITY        (@"Community")

#define EVENT_ACTION_COMMUNITY_LOAD_DESIGNSTREAM    (@"Load DesignStream")
#define EVENT_LABEL_COMMUNITY_FEATURE               (@"Feature")
#define EVENT_LABEL_COMMUNITY_FOLLOW                (@"Follow")
#define EVENT_LABEL_COMMUNITY_NEW                   (@"New")

//#define EVENT_ACTION_COMMUNITY_SORT         (@("Sort"))
//#define EVENT_ACTION_COMMUNITY_Filter       (@("Filter"))
#define EVENT_ACTION_COMMUNITY_ROOM_TYPE    (@"Room Name")


#define EVENT_NAME_EMPTY_ROOM           (@"Empty Room")
#define EVENT_ACTION_EMPTY_ROOM_FILTER  (@"Filter")
#define EVENT_ACTION_EMPTY_ROOM_SORT    (@"Sort")

// Event banner
#define EVENT_BANNER_CLICKED        (@("Banner Clicked"))


// Design Detail
#define EVENT_NAME_BROWSE_DESIGN    (@("Browse Design"))

#define FLURRY_ITEM_LIST            (@("Item list")) // comments list?


#define EVENT_ACTION_BANNER_NAME (@("Banner Name"))


// Notifications
#define EVENT_NAME_NOTIFICATIONS_UI_OPEN        (@"Notifications")
#define EVENT_PARAM_VAL_UISOURCE_PROFILE        (@"User Profile")
#define EVENT_PARAM_VAL_UISOURCE_COMMUNITY      (@"Community")
#define EVENT_PARAM_VAL_UISOURCE_DESIGN_DETAIL  (@"Design Detail")


#define EVENT_PARAM_VAL_LOAD_ORIGIN_USER_PROFILE (@("User Profile"))


// Screen views
#define GA_HOME_SCREEN (@("HomeActivity"))
#define GA_SPLASH_SCREEN (@("SplashScreenActivity"))
#define GA_PROFESSIONALS_SCREEN (@("ProfessionalsIndexActivity"))
#define GA_FULLSCREEN_SCREEN (@("FullScreenActivity"))
#define GA_DESIGN_STREAM_SCREEN (@("DesignsStreamActivity"))
#define GA_PRODUCT_CATALOG_SCREEN (@("ProductsCatalogActivity"))
#define GA_PROFILE_SCREEN (@("ProfileActivity"))
#define GA_PAINT_SCREEN (@("PaintActivity"))
#define GA_PROFESSIONAL_SCREEN (@("ProfessionalPageActivity"))
#define GA_3DTOOL_SCREEN (@("ToolActivity"))
#define GA_CAMERA_SCREEN (@("CameraActivity"))
#define GA_3DANALYS_SCREEN (@("AnalyzeActivity")) //currently not used
#define GA_PROFILE_SCREEN               (@"ProfileActivity")
#define GA_NOTIFICATIONS_SCREEN         (@"NotificationsActivity")
#define GA_PROFILE_FOLLOWING_SCREEN     (@"FollowingActivity")
#define GA_PROFILE_FOLLOWERS_SCREEN     (@"FollowersActivity")
#define GA_PROFILE_DESIGN_LIKES_SCREEN  (@"DesignLikesActivity")



//---- not used ----
#define FLURRY_SHARE (@("Share"))
#define FLURRY_DELETE_REQUEST_GUID (@("Delete Requset GUID"))
#define FLURRY_DELETE (@("Delete"))
#define FLURRY_ITEM_LIST_REQUEST (@("Item list Requset"))

#define FLURRY_FULL_SCREEN (@("fullScreenClicked Requset"))
#define FLURRY_SIGN_IN_GOOGLE_SUCCESS (@("sign in google plus success"))
#define FLURRY_SIGN_IN_GOOGLE_CLICK (@("sign in google plus"))
#define FLURRY_SIGN_IN_FACEBOOK_SUCCESS (@("sign in facebook success"))
#define FLURRY_SIGN_IN_FACEBOOK_CLICK (@("sign in facebook"))
#define FLURRY_SIGN_IN_EMAIL_CLICK (@("sign in email"))
#define FLURRY_SIGNUP_FACEBOOK_SUCCESS (@("sign up facebook success"))
#define FLURRY_SIGN_IN_MENU_CLICK (@("sign in menu"))
#define FLURRY_SIGNUP_SUCCESS_CLICK (@("sign up email success"))
#define FLURRY_ACCEPT_RECEIVE_EMAILS (@("accept emails status"))
#define FLURRY_ACCEPT_TERMS_SUCCESS (@("accept terms success"))

#define FLURRY_FEEDBACK_MENU_CLICK (@("feedback menu click"))
#define FLURRY_FEEDBACK_MAIL_SENT (@("feedback mail sent"))
#define FLURRY_PROFS_MENU_CLICK (@("professionals menu click"))


#define FLURRY_CATALOG_BRAND_VISIT_CLICK (@("catalog brand site visit"))
#define FLURRY_CATALOG_PRODUCT_CLICK (@("catalog product click"))
#define FLURRY_MYHOME_MENU_CLICK (@("my home menu click"))
#define FLURRY_LOW_MEMORY (@("low memory warning"))
#define FLURRY_MYDESIGNS_REFRESH (@("user designs refresh"))
#define FLURRY_MYARTICLES_REFRESH (@("user articles refresh"))
#define FLURRY_MYPROFS_REFRESH (@("user professionals refresh"))
#define FLURRY_CHANGE_PASSWORD (@("user changed password"))

#define FLURRY_PROFESIONAL_BY_ID (@("load professional page"))
#define FLURRY_PROFESIONALS_BY_FILTER (@("load professionals by filter"))
#define FLURRY_PROFESIONAL_SITE_VISIT (@("open website professional"))
#define FLURRY_PROFESIONAL_EMAIL_WRITE (@("open email professional"))
#define FLURRY_PROFESIONAL_PHONE_CLICK (@("open phone professional"))
#define FLURRY_PROFESIONAL_FOLLOW (@("professional follow/unfollow"))

#define FLURRY_EXTERNAL_WEBSITE_VISIT (@("safari website visit"))
#define FLURRY_TWITTER_SEND (@("design share twitter send"))
#define FLURRY_FILTER_TYPE_REQUEST (@("filter item type request"))
#define FLURRY_FILTER_ROOM_TYPE_REQUEST (@("filter room type request"))
#define FLURRY_SORT_REQUEST (@("sort request"))
#define FLURRY_COMMUNITY_SORT_FILTER (@("Community"))
#define FLURRY_3DDESIGN_MENU_CLICK (@("Design Stream menu type selection"))

#define FLURRY_PROFILE_FOLLOW (@("user profile follow click"))
#define FLURRY_PROFILE_EDIT (@("user profile edit click"))
#define FLURRY_PROFILE_EDIT_DONE (@("user profile done editing click"))
#define FLURRY_PROFILE_EDIT_PASSWORD_CLICK (@("user profile edit password click"))
#define FLURRY_PROFILE_DESIGNS_MENU_CLICK (@("designs menu click"))
#define FLURRY_PROFILE_FOLLOWINGS_MENU_CLICK (@("followings menu click"))
#define FLURRY_PROFILE_FOLLOWERS_MENU_CLICK (@("followers menu click"))
#define FLURRY_PROFILE_ARTICLES_MENU_CLICK (@("articles menu click"))
#define FLURRY_PROFILE_PROFESSIONALS_MENU_CLICK (@("professionals menu click"))
#define FLURRY_PROFILE_ACTIVITY_MENU_CLICK (@("activity menu click"))
#define FLURRY_MYDESIGNS_MENU_CLICK (@("my designs menu click"))
#define FLURRY_MYARTICLES_MENU_CLICK (@("my articles menu click"))
#define FLURRY_MYPROFESSIONALS_MENU_CLICK (@("my professionals menu click"))
#define FLURRY_BRIT_CO_CONTEST (@("open BRIT + CO. Design Competition."))
#define FLURRY_EXTERNAL_LINKS (@("external link/pn action"))
#define FLURRY_FIND_FRIEND_OPEN (@("find friends ui open"))
#define FLURRY_FIND_FRIEND_INVITE_EMAIL_SUCCESS (@("invite friend from email success"))
#define FLURRY_FIND_FRIEND_INVITE_EMAIL_OPEN (@("invite friend from email open"))
#define FLURRY_FIND_FRIEND_INVITE_FB_SUCCESS (@("invite friend from facebook success"))
#define FLURRY_FIND_FRIEND_INVITE_FB_OPEN (@("invite friend from facebook open"))
#define FLURRY_FIND_FRIEND_SEARCH_ON_HS (@("search friend on homestyler"))
#define FLURRY_FIND_FRIEND_GET_CONTACTS_FRIENDS (@("search contacts on homestyler"))
#define FLURRY_FIND_FRIEND_GET_FACEBOOK_FRIENDS (@("get facebook friends"))

/*Product Information Events*/
#define FLURRY_PROD_TAG_LOAD (@("product info open"))
#define FLURRY_PROD_TAG_DUPLICATE (@("product info action duplicate"))
#define FLURRY_PROD_TAG_DELETE (@("product info action delete"))
#define FLURRY_PROD_TAG_RESTORE_SCALE (@("product info action restore scale"))
#define FLURRY_PROD_TAG_BRAND_LOGO_CLICK (@("product info brand logo click"))
#define FLURRY_PROD_TAG_DETAILS_CLICK (@("product info details click"))




#define FLURRY_FACEBOOK_LIKE_SUCCESS (@("facebook like success"))
#define FLURRY_FACEBOOK_LIKE_FAILED (@("facebook like failed"))
#define EVENT_NAME_PROFILE_VISITED (@("user profile visit"))
#define EVENT_NAME_MY_PROFILE_VISITED (@("user my profile visit"))
#define EVENT_PARAM_PROFILE_VISIT_ID  (@("visted user id"))
#define EVENT_PARAM_PROFILE_VISITOR_ID  (@("visitor user id"))

#define EVENT_NAME_APP_LAUNCH       (@"app Launch")
#define EVENT_NAME_APP_ACTIVATED    (@"app Activated")
#define EVENT_LAST_SEEN_APP_LAUNCH (@("AppLaunch Last Seen"))
#define EVENT_TALLY_APP_LAUNCH (@("AppLaunch Tally"))
#define PARAM_NAME_APP_LAUNCH_DISTINCT_ID (@("AppLaunch Distinct ID"))
#define EVENT_NAME_USER_LOGIN_SUCCESS (@("successful login"))
#define EVENT_NAME_SHARE_UI_OPEN (@("share"))
#define EVENT_NAME_SHARE_UI_CANCEL (@("share ui cancel"))
#define EVENT_NAME_SHARE_ACTION_SUCCESS (@("share design succeess"))
#define EVENT_NAME_SHARE_ACTION_FAILURE (@("share design fail"))
#define EVENT_PARAM_USER_TYPE (@("user type"))
#define EVENT_PARAM_DESIGN_ITEM_TYPE (@("item type"))
#define EVENT_PARAM_UI_ORIGIN (@("Click Origin"))
#define EVENT_PARAM_SHARE_DESTINATION (@("Channel"))
#define EVENT_PARAM_VAL_USER_TYPE_FACEBOOK (@("facebook"))
#define EVENT_PARAM_VAL_USER_TYPE_REGULAR (@("regular"))
#define EVENT_PARAM_VAL_UISOURCE_DESIGN_STREAM (@("Design stream"))
#define EVENT_PARAM_VAL_UISOURCE_FULL_SCREEN (@("Full screen design"))
#define EVENT_PARAM_VAL_UISOURCE_DESIGN_TOOL (@("Design tool"))


//Ariel

// Event catagory sign in/up event 


// The Parameters value key For view sign in dialog event:

// Pareameters value for sign up/in trigger
#define EVENT_PARAM_VAL_FOLLOW_PROFESSIONAL (@("follow professional"))
#define EVENT_PARAM_VAL_LIKE_3D (@("like 3D"))
#define EVENT_PARAM_VAL_LIKE_2D (@("like 2D"))
#define EVENT_PARAM_VAL_LIKE_ARTICLE (@("like article"))
#define EVENT_PARAM_VAL_COMMENTS_ON_3D (@("comments on 3D"))
#define EVENT_PARAM_VAL_COMMENTS_ON_2D (@("comments on 2d"))
#define EVENT_PARAM_VAL_COMMENTS_ON_ARTICLE (@("comments on article"))
#define EVENT_PARAM_VAL_SAVE_DESIGN (@("save design"))
#define EVENT_PARAM_VAL_SIGNIN_MENU_BUTTON (@("sign in menu button"))
#define EVENT_PARAM_VAL_PROFESSIION_NAME (@("profession name"))
#define EVENT_PARAM_VAL_UNKNOWN (@("unknown"))

#define EVENT_PARAM_LOAD_ORIGIN_LIKE (@("Like"))

// Event catagory sign in/up event
#define EVENT_NAME_SIGNIN_WITH_WEBVIEW (@("sign in with WebView"))
#define EVENT_NAME_SIGNIN_WITH_FACEBOOK (@("sign in with Facebook"))
#define EVENT_NAME_SIGNUP_WITH_EMAIL (@("sign up with Email"))
#define EVENT_NAME_TERMS_AND_CONDIOTIONS (@("terms and condiotions"))
#define EVENT_NAME_AGREE_TO_RECIVE_EMAILS (@("agree to recive emails"))
#define EVENT_NAME_SIGN_OUT (@("sign out"))
#define EVENT_NAME_SUCCESSFUL_LOGIN (@("successful log in"))

//Event catagory Real scale
#define EVENT_NAME_VIEW_UNLOCK_REAL_SCALE_DIALOG (@("view unlock real scale dialog"))
#define EVENT_NAME_UNLOCK_REALSCALE (@("unlock real scale"))
#define EVENT_NAME_REAL_SCALE_WIZARD (@("real scale wizard"))

//Real scale Parameters key
#define EVENT_PARAM_UNLOCK_TRIGGER (@("unlock trigger"))
#define EVENT_PARAM_SCALE_LOCK_STATUS (@("scale lock status"))
#define EVENT_PARAM_WIZARD_TRIGGER (@("wizard trigger"))
#define EVENT_PARAM_WIZARD_FINISHED (@("wizard finished"))

//Real scale parameters value
#define EVENT_PARAM_VAL_REAL_SCALE_BUTTON (@("real scale button"))
#define EVENT_PARAM_VAL_PINCH (@("pinch"))
#define EVENT_PARAM_VAL_LOCK (@("lock"))
#define EVENT_PARAM_VAL_UNLOCK (@("unlock"))
#define EVENT_PARAM_VAL_BUTTON (@("button"))
#define EVENT_PARAM_VAL_PHOTO (@("photo"))
#define EVENT_PARAM_VAL_CANCELED (@("canceled"))
#define EVENT_PARAM_VAL_DONE (@("done"))

// Style wall catagory
#define EVENT_NAME_STYLE_WALL_PICKER_OPEN (@("style wall picker open"))
#define EVENT_NAME_STYLE_WALL_PICKER (@("Paint Picker"))
#define EVENT_NAME_STYLE_WALL_FINISH (@("style wall finish"))

// The parameters value key For style wall 
#define EVENT_PARAM_STYLE_WALL_TRIGGER (@("style wall trigger"))
#define EVENT_PARAM_DESGIN_ID (@("Design ID"))
#define EVENT_PARAM_DECOTRAION_CATAGORY (@("decoration catagory"))
#define EVENT_PARAM_DECORATION_BRAND (@("Product Brand"))
#define EVENT_PARAM_DECORATION_ID (@("Product id"))
#define EVENT_PARAM_DECORATION_NAME (@("Product Name"))

// Pareameters value for style wall
#define EVENT_PARAM_VAL_STYLE_WALL_BUTTON (@("style wall button"))
#define EVENT_PARAM_VAL_CHANGE_COLOR_BUTTON (@("change color button"))
#define EVENT_PARAM_VAL_PAINT (@("paint"))
#define EVENT_PARAM_VAL_WALLPAPER (@("wallpaper"))

// Request new product catagory
#define EVENT_NAME_CATALOG_REQUEST_TO_BROWSER (@("catalog request to browser"))
#define EVENT_NAME_BROWSER_REQUSET_PRODUCT_CLICKED (@("browser request product clicked"))
#define EVENT_NAME_CATALOG_REQUEST_OK_SEND_EMAIL (@("catalog request ok send email"))

// Parameters for requst caytagory
//#define EVENT_PARAM_PRODUCT_ID (@("product ID"))
#define EVENT_PARAM_USER_ID (@("user ID"))
#define EVENT_PARAM_DISTINCT_ID (@("Distinct ID"))
// Share category
#define EVENT_NAME_SHARE_DESIGN (@("share design"))

//The parameters key for Share category
#define EVENT_PARAM_ITEM_TYPE (@("item type"))
#define EVENT_PARAM_ORGIN (@("orgin"))
#define EVENT_PARAM_SHARE_OWNER (@("share owner"))
#define EVENT_PARAM_SHARE_TRIGGER (@("share trigger"))

// The parameters value for share category
#define EVENT_PARAM_VAL_ARTICLE (@("article"))
#define EVENT_PARAM_VAL_2D (@("2D"))
#define EVENT_PARAM_VAL_3D (@("3D"))
#define EVENT_PARAM_VAL_DESIGN_STREAM (@("design stream"))
#define EVENT_PARAM_VAL_FULL_SCREEN_DESIGN (@("full screen design"))
#define EVENT_PARAM_VAL_DESIGN_TOOL (@("design tool")
#define EVENT_PARAM_VAL_MINE (@("mine"))
#define EVENT_PARAM_VAL_OTHER (@("other"))
/*Events v1.4*/
#define EVENT_NAME_SIGNUP_OPTION_CLICK (@("Log In"))
#define PARAM_NAME_SIGN_IN_MAIN_MENU (@("Sign In"))
#define EVENT_NAME_LOGIN_CLICK_LOGIN_SCREEN (@("Log In Screen Clicks"))
#define EVENT_PARAM_VAL_SIGN_IN_CLICK_OPTION_BACK (@("Back"))
#define EVENT_PARAM_VAL_SIGN_IN_CLICK_OPTION_LOGIN (@("Log In"))
#define EVENT_PARAM_VAL_SIGN_IN_CLICK_OPTION_PASSWORD (@("Forgot Password"))
#define EVENT_PARAM_SIGN_IN_EMAIL_SUCCESS (@("Log In Confirmed"))
#define EVENT_NAME_LOGIN_SUBMIT (@("Log In Submit"))
#define EVENT_LAST_SEEN_LOGIN_CONFIRMED (@("Login Last Seen"))
#define EVENT_NAME_FACEBOOK_SIGNUP (@("Sign Up Facebook"))
#define EVENT_NAME_GOOGLE_SIGNUP (@("Sign Up Google"))
#define EVENT_NAME_EMAIL_SIGNUP (@("Sign Up Email"))
#define EVENT_NAME_EMAIL_SIGNUP_SUBMIT (@("Sign Up Email Submit"))
#define EVENT_NAME_FACEBOOK_SIGNUP_CONFIRM (@("Sign up Facebook confirmed"))
#define EVENT_NAME_GOOGLE_SIGNUP_CONFIRM (@("Sign Up Google Confirmed"))
#define EVENT_NAME_EMAIL_SIGNUP_CONFIRM (@("Sign Up Email Confirmed"))

#define EVENT_PARAM_VAL_FACEBOOK_OPTION (@("Facebook"))
#define EVENT_PARAM_VAL_GOOGLE_OPTION (@("Google"))
#define EVENT_PARAM_VAL_EMAIL_OPTION (@("Email"))
#define EVENT_PARAM_VAL_LOGIN_OPTION (@("Login"))
#define EVENT_PARAM_VAL_TERMS_OPTION (@("Terms of Service"))
#define EVENT_PARAM_VAL_PRIVACY_OPTION (@("Autodesk Privacy Statement"))
#define EVENT_LAST_SEEN_EMAIL_SIGNUP (@("SignUpEmail Last Seen"))
#define EVENT_LAST_SEEN_FACEBOOK_SIGNUP (@("SignUpFB Last Seen"))
#define EVENT_LAST_SEEN_GOOGLE_SIGNUP (@("SignUpGoogle Last Seen"))

/*Delft events */
#define EVENT_NAME_LOAD_DESIGN_TOOL (@("Load design tool"))
#define EVENT_NAME_LOAD_CATALOG (@("Load Catalog"))
#define EVENT_LAST_SEEN_OPEN_CATALOG (@("Load Catalog Last Seen"))
#define EVENT_PARAM_VAL_LOAD_ORIGIN_DESIGN_TOOL (@("Design Tool"))
#define EVENT_PARAM_VAL_LOAD_ORIGIN_HOME_SCREEN (@("Home Screen"))
#define EVENT_PARAM_VAL_LOAD_ORIGIN_REDESIGN (@("Redesign"))
#define EVENT_PARAM_VAL_LOAD_ORIGIN_NEW_DESIGN (@("New Design"))
#define EVENT_PARAM_VAL_LOAD_ORIGIN_CATALOG (@("Catalog"))
#define EVENT_PARAM_VAL_LOAD_ORIGIN_AFTERCRASH (@("Autosave recovery"))
#define EVENT_PARAM_VAL_LOAD_ORIGIN_PRODUCT_LIST (@("Product List"))
#define EVENT_PARAM_VAL_LOAD_ORIGIN_AR (@("AR"))
#define EVENT_PARAM_BRAND_PPL_CONTENT_ID (@("C Brand Cont ID"))
#define EVENT_NAME_VIEW_PRODUCT_TAG (@("Highlight Product"))
#define EVENT_NAME_PRODUCT_LIST (@("Product List"))
#define EVENT_NAME_ARTICLE_OPEN (@("Article"))
#define EVENT_PARAM_VAL_LOAD_ORIGIN_MAGAZINE (@("Homestyler Magazine"))
#define EVENT_PARAM_VAL_LOAD_ORIGIN_EXT_NOTIFICATION (@("Notification"))
#define EVENT_PARAM_NAME_ARTICLE_ID (@("Article ID")
#define EVENT_PARAM_NAME_DESIGN_ID (@("Design ID"))
#define EVENT_LAST_SEEN_BROWSE_DESIGN (@("B Design Last Seen"))
#define EVENT_PARAM_VAL_LOAD_ORIGIN_NEWDESIGN (@("New Design"))
#define EVENT_PARAM_VAL_LOAD_ORIGIN_3DSTREAM (@("Community"))
#define EVENT_PARAM_VAL_LOAD_ORIGIN_2DSTREAM (@("2D Design Stream"))
#define EVENT_NAME_HOTSPOT_CLICK (@("Hot Spot"))

#endif
