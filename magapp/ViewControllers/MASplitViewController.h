//
//  MAMenuItem.h
//  megapp
//
//  Created by Viktor Kalinchuk on 10/22/14.
//  Copyright (c) 2014 Viktor Kalinchuk. All rights reserved.
//

#import "MABaseViewController.h"

@interface MASplitViewController : MABaseViewController

- (float)heightForNavigationBar;
- (void)openOrCloseMenu:(id)sender;

@property (nonatomic, readonly) BOOL menuOpened;
@property (nonatomic, readonly) UINavigationController *currentViewController;

@end
