//
//  GraphicsCommon.h
//  ImageConversion
//
//  Created by Paul Solt on 8/24/11.
//  Copyright 2011 Paul Solt. All rights reserved.
//

//#import <Foundation/Foundation.h>
//
//@interface GraphicsCommon : NSObject
//
//
//@end

#include <iostream>
#include <sstream>

static const int NUMBER_COLORS = 4;	

/** The Color3D structure is used for storing the Red, Green, Blue, and Alpha components. */
struct Color3D {
    
    Color3D() : red(0.0f), green(0.0f), blue(0.0f), alpha(1.0f) {}
    
    float red;
    float green;
    float blue;
    float alpha;
}; // Color3D;

/** Prints out a Color3D structure */
static std::ostream &operator<<(std::ostream &os, const Color3D &c) {
    os << "Color: (" << c.red << ", " << c.green << ", " << c.blue << ", " << c.alpha << ")";
    return os;
}

static std::string toString(const Color3D &c) {
    std::ostringstream os;
    os << "Color: (" << c.red << ", " << c.green << ", " << c.blue << ", " << c.alpha << ")";
    std::string str(os.str());
    return str;
}

/** Converts a single color value from floating point space (0.0-1.0) to unsigned char (RGBA8) format.
 Red,green,blue,alpha in 0.0-1.0 space
 color will be in range 0-255
 Requires 4 component (RGBA) (unsigned char *) to be already allocated
 */
static inline void color3dToRGBA8(Color3D *colorIn, unsigned char *colorOut) {
    
    // Clamp the negative colors to black, it's undefined behavior otherwise. 
    Color3D newColor = *colorIn;
    if(newColor.red < 0) {
        newColor.red = 0;
    }
    if(newColor.green < 0) {
        newColor.green = 0;
    }
    if(newColor.blue < 0) {
        newColor.blue = 0;
    }
    
    colorOut[0] = static_cast<unsigned char>(newColor.red * 255);
    colorOut[1] = static_cast<unsigned char>(newColor.green * 255);
    colorOut[2] = static_cast<unsigned char>(newColor.blue * 255);
    colorOut[3] = static_cast<unsigned char>(newColor.alpha * 255);
}

static inline void RGBA8ToColor3d(unsigned char *colorIn, Color3D *colorOut) {
    colorOut->red = static_cast<float>(colorIn[0]) / 255.0f;
    colorOut->green = static_cast<float>(colorIn[1]) / 255.0f;
    colorOut->blue = static_cast<float>(colorIn[2]) / 255.0f;
    colorOut->alpha = static_cast<float>(colorIn[3]) / 255.0f;
}

/** Converts a single color value from the colors Red, Green, Blue, Alpha in RGBA8 format to floating
 point format in (0.0-1.0) range.
 Requires the memory to be allocated for the colorOut parameter.
 @param red - the red component
 @param green - the green component
 @param blue - the blue component
 @param alpha - the alpha component
 @param colorOut - the floating point Color3D structure to store the conversion
 */
static inline void RGBA8ToColor3d(unsigned char red, unsigned char green, unsigned char blue,
                                  unsigned char alpha, Color3D *colorOut) {
    colorOut->red = static_cast<float>(red) / 255.0f;
    colorOut->green = static_cast<float>(green) / 255.0f;
    colorOut->blue = static_cast<float>(blue) / 255.0f;
    colorOut->alpha = static_cast<float>(alpha) / 255.0f;
}

/** Converts a Color3D image to RGBA8 (unsigned char *) given the image dimensions. The function
 assumes the number of bytes per pixel color is 4. The memory should be allocated before calling this 
 method. It simply copies data from one type to the other. ImageOut should be width*height*4
 @param imageIn - the image that should be converted
 @param imageOut - the image that should be used for output
 @param width - the number of pixels wide
 @param height - the number of pixels high.
 */
static inline void ConvertImageColor3dToRGBA8(Color3D *imageIn, unsigned char *imageOut, int width, int height) {
    int length = width * height;
    
    // Need to increment unsigned char pointer by the number of colors each loop
    for(int i = 0, j = 0; i < length; ++i, j+=NUMBER_COLORS) {
        color3dToRGBA8(&imageIn[i], &imageOut[j]);
    }
    
}

static inline void ConvertImageRGBA8ToColor3d(unsigned char *imageIn, Color3D *imageOut, int width, int height) {
    int length = width * height;
    
    // Need to increment unsigned char pointer by the number of colors each loop
    for(int i = 0, j = 0; i < length; ++i, j+=NUMBER_COLORS) {
        RGBA8ToColor3d(&imageIn[j], &imageOut[i]);
    }
}