//
//  MAMenuItem.h
//  megapp
//
//  Created by Viktor Kalinchuk on 10/22/14.
//  Copyright (c) 2014 Viktor Kalinchuk. All rights reserved.
//

@class MASplitViewController;
@class MAAppDelegate;

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define RM_THEME_COLOR              UIColorFromRGB(0xd33837)

MASplitViewController* splitViewController();
MAAppDelegate* appDelegate();
float statusBarHeight();
BOOL checkURL(NSString *url);

@interface MAUtils : NSObject

+ (void)showInfoAlertWithText:(NSString*)text;
+ (void)showInfoAlertWithText:(NSString*)text handler:(void (^)(id sender))handler;
+ (void)showInfoAlertWithError:(NSError*)error;
+ (void)showInfoAlertWithError:(NSError*)error handler:(void (^)(id sender))handler;

@end