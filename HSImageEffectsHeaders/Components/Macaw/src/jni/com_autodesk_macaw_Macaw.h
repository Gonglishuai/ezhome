/* DO NOT EDIT THIS FILE - it is machine generated */
#include <jni.h>
/* Header for class com_autodesk_macaw_Macaw */

#ifndef _Included_com_autodesk_macaw_Macaw
#define _Included_com_autodesk_macaw_Macaw
#ifdef __cplusplus
extern "C" {
#endif
/*
 * Class:     com_autodesk_macaw_Macaw
 * Method:    initialize
 * Signature: ()I
 */
JNIEXPORT jint JNICALL Java_com_autodesk_macaw_Macaw_initialize
  (JNIEnv *, jobject);

/*
 * Class:     com_autodesk_macaw_Macaw
 * Method:    setPattern
 * Signature: (Ljava/lang/String;Lcom/autodesk/macaw/Texture;)I
 */
JNIEXPORT jint JNICALL Java_com_autodesk_macaw_Macaw_setPattern
  (JNIEnv *, jobject, jstring, jobject);

/*
 * Class:     com_autodesk_macaw_Macaw
 * Method:    render
 * Signature: (Lcom/autodesk/macaw/Effect;Lcom/autodesk/macaw/Texture;Lcom/autodesk/macaw/Texture;)I
 */
JNIEXPORT jint JNICALL Java_com_autodesk_macaw_Macaw_render
  (JNIEnv *, jobject, jobject, jobject, jobject);

#ifdef __cplusplus
}
#endif
#endif
