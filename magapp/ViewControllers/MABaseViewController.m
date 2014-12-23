//
//  MAMenuItem.h
//  megapp
//
//  Created by Viktor Kalinchuk on 10/22/14.
//  Copyright (c) 2014 Viktor Kalinchuk. All rights reserved.
//

#import "MABaseViewController.h"
#import "MASplitViewController.h"
#import "MABaseViewController_Protected.h"
#import "MAUtils.h"
#import "MASplitViewController.h"
#import "MAAppDelegate.h"
#import "UIButton+ButtonWithImage.h"
#import "MASoapRequest.h"

@interface MABaseViewController ()

@end

@implementation MABaseViewController

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.soapRequest = [[MASoapRequest alloc] initStandard];
    self.navigationController.navigationBar.translucent = NO;
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation-button-menu.png"] style:UIBarButtonItemStylePlain target:appDelegate().splitViewController action:@selector(openOrCloseMenu:)];
    self.navigationItem.leftBarButtonItem = item;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardOpened:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHided:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)addLogo {
    UIImageView *logoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:logoImage];
}

- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.soapRequest cancelRequests];
}

- (void)keyboardOpened:(NSNotification*)sender {
    NSValue *frame = sender.userInfo[UIKeyboardFrameBeginUserInfoKey];
    float height = MIN([frame CGRectValue].size.width, [frame CGRectValue].size.height);
    self.keyboardShown = YES;
    self.contentScroll.contentInset = UIEdgeInsetsMake(self.contentScroll.contentInset.top, self.contentScroll.contentInset.left, self.contentScroll.contentInset.bottom + height, self.contentScroll.contentInset.right);
}

- (void)keyboardHided:(NSNotification*)sender {
    NSValue *frame = sender.userInfo[UIKeyboardFrameBeginUserInfoKey];
    float height = MIN([frame CGRectValue].size.width, [frame CGRectValue].size.height);
    self.keyboardShown = NO;
    self.contentScroll.contentInset = UIEdgeInsetsMake(self.contentScroll.contentInset.top, self.contentScroll.contentInset.left, self.contentScroll.contentInset.bottom - height, self.contentScroll.contentInset.right);
}

@end
