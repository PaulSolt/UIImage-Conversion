//
//  ImageHelper.h
//  ImageConversion
//
//  Created by Paul Solt on 9/22/10.
//  Copyright 2010 Paul Solt. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ImageHelper : NSObject {
	
}

/** Converts a UIImage to RGBA8 bitmap.
 @param image - a UIImage to be converted
 @return a RGBA8 bitmap, cleanup memory with free() when done.
 */
+ (unsigned char *) convertUIImageToBitmapRGBA8:(UIImage *)image;

/** A helper routine used to convert a RGBA8 to UIImage */
+ (CGContextRef) createBitmapRGBA8ContextFromImage:(CGImageRef)image;


/** Converts a RGBA8 bitmap to a UIImage. 
 @param buffer - the RGBA8 unsigned char * bitmap
 @param width - the number of pixels wide
 @param height - the number of pixels tall
 @return a UIImage that is autoreleased 
 */
+ (UIImage *) convertBitmapRGBA8ToUIImage:(unsigned char *)buffer 
								withWidth:(int)width
							   withHeight:(int)height;

@end
