//
//  AppDelegate_iPhone.m
//  ImageConversion
//
//  Created by Paul Solt on 9/22/10.
//  Copyright 2010 RIT. All rights reserved.
//

#import "AppDelegate_iPhone.h"
#import "ImageHelper.h"
#import <QuartzCore/QuartzCore.h>

@implementation AppDelegate_iPhone

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

    [window makeKeyAndVisible];

    // Round-trip UI: show Original, Round-trip, and Diff for Icon4
    UIView *host = nil;
    if ([self.window respondsToSelector:@selector(rootViewController)] && self.window.rootViewController) {
        host = self.window.rootViewController.view;
    } else {
        host = (UIView *)window;
    }

    UIImage *src = [UIImage imageNamed:@"Icon4.png"];
    if (src && host) {
        // Wrap content in a scroll view to prevent overlap/clipping when many triads are shown
        UIView *originalHost = host;
        UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:originalHost.bounds];
        scroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [originalHost addSubview:scroll];
        host = scroll; // add all demo views into the scroll view
        [scroll release];

        // No precompute; triads below handle their own round-trip/diff

        // Layout: stack vertically with labels
        CGFloat margin = 16.0f;
        __block CGFloat y = 80.0f; // allow mutation within blocks
        CGFloat maxWidth = host.bounds.size.width - 2 * margin;

        UILabel *(^makeLabelAtY)(NSString *) = ^UILabel*(NSString *text){
            UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(margin, y, host.bounds.size.width - 2*margin, 18.0f)];
            l.font = [UIFont systemFontOfSize:14.0f];
            l.textColor = [UIColor darkGrayColor];
            l.backgroundColor = [UIColor clearColor];
            l.textAlignment = NSTextAlignmentLeft;
            l.text = text;
            return [l autorelease];
        };

        UIImageView *(^makeImageViewAtY)(UIImage *, CGSize) = ^UIImageView*(UIImage *img, CGSize size){
            UIImageView *iv = [[UIImageView alloc] initWithImage:img];
            iv.frame = CGRectMake((host.bounds.size.width - size.width)/2.0f, y, size.width, size.height);
            iv.layer.borderColor = [UIColor colorWithWhite:0.85 alpha:1.0].CGColor;
            iv.layer.borderWidth = 1.0f;
            return [iv autorelease];
        };

        // Helper to append a triad and return updated y
        void (^appendTriad)(UIImage *, NSString *) = ^(UIImage *img, NSString *title){
            if (!img) return;
            CGImageRef cg2 = img.CGImage;
            size_t w2 = CGImageGetWidth(cg2);
            size_t h2 = CGImageGetHeight(cg2);
            size_t len2 = w2 * h2 * 4;
            unsigned char *t1 = [ImageHelper convertUIImageToBitmapRGBA8:img];
            UIImage *rt2 = [ImageHelper convertBitmapRGBA8ToUIImage:t1 withWidth:(int)w2 withHeight:(int)h2];
            unsigned char *t2 = [ImageHelper convertUIImageToBitmapRGBA8:rt2];
            NSUInteger dc = 0;
            unsigned char *db = (unsigned char *)malloc(len2);
            if (db && t1 && t2) {
                for (size_t j = 0; j < len2; j += 4) {
                    int dr = (int)t2[j+0] - (int)t1[j+0];
                    int dg = (int)t2[j+1] - (int)t1[j+1];
                    int dbv = (int)t2[j+2] - (int)t1[j+2];
                    int da = (int)t2[j+3] - (int)t1[j+3];
                    if (dr|dg|dbv|da) { dc++; }
                    db[j+0] = (unsigned char)abs(dr);
                    db[j+1] = (unsigned char)abs(dg);
                    db[j+2] = (unsigned char)abs(dbv);
                    db[j+3] = 255;
                }
            }
            UIImage *dimg = db ? [ImageHelper convertBitmapRGBA8ToUIImage:db withWidth:(int)w2 withHeight:(int)h2] : nil;
            if (db) { free(db); }
            if (t1) { free(t1); }
            if (t2) { free(t2); }

            CGFloat sc = MIN(1.0f, maxWidth / img.size.width);
            CGSize size = CGSizeMake(img.size.width * sc, img.size.height * sc);

            UILabel *lab = makeLabelAtY(title);
            [host addSubview:lab];
            y += 20.0f;
            UIImageView *iv = makeImageViewAtY(img, size);
            iv.frame = CGRectMake((host.bounds.size.width - size.width)/2.0f, y, size.width, size.height);
            [host addSubview:iv];
            y += size.height + 12.0f;

            lab = makeLabelAtY(@"Round-trip");
            [host addSubview:lab];
            y += 20.0f;
            iv = makeImageViewAtY(rt2, size);
            iv.frame = CGRectMake((host.bounds.size.width - size.width)/2.0f, y, size.width, size.height);
            [host addSubview:iv];
            y += size.height + 12.0f;

            NSString *t = [NSString stringWithFormat:@"Diff (abs RGBA) — count: %lu", (unsigned long)dc];
            lab = makeLabelAtY(t);
            [host addSubview:lab];
            y += 20.0f;
            if (dimg && dc > 0) {
                iv = makeImageViewAtY(dimg, size);
                iv.frame = CGRectMake((host.bounds.size.width - size.width)/2.0f, y, size.width, size.height);
                [host addSubview:iv];
                y += size.height + 12.0f;
            }
        };

        // Append triad for Icon4
        appendTriad(src, @"Original (Icon4)");

        // Optionally append Problem.png if present
        UIImage *problem = [UIImage imageNamed:@"Problem.png"];
        if (problem) {
            y += 24.0f; // spacing between sets
            appendTriad(problem, @"Original (Problem.png)");
        }

        // Auto-enumerate test_*.png/jpg/jpeg in bundle
        NSString *bundlePath = [[NSBundle mainBundle] resourcePath];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSDirectoryEnumerator *en = [fm enumeratorAtPath:bundlePath];
        NSString *relPath = nil;
        NSArray *exts = [NSArray arrayWithObjects:@"png", @"jpg", @"jpeg", nil];
        while ((relPath = [en nextObject])) {
            NSString *name = [relPath lastPathComponent];
            NSString *ext = [[name pathExtension] lowercaseString];
            if ([name hasPrefix:@"test_"] && [exts containsObject:ext]) {
                NSString *full = [bundlePath stringByAppendingPathComponent:relPath];
                UIImage *img = [UIImage imageWithContentsOfFile:full];
                if (img) {
                    y += 24.0f;
                    appendTriad(img, [NSString stringWithFormat:@"Original (%@)", name]);
                }
            }
        }

        // Update scrollable content size so nothing overlaps or clips
        if ([host isKindOfClass:[UIScrollView class]]) {
            UIScrollView *s = (UIScrollView *)host;
            s.contentSize = CGSizeMake(host.bounds.size.width, y + 40.0f);
        }
        }
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
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
