//
//  MathMacros.h
//  CmyCasa
//
//  Created by Or Sharir on 11/11/12.
//
//

#ifndef CmyCasa_MathMacros_h
#define CmyCasa_MathMacros_h

///////////////////////////////////////////////////////
//           Math Macros                             //
///////////////////////////////////////////////////////
#define BIASED_SIGN(x) (x >= 0 ? 1 : -1)
#define SIGN(x) (x == 0 ? 0 : (x > 0 ? 1 : -1))
#define BETWEEN(LOW, HIGH, VALUE) (MAX(LOW, MIN(HIGH, VALUE)))
#define CGPointDistance(p1, p2) (sqrtf((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y)*(p1.y - p2.y)))

#define EPSILON (0.0001f)
#define FLOAT_EQUAL(X, VALUE)    ((abs(X - EPSILON) < VALUE))

#endif
