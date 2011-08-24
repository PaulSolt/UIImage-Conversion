//
//  AppDelegate_iPad.h
//  ImageConversion
//
//  Created by Paul Solt on 9/22/10.
//  Copyright 2010 RIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate_iPad : NSObject <UIApplicationDelegate> {
    UIWindow *window;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;


// Adds an image to an imageview on the window
- (void)addImage:(NSString *)theFilename atPosition:(CGPoint)thePosition;

@end

