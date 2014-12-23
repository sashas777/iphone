//
//  MAMenuItem.h
//  megapp
//
//  Created by Viktor Kalinchuk on 10/22/14.
//  Copyright (c) 2014 Viktor Kalinchuk. All rights reserved.
//

#import "MABaseViewController.h"

@interface MABaseViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *contentScroll;
@property (nonatomic, assign, getter=isKeyboardShown) BOOL keyboardShown;

- (void)back:(id)sender;
- (void)addLogo;

@end

