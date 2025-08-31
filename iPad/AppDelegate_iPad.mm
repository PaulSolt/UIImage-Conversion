//
//  AppDelegate_iPad.m
//  ImageConversion
//
//  Created by Paul Solt on 9/22/10.
//  Copyright 2010 RIT. All rights reserved.
//

#import "AppDelegate_iPad.h"
#import "ImageHelper.h"
#import "GraphicsCommon.h"
#import <QuartzCore/QuartzCore.h>
#include <cstdlib>

@implementation AppDelegate_iPad

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    // Ensure window has a root view controller (required on iOS 5+).
    // Wrap in respondsToSelector for legacy SDK compatibility.
    if ([self.window respondsToSelector:@selector(setRootViewController:)]) {
        UIViewController *rootViewController = [[UIViewController alloc] init];
        self.window.rootViewController = rootViewController;
        [rootViewController release];
    }
//
    UIImage *image = [UIImage imageNamed:@"Icon4.png"];
	int width = image.size.width;
	int height = image.size.height;
	
	// Create a bitmap
	unsigned char *bitmap = [ImageHelper convertUIImageToBitmapRGBA8:image];
	
	// Create a UIImage using the bitmap
	UIImage *imageCopy = [ImageHelper convertBitmapRGBA8ToUIImage:bitmap withWidth:width withHeight:height];
	
	// Cleanup
	if(bitmap) {
		free(bitmap);	
		bitmap = NULL;
	}
	
	// Display the image copy on the GUI
	UIImageView *imageView = [[UIImageView alloc] initWithImage:imageCopy];
	CGPoint center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2.0, 
								 [UIScreen mainScreen].bounds.size.height / 2.0);
	[imageView setCenter:center];
	[window addSubview:imageView];
	[imageView release];
    
    CGPoint iconPosition = CGPointMake([UIScreen mainScreen].bounds.size.width / 2.0,
                                        [UIScreen mainScreen].bounds.size.height / 2.0);
    [self addImage:@"Icon4.png" atPosition:iconPosition];
    
    CGPoint arrowPosition = CGPointMake([UIScreen mainScreen].bounds.size.width / 2.0, 
                                   [UIScreen mainScreen].bounds.size.height / 4.0);
    [self addImage:@"ShareArrow.png" atPosition:arrowPosition];
	
    [window makeKeyAndVisible];
    
    return YES;
}

- (void)addImage:(NSString *)theFilename atPosition:(CGPoint)thePosition {
    UIImage *image = [UIImage imageNamed:theFilename];
	int width = image.size.width;
	int height = image.size.height;
	
	// Create a bitmap
	unsigned char *bitmap = [ImageHelper convertUIImageToBitmapRGBA8:image];
    Color3D *colorOut = new Color3D[width * height];
    ConvertImageRGBA8ToColor3d(bitmap, colorOut, width, height);
    
    // **NOTE:** Test Print the colors using a c++ code to check transparency
//    for(int i = 0; i < width * height; ++i) {
//        std::cout << colorOut[i] << std::endl;
//    }
	
	// Create a UIImage using the bitmap
	UIImage *imageCopy = [ImageHelper convertBitmapRGBA8ToUIImage:bitmap withWidth:width withHeight:height];

    // Round-trip back to bytes and compute per-pixel differences
    unsigned char *bitmap2 = [ImageHelper convertUIImageToBitmapRGBA8:imageCopy];
    size_t len = (size_t)width * (size_t)height * 4;
    NSUInteger diffs = 0;
    unsigned char *diffBuf = (unsigned char *)malloc(len);
    if (diffBuf && bitmap && bitmap2) {
        for (size_t j = 0; j < len; j += 4) {
            int dr = (int)bitmap2[j+0] - (int)bitmap[j+0];
            int dg = (int)bitmap2[j+1] - (int)bitmap[j+1];
            int db = (int)bitmap2[j+2] - (int)bitmap[j+2];
            int da = (int)bitmap2[j+3] - (int)bitmap[j+3];
            if (dr|dg|db|da) { diffs++; }
            diffBuf[j+0] = (unsigned char)abs(dr);
            diffBuf[j+1] = (unsigned char)abs(dg);
            diffBuf[j+2] = (unsigned char)abs(db);
            diffBuf[j+3] = 255;
        }
    }
    UIImage *diffImage = nil;
    if (diffBuf) {
        diffImage = [ImageHelper convertBitmapRGBA8ToUIImage:diffBuf withWidth:width withHeight:height];
    }
    if (diffBuf) { free(diffBuf); }
    if (colorOut) { delete [] colorOut; }
    if (bitmap2) { free(bitmap2); }
    if(bitmap) {
        free(bitmap);
        bitmap = NULL;
    }
	
    // Display the image copy on the GUI
	UIImageView *imageView = [[UIImageView alloc] initWithImage:imageCopy];
	[imageView setCenter:thePosition];
	if ([self.window respondsToSelector:@selector(rootViewController)] && self.window.rootViewController) {
		[self.window.rootViewController.view addSubview:imageView];
	} else {
		[window addSubview:imageView];
	}

    // Show a compact diff label and optional diff image below
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 24)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:14.0f];
    label.textColor = [UIColor darkGrayColor];
    label.center = CGPointMake(thePosition.x, thePosition.y + imageView.bounds.size.height/2.0f + 14.0f);
    label.text = [NSString stringWithFormat:@"Diff count: %lu", (unsigned long)diffs];
    if ([self.window respondsToSelector:@selector(rootViewController)] && self.window.rootViewController) {
        [self.window.rootViewController.view addSubview:label];
    } else {
        [window addSubview:label];
    }
    [label release];

    if (diffImage && diffs > 0) {
        UIImageView *diffView = [[UIImageView alloc] initWithImage:diffImage];
        CGPoint p = thePosition;
        p.y += imageView.bounds.size.height/2.0f + 14.0f + 12.0f + diffView.bounds.size.height/2.0f;
        diffView.center = p;
        // Add a thin border to distinguish
        diffView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        diffView.layer.borderWidth = 1.0f;
        if ([self.window respondsToSelector:@selector(rootViewController)] && self.window.rootViewController) {
            [self.window.rootViewController.view addSubview:diffView];
        } else {
            [window addSubview:diffView];
        }
        [diffView release];
    }

    [imageView release];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
