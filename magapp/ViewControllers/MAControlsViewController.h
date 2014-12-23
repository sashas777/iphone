//
//  MAMenuItem.h
//  megapp
//
//  Created by Viktor Kalinchuk on 10/22/14.
//  Copyright (c) 2014 Viktor Kalinchuk. All rights reserved.
//

#import "MABaseViewController.h"

@class MAControlsViewController;
@class MAMenuItem;

@protocol MAControlsViewControllerDelegate <NSObject>

- (void)controlsMenu:(MAControlsViewController*)sender didSelectedItemAtIndex:(NSUInteger)index;
- (NSArray*)itemsForMenu;

@end

@interface MAControlsViewController : MABaseViewController

@property (nonatomic, weak) id <MAControlsViewControllerDelegate> delegate;

- (void)reload;
- (void)setItemSelected:(NSInteger)index notifyDelegate:(BOOL)shouldNotifyDelegate;

@end
