#pragma once
#include "photolib_defs.h"

#ifdef IOS
	#define PHOTOLIB_API
#else
	#ifdef LOCAL_PHOTOLIB
		#define PHOTOLIB_API 
		#else
			#define PHOTOLIB_API __declspec(dllexport)
		#endif
#endif

// fillOrderMask shall be allocated in advance with the same size as scribbles, 16-unsigned depth, and 1 channel. 
// fillOrderMask is returned only if mode = 0. if mode =1 it can be set to null, 
// mode: 0 - work on source, 2 - remove lightness from source and add the lightness after the painting.
// SourceNoLight - Background image with no light (the one which was returned from the getBackgroundWithNoLight
//                 function. Can be set to NULL and then the no-light image is computed internally.
// numOfScribbles is an input/output parameter  - start with 0, and next put the last you got.
// negScribbSdvMargin  - control how many automatic negative scribbles: 20 - usually won't paint the floor but you will may more times for wall,
//																		35 - sometimes floor will be painted,  but less times for wall
//                     - Start with 20 and go up if needed.
PHOTOLIB_API IplImage* getRecolorMask(const IplImage* const background, const IplImage* const scribbles, int* numOfScribbles, IplImage*  fillOrderMask, const IplImage* const sourceNoLight, int mode, int negScribbSdvMargin);
