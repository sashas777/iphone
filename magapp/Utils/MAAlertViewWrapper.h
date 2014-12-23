//
//  Created by Viktor Kalinchuk on 10/30/14.
//  Copyright (c) 2014 All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MAAlertViewWrapper : NSObject

// Set alert reusable if you want to use it more than once after creation. In this case, callback blocks wan't be nil-ed after using, so you must weakify self, capturing inside action handler
// Default value NO for alert and YES for action sheet
@property (nonatomic, assign, getter=isReusable) BOOL reusable;
@property (nonatomic, readonly) UIView *senderView;

+ (instancetype)alertWithTitle:(NSString*)title message:(NSString*)message;

+ (instancetype)actionSheetWithTitle:(NSString*)title message:(NSString*)message inView:(UIView*)view;

- (instancetype)initWithTitle:(NSString*)title message:(NSString*)message;

- (void)addActionWithTitle:(NSString*)title handler:(void (^)(id sender))handler;

- (void)addCancelActionWithTitle:(NSString*)title handler:(void (^)(id sender))handler;

- (void)show;

@end
