//
//  UtilMacros.h
//  Homestyler
//
//  Created by Avihay Assouline on 4/7/14.
//
//

#ifndef Homestyler_UtilMacros_h
#define Homestyler_UtilMacros_h

///////////////////////////////////////////////////////
//           UTIL DEFINES                            //
///////////////////////////////////////////////////////
#define API_ERROR_CODE  (-1)
#define NBE_API_ERROR_CODE  (0)

///////////////////////////////////////////////////////
//           UTIL MACROS                             //
///////////////////////////////////////////////////////
#define CHECK_C_NULL_RETURN_NIL(x) if (NULL == x) return nil

#define RETURN_ON_NIL(x, y) if (!x) return y

#define RETURN_VOID_ON_NIL(x) RETURN_ON_NIL(x, )

// Dispatch async on the main queue - Usually used for UI updated
#define DISPATCH_ASYNC_ON_MAIN_QUEUE(x)   dispatch_async(dispatch_get_main_queue(),^{x;})

#endif
