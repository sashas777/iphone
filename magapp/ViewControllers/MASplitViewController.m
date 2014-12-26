//
//  MAMenuItem.h
//  megapp
//
//  Created by Viktor Kalinchuk on 10/22/14.
//  Copyright (c) 2014 Viktor Kalinchuk. All rights reserved.
//

#import "MASplitViewController.h"
#import "MAControlsViewController.h"
#import "MAMenuItem.h"
#import "MAAppDelegate.h"
#import "MARootViewController.h"
#import "MAAccounts.h"
#import "MAHomeViewController.h"
#import "MASalesViewController.h"
#import "MASettingsViewController.h"
#import "MAAddAccountViewController.h"

@interface MASplitViewController () <MAControlsViewControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UINavigationController *currentViewController;
@property (nonatomic, strong) NSMutableDictionary *viewControllers;
@property (nonatomic, strong) MAControlsViewController *controlsViewController;
@property (nonatomic, strong) NSMutableArray *menuItems;

@property (nonatomic, assign) BOOL menuOpened;
@property (nonatomic, strong) UISwipeGestureRecognizer *menuOpeningGesture;

@end

@implementation MASplitViewController

- (UINavigationController*)initalizedControllerWithCreateBlock:(MABaseViewController* (^) ())createBlock {
    MABaseViewController *vc = createBlock();
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = NO;
    nav.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self addChildViewController:nav];
    return nav;
}

- (float)heightForNavigationBar {
    return self.navigationController.navigationBar.frame.size.height;
}

- (id)init {
    if (self = [super init]) {
        self.controlsViewController = [[MAControlsViewController alloc] initWithNibName:nil bundle:nil];
        self.controlsViewController.delegate = self;
        self.viewControllers = [[NSMutableDictionary alloc] init];
        self.menuItems = [[NSMutableArray alloc] init];
        [self.menuItems addObject:[MAMenuItem itemWithName:NSLocalizedString(@"Home", nil)]];
        [self.menuItems addObject:[MAMenuItem itemWithName:NSLocalizedString(@"Sales", nil)]];
        [self.menuItems addObject:[MAMenuItem itemWithName:NSLocalizedString(@"Settings", nil)]];
        [self.viewControllers setObject:[self initalizedControllerWithCreateBlock:^MABaseViewController *{
            return [[MAHomeViewController alloc] initWithNibName:nil bundle:nil];
        }] forKey:@0];
        [self.viewControllers setObject:[self initalizedControllerWithCreateBlock:^MABaseViewController *{
            return [[MASalesViewController alloc] initWithNibName:nil bundle:nil];
        }] forKey:@1];
        [self.viewControllers setObject:[self initalizedControllerWithCreateBlock:^MABaseViewController *{
            return [[MASettingsViewController alloc] initWithNibName:nil bundle:nil];
        }] forKey:@2];
        self.menuOpened = NO;
    }
    return self;
}

#define MIN_MENU_WIDTH                  228.f

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.view.layer.shadowOffset = CGSizeMake(-1.f, 0.f);
    self.navigationController.view.layer.shadowOpacity = 0.8f;
    self.navigationController.navigationBarHidden = YES;
    self.menuOpeningGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(openOrCloseMenu:)];
    self.menuOpeningGesture.delegate = self;
    self.menuOpeningGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:self.menuOpeningGesture];
    self.contentView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    float calculated = MAX(self.view.frame.size.width, self.view.frame.size.height) * 0.38f;
    float optimizedWidth = MAX(calculated, MIN_MENU_WIDTH);
    self.controlsViewController.view.frame = CGRectMake(0.f, 0.f, optimizedWidth, self.view.bounds.size.height);
    self.controlsViewController.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
    [appDelegate().theRootestViewController.view insertSubview:self.controlsViewController.view atIndex:0];
    [self.view addSubview:self.contentView];
    [appDelegate().theRootestViewController addChildViewController:self.controlsViewController];
    [self addChildControllerWithNumber:0];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // ------- User must add at least one account
    if (![MAAccounts sharedStorage].hasAccounts) {
        MAAddAccountViewController *ac = [[MAAddAccountViewController alloc] initWithNibName:nil bundle:nil];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ac];
        [self.navigationController presentViewController:nav animated:NO completion:nil];
    }
}

- (void)openOrCloseMenu:(id)sender {
    CGPoint center = self.menuOpened ? CGPointMake(self.view.frame.size.width * 0.5f, self.navigationController.view.center.y) : CGPointMake(self.controlsViewController.view.frame.size.width + self.view.frame.size.width * 0.5f, self.controlsViewController.view.center.y);
    self.menuOpened = !self.menuOpened;
    self.menuOpeningGesture.enabled = !self.menuOpened;
    self.contentView.userInteractionEnabled = !self.menuOpened;
    [UIView animateWithDuration:0.3f animations:^{
        self.navigationController.view.center = center;
    } completion:^(BOOL finished) {}];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    if (self.menuOpened) {
        [self openOrCloseMenu:nil];
    }
}

- (void)addChildControllerWithNumber:(NSUInteger)number {
    UINavigationController *controller = self.viewControllers[[NSNumber numberWithInteger:number]];
    [self.currentViewController.view removeFromSuperview];
    self.currentViewController = controller;
    controller.view.frame = self.view.bounds;
    [self.contentView insertSubview:self.currentViewController.view atIndex:0];
}

#pragma mark MAControlsViewControllerDelegate

- (void)controlsMenu:(MAControlsViewController*)sender didSelectedItemAtIndex:(NSUInteger)index {
    [self addChildControllerWithNumber:index];
    [self.currentViewController popToRootViewControllerAnimated:NO];
    [self openOrCloseMenu:nil];
}

- (NSArray*)itemsForMenu {
    return self.menuItems;
}

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

@end
