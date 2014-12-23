//
//  Created by Viktor Kalinchuk on 10/30/14.
//  Copyright (c) 2014  All rights reserved.
//

#import "MAAlertViewWrapper.h"
#import <objc/runtime.h>

typedef void (^AlertAction)(id sender);

@interface SPAlertAction : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, copy) AlertAction handler;
@property (nonatomic, assign, getter=isCancel) BOOL cancel;

+ (instancetype)actionWithTitle:(NSString*)title handler:(AlertAction)handler;

- (UIAlertAction*)alertAction;

@end

@implementation SPAlertAction

+ (instancetype)actionWithTitle:(NSString*)title handler:(AlertAction)handler {
    SPAlertAction *action = [[SPAlertAction alloc] init];
    action.title = title;
    action.handler = handler;
    action.cancel = NO;
    return action;
}

- (UIAlertAction *)alertAction {
    UIAlertActionStyle style = self.cancel ? UIAlertActionStyleCancel : UIAlertActionStyleDefault;
    return [UIAlertAction actionWithTitle:self.title style:style handler:self.handler];
}

@end

typedef NS_ENUM(NSInteger, SPAlertControllerStyle) {
    SPAlertControllerStyleActionSheet = 0,
    SPAlertControllerStyleAlert
};

@interface MAAlertViewWrapper () <UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSMutableArray *actions;
@property (nonatomic, strong) UIView *senderView;
@property (nonatomic, assign) SPAlertControllerStyle style;

@end

@implementation MAAlertViewWrapper

+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message {
    return [[MAAlertViewWrapper alloc] initWithTitle:title message:message];
}

+ (instancetype)actionSheetWithTitle:(NSString*)title message:(NSString*)message inView:(UIView *)view {
    MAAlertViewWrapper *alert = [[MAAlertViewWrapper alloc] initWithTitle:title message:message];
    alert.style = SPAlertControllerStyleActionSheet;
    alert.reusable = YES;
    alert.senderView = view;
    return alert;
}

- (instancetype)initWithTitle:(NSString*)title message:(NSString*)message {
    if (self = [super init]) {
        self.title = title;
        self.message = message;
        self.actions = [NSMutableArray array];
        self.style = SPAlertControllerStyleAlert;
        self.reusable = NO;
    }
    return self;
}

- (void)addActionWithTitle:(NSString*)title handler:(void (^)(id sender))handler {
    [self.actions addObject:[SPAlertAction actionWithTitle:title handler:handler]];
}

- (void)addCancelActionWithTitle:(NSString*)title handler:(void (^)(id sender))handler {
    SPAlertAction *action = [SPAlertAction actionWithTitle:title handler:handler];
    action.cancel = YES;
    [self.actions insertObject:action atIndex:0];
}

static const char kSPAlertWrapper;

- (void)show {
    if (NSClassFromString(@"UIAlertController") != Nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.title message:self.message preferredStyle:(UIAlertControllerStyle)self.style];
        for (int i = 0; i < self.actions.count; i++) {
            SPAlertAction *action = self.actions[i];
            [alert addAction:[action alertAction]];
        }
        UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (root.presentedViewController) {
            root = root.presentedViewController;
        }
        UIPopoverPresentationController *popover = alert.popoverPresentationController;
        if (popover) {
            popover.sourceView = self.senderView;
            popover.sourceRect = self.senderView.bounds;
            popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
        [root presentViewController:alert animated:YES completion:nil];
    } else {
        switch (self.style) {
            case SPAlertControllerStyleActionSheet: {
                SPAlertAction *cancel = self.actions[0];
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:self.title delegate:self cancelButtonTitle:cancel.title destructiveButtonTitle:nil otherButtonTitles:nil];
                for (int i = 1; i < self.actions.count; i++) {
                    SPAlertAction *action = self.actions[i];
                    [actionSheet addButtonWithTitle:action.title];
                }
                objc_setAssociatedObject(actionSheet, &kSPAlertWrapper, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
            }
                break;
            case SPAlertControllerStyleAlert: {
                SPAlertAction *cancel = self.actions[0];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.title message:self.message delegate:self cancelButtonTitle:cancel.title otherButtonTitles:nil];
                for (int i = 1; i < self.actions.count; i++) {
                    SPAlertAction *action = self.actions[i];
                    [alert addButtonWithTitle:action.title];
                }
                objc_setAssociatedObject(alert, &kSPAlertWrapper, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                [alert show];
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    SPAlertAction *action = self.actions[buttonIndex];
    if (action.handler) {
        action.handler(action);
        if (!self.reusable) {
            action.handler = nil;
        }
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView {
    SPAlertAction *action = self.actions[alertView.cancelButtonIndex];
    if (action.handler) {
        action.handler(action);
        if (!self.reusable) {
            action.handler = nil;
        }
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    SPAlertAction *action = self.actions[buttonIndex];
    if (action.handler) {
        action.handler(action);
        if (!self.reusable) {
            action.handler = nil;
        }
    }
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
    SPAlertAction *action = self.actions[actionSheet.cancelButtonIndex];
    if (action.handler) {
        action.handler(action);
        if (!self.reusable) {
            action.handler = nil;
        }
    }
}

@end
