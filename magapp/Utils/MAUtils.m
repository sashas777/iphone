//
//  MAMenuItem.h
//  megapp
//
//  Created by Viktor Kalinchuk on 10/22/14.
//  Copyright (c) 2014 Viktor Kalinchuk. All rights reserved.
//

#import "MAAppDelegate.h"
#import "MASplitViewController.h"
#import "MAUtils.h"
#import "MAAlertViewWrapper.h"

MASplitViewController* splitViewController() {
    return appDelegate().splitViewController;
}

MAAppDelegate* appDelegate() {
    return (MAAppDelegate*)[UIApplication sharedApplication].delegate;
}

float statusBarHeight() {
    return [[UIApplication sharedApplication] statusBarFrame].size.height;
}

BOOL checkURL(NSString *url) {
#warning TODO improve regex
    NSString *urlRegEx = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:url];
}

@implementation MAUtils

+ (void)showInfoAlertWithText:(NSString*)text {
    [MAUtils showInfoAlertWithText:text handler:nil];
}

+ (void)showInfoAlertWithText:(NSString*)text handler:(void (^)(id sender))handler {
    MAAlertViewWrapper *alert = [MAAlertViewWrapper alertWithTitle:@"" message:text];
    [alert addActionWithTitle:NSLocalizedString(@"Ok", nil) handler:handler];
    [alert show];
}

+ (void)showInfoAlertWithError:(NSError*)error handler:(void (^)(id sender))handler {
    MAAlertViewWrapper *alert = [MAAlertViewWrapper alertWithTitle:NSLocalizedString(@"Error", nil) message:error.userInfo[@"message"]];
    [alert addActionWithTitle:NSLocalizedString(@"Ok", nil) handler:handler];
    [alert show];
}

+ (void)showInfoAlertWithError:(NSError*)error {
    [MAUtils showInfoAlertWithError:error handler:nil];
}

@end
