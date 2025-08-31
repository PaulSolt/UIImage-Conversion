//
//  ImageHelper.m
//  ImageConversion
//
//  Created by Paul Solt on 9/22/10.
//  Copyright 2010 Paul Solt. All rights reserved.
//

#import "ImageHelper.h"


@implementation ImageHelper


+ (unsigned char *) convertUIImageToBitmapRGBA8:(UIImage *) image {
	
	CGImageRef imageRef = image.CGImage;
	
	// Create a bitmap context to draw the uiimage into
	CGContextRef context = [self newBitmapRGBA8ContextFromImage:imageRef];
	
	if(!context) {
		return NULL;
	}
	
	size_t width = CGImageGetWidth(imageRef);
	size_t height = CGImageGetHeight(imageRef);
	
	CGRect rect = CGRectMake(0, 0, width, height);
	
	// Draw image into the context to get the raw image data
	CGContextDrawImage(context, rect, imageRef);
	
	// Get a pointer to the data	
	unsigned char *bitmapData = (unsigned char *)CGBitmapContextGetData(context);
	
	// Copy the data and release the memory (return memory allocated with new)
	size_t bytesPerRow = CGBitmapContextGetBytesPerRow(context);
	size_t bufferLength = bytesPerRow * height;
	
	unsigned char *newBitmap = NULL;
	
	if(bitmapData) {
		newBitmap = (unsigned char *)malloc(sizeof(unsigned char) * bytesPerRow * height);
		
		if(newBitmap) {	// Copy the data
			for(int i = 0; i < bufferLength; ++i) {
				newBitmap[i] = bitmapData[i];
			}
		}
		
	} else {
		NSLog(@"Error getting bitmap pixel data\n");
	}
	
	CGContextRelease(context);
	if(bitmapData) {
		free(bitmapData);
	}
	
	return newBitmap;	
}

+ (CGContextRef) newBitmapRGBA8ContextFromImage:(CGImageRef) image {
	CGContextRef context = NULL;
	CGColorSpaceRef colorSpace;
	uint32_t *bitmapData;
	
	size_t bitsPerPixel = 32;
	size_t bitsPerComponent = 8;
	size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;
	
	size_t width = CGImageGetWidth(image);
	size_t height = CGImageGetHeight(image);
	
	size_t bytesPerRow = width * bytesPerPixel;
	size_t bufferLength = bytesPerRow * height;
	
	colorSpace = CGColorSpaceCreateDeviceRGB();
	
	if(!colorSpace) {
		NSLog(@"Error allocating color space RGB\n");
		return NULL;
	}
	
	// Allocate memory for image data
	bitmapData = (uint32_t *)malloc(bufferLength);
	
	if(!bitmapData) {
		NSLog(@"Error allocating memory for bitmap\n");
		CGColorSpaceRelease(colorSpace);
		return NULL;
	}
	
	//Create bitmap context
	
	context = CGBitmapContextCreate(bitmapData, 
									width, 
									height, 
									bitsPerComponent, 
									bytesPerRow, 
									colorSpace, 
									kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);	// RGBA
	
	if(!context) {
		free(bitmapData);
		NSLog(@"Bitmap context not created");
	}
	
	CGColorSpaceRelease(colorSpace);
	
	return context;	
}

+ (UIImage *) convertBitmapRGBA8ToUIImage:(unsigned char *) buffer 
								withWidth:(int) width
							   withHeight:(int) height {
	
	
	size_t bufferLength = width * height * 4;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, bufferLength, NULL);
	size_t bitsPerComponent = 8;
	size_t bitsPerPixel = 32;
	size_t bytesPerRow = 4 * width;
	
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	if(colorSpaceRef == NULL) {
		NSLog(@"Error allocating color space");
		CGDataProviderRelease(provider);
		return nil;
	}
	
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast; 
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	CGImageRef iref = CGImageCreate(width, 
									height, 
									bitsPerComponent, 
									bitsPerPixel, 
									bytesPerRow, 
									colorSpaceRef, 
									bitmapInfo, 
									provider,	// data provider
									NULL,		// decode
									YES,			// should interpolate
									renderingIntent);
		
	uint32_t* pixels = (uint32_t*)malloc(bufferLength);
	
	if(pixels == NULL) {
		NSLog(@"Error: Memory not allocated for bitmap");
		CGDataProviderRelease(provider);
		CGColorSpaceRelease(colorSpaceRef);
		CGImageRelease(iref);		
		return nil;
	}
	
	CGContextRef context = CGBitmapContextCreate(pixels, 
												 width, 
												 height, 
												 bitsPerComponent, 
												 bytesPerRow, 
												 colorSpaceRef, 
												 kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast); 
	
	if(context == NULL) {
		NSLog(@"Error context not created");
		free(pixels);
	}
	
	UIImage *image = nil;
	if(context) {
		
		CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), iref);
		
		CGImageRef imageRef = CGBitmapContextCreateImage(context);
		
		// Support both iPad 3.2 and iPhone 4 Retina displays with the correct scale
		if([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
			float scale = [[UIScreen mainScreen] scale];
			image = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
		} else {
			image = [UIImage imageWithCGImage:imageRef];
		}
		
		CGImageRelease(imageRef);	
		CGContextRelease(context);	
	}
	
	CGColorSpaceRelease(colorSpaceRef);
	CGImageRelease(iref);
	CGDataProviderRelease(provider);
	
	if(pixels) {
		free(pixels);
	}	
	return image;
}



+ (UIImage *) compositeImage:(UIImage *)topImage onImage:(UIImage *)bottomImage withInset:(CGSize)theInset{

	CGFloat scale = 1.0;
	if([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
		scale = [[UIScreen mainScreen] scale];
	}
	
	NSUInteger width = bottomImage.size.width * scale; // + 20;
	NSUInteger height = bottomImage.size.height * scale; // + 20;
	
	//size_t bufferLength = width * height * 4;
	size_t bitsPerComponent = 8;
	//size_t bitsPerPixel = 32;
	size_t bytesPerRow = 4 * width;
	
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
		
	CGContextRef context = CGBitmapContextCreate(NULL, 
												 width, 
												 height, 
												 bitsPerComponent, 
												 bytesPerRow, 
												 colorSpaceRef, 
												 kCGImageAlphaPremultipliedLast); 
	
	
	
	UIImage *image = nil;
	if(context) {
		
//		CGContextDrawImage(context, CGRectMake(15.0f, 15.0f, width - 30, height - 30), bottomImage.CGImage);
		CGContextDrawImage(context, CGRectMake(theInset.width * scale, theInset.height * scale, width - (scale * 2 * theInset.width), 
											   height - (scale * 2 * theInset.height)), bottomImage.CGImage);
		
		CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), topImage.CGImage);
		
		CGImageRef imageRef = CGBitmapContextCreateImage(context);
		
		// Support both iPad 3.2 and iPhone 4 Retina displays with the correct scale
		if([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
			float scale = [[UIScreen mainScreen] scale];
			image = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
		//	ALog(@"RETINA");
		} else {
		//	ALog(@"NOT RETINA");
			image = [UIImage imageWithCGImage:imageRef];
		}
		
		
		
		CGImageRelease(imageRef);	
		CGContextRelease(context);	
	}
	
	CGColorSpaceRelease(colorSpaceRef);
		
	return image;
}

//+ (UIImage *) scaleImage:(UIImage *)theImage toSize:(CGSize)newSize keepAspectRatio:(BOOL)aspectRatio { 
//	CGFloat scale = 1.0;
//	if([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
//		scale = [[UIScreen mainScreen] scale];
//	}
//    
//    if(aspectRatio) {
//        // Use the longer edge and scale respectively
//        CGFloat maxScaleSize = MAX(newSize.width, newSize.height);
//        
//        CGFloat maxImageSize = MAX(theImage.size.width, theImage.size.height);
//        
//        
//        CGFloat scaleFactor = maxImageSize / maxScaleSize;
//        newSize.width = theImage.size.width / scaleFactor;
//        newSize.height = theImage.size.height / scaleFactor;
//    }
//	
//	NSUInteger width = newSize.width * scale; //theImage.size.width * scale; // + 20;
//	NSUInteger height = newSize.height * scale; //theImage.size.height * scale; // + 20;
//	
//    ALog(@"Scale: %d x %d", width, height);
//    
//	size_t bitsPerComponent = 8;
//	size_t bytesPerRow = 4 * width;	
//	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
//    
//	CGContextRef context = CGBitmapContextCreate(NULL, 
//												 width, 
//												 height, 
//												 bitsPerComponent, 
//												 bytesPerRow, 
//												 colorSpaceRef, 
//												 kCGImageAlphaPremultipliedLast); 
//    UIImage *image = nil;
//	if(context) {
//        CGContextDrawImage(context, CGRectMake(0, 0, width, height), theImage.CGImage);
//		CGImageRef imageRef = CGBitmapContextCreateImage(context);
//		
//		// Support both iPad 3.2 and iPhone 4 Retina displays with the correct scale
//		if([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
//			float scale = [[UIScreen mainScreen] scale];
//			image = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
//            //	ALog(@"RETINA");
//		} else {
//            //	ALog(@"NOT RETINA");
//			image = [UIImage imageWithCGImage:imageRef];
//		}
//		CGImageRelease(imageRef);	
//		CGContextRelease(context);	
//	}
//	CGColorSpaceRelease(colorSpaceRef);
//    return image;
//}

+ (UIImage *)scaleImage:(UIImage*)image toSize:(CGSize)newSize keepAspectRatio:(BOOL)aspectRatio
{
       
    if(aspectRatio) {
        // Use the longer edge and scale respectively
        //CGFloat maxScaleSize = MAX(newSize.width, newSize.height);
        CGFloat minScaleSize = MIN(newSize.width, newSize.height);
        
        //CGFloat maxImageSize = MAX(image.size.width, image.size.height);
        CGFloat minImageSize = MIN(image.size.width, image.size.height);
        
        //CGFloat scaleFactor = maxImageSize / maxScaleSize;
        CGFloat scaleFactor = minImageSize / minScaleSize;
        
        newSize.width = image.size.width / scaleFactor;
        newSize.height = image.size.height / scaleFactor;
    }
    
    // Account for the scale on the UIImage (High resolution screens)
    CGFloat scale = [[UIScreen mainScreen] scale];
   
//    if(scale != 1 && scale != 0) {
//        newSize.width /= scale;
//        newSize.height /= scale;
//    }
    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
//    UIImage *scaledImage = [UIImage imageWithCGImage:[newImage CGImage] scale:scale orientation:UIImageOrientationUp];

//    return scaledImage;
    return newImage;
}

@end
