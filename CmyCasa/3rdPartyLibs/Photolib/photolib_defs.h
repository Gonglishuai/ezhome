/**
 * @file: photolib_defs.h
 * @author  Gil Hoffer <hoffer@gmail.com>
 * @Amendments by DZ <dror@inspiringvision-tech.com>
 * Version 2.0 
 * @section LICENSE
 *
 *
 * @section DESCRIPTION
 *
 * Some definitions we use throughout the library
 *
 */
#pragma once
#define IOS
//#define LOCAL_PHOTOLIB
#ifdef IOS
	#include <opencv2/opencv.hpp>
#else
	#include <opencv/cv.h>
#endif

typedef unsigned char byte;
typedef unsigned int uint;

/**
 * TIMEBOMB Mode is used in order to make the library expire at a certain date.
 * Works only in Windows.
 * Undef if you want to disable it.
 * Also set TIMEBOMB_MONTH and TIMEBOMB_YEAR to the correct values.
 */

/**
 * Our own definition for a line.
 * Allows initialization from 2 points, getting the line coefficients, assigning a x/y value, and calculating line-point distance.
 */
typedef class CvLine {
public:
	CvLine() :p1(cvPoint(-1,-1)), p2(cvPoint(-1,-1)) {}
	CvLine(const CvPoint& q1,const  CvPoint& q2) : p1(q1), p2(q2) {}

	double a() const { 
		int dx = p1.x - p2.x;
		int dy = p1.y - p2.y;
		if (dx == 0 ) {
			dx =1;
		}
		return (double)dy / (double)dx;
	}
	double b(double a) const {return p1.y - a*p1.x;}
	double assign(double x) const {double a1 = a(); return a1*x+b(a1);}

	double assign_y( double y ) const {	double a1 = a();return (y-b(a1))/a1; }
	double distance(const CvPoint& p) const {
		double numinator = std::abs((p2.x - p1.x)*(p1.y - p.y) - (p1.x - p.x)*(p2.y - p1.y));
		double denum = std::sqrt((double) ((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y)));
		return numinator/denum;
	}

	CvPoint p1;
	CvPoint p2;
} CvLine;

//#define DEBUG_PRINTING
#ifdef DEBUG_PRINTING
#define DEBUG_PRINT(...) do{ fprintf( stderr, __VA_ARGS__ ); } while( false )
#else
#define DEBUG_PRINT(...) do{ } while ( false )
#endif 