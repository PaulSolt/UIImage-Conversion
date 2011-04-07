//
//  AppDelegate_iPad.m
//  ImageConversion
//
//  Created by Paul Solt on 9/22/10.
//  Copyright 2010 RIT. All rights reserved.
//

#import "AppDelegate_iPad.h"
#import "ImageHelper.h"

@implementation AppDelegate_iPad

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.

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

	
    [window makeKeyAndVisible];
    
    return YES;
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
