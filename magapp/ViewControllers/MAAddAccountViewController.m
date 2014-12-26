//
//  MAAddAccountViewController.m
//  magapp
//
//  Created by Viktor Kalinchuk on 10/24/14.
//  Copyright (c) 2014 Viktor Kalinchuk. All rights reserved.
//

#import "MAAddAccountViewController.h"
#import "MAAccounts.h"
#import "MBProgressHUD.h"
#import "MABaseViewController_Protected.h"
#import "MASoapRequest.h"

#define FIRST_FIELD_TAG         10

@interface MAAddAccountViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *accountField;
@property (nonatomic, weak) IBOutlet UITextField *storeURLField;
@property (nonatomic, weak) IBOutlet UITextField *usernameField;
@property (nonatomic, weak) IBOutlet UITextField *APIKeyField;

@property (nonatomic, weak) IBOutlet UILabel *accountLabel;
@property (nonatomic, weak) IBOutlet UILabel *storeURLLabel;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *APIKeyLabel;
@property (nonatomic, weak) IBOutlet UILabel *infoLabel;

@property (nonatomic, strong) UISwipeGestureRecognizer *cancelSwipe;
@property (nonatomic, strong) NSArray *responders;

@property (nonatomic, strong) MBProgressHUD *progressHUD;

- (IBAction)onSymbolEntered:(UITextField*)sender;

@end

@implementation MAAddAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Account", nil);
    self.progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.progressHUD];
    self.contentScroll.scrollsToTop = NO;
    self.cancelSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cancel:)];
    self.cancelSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:self.cancelSwipe];
    self.responders = @[self.accountField, self.storeURLField, self.usernameField, self.APIKeyField];
    self.storeURLField.text = @"http://";
    self.storeURLField.text = @"http://extensions.sashas.org";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", nil) style:UIBarButtonItemStylePlain target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
// -- setup localization
    self.infoLabel.text = NSLocalizedString(@"Please, fill out magento account information below", nil);
    self.accountLabel.text = [NSLocalizedString(@"Account Name", nil) lowercaseString];
    self.accountField.placeholder = NSLocalizedString(@"Account Name", nil);
    self.storeURLLabel.text = [NSLocalizedString(@"Store URL", nil) lowercaseString];
    self.usernameLabel.text = [NSLocalizedString(@"Username", nil) lowercaseString];
    self.usernameField.placeholder = NSLocalizedString(@"Username", nil);
    self.APIKeyLabel.text = [NSLocalizedString(@"API Key", nil) lowercaseString];
    self.APIKeyField.placeholder = NSLocalizedString(@"API Key", nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)areFieldsFilled {
    BOOL result = YES;
    for (UITextField *field in self.responders) {
        result = field.text.length != 0;
        if (!result) break;
    }
    return result;
}

- (UITextField*)findNextResponder:(UITextField*)currentResponder {
    UITextField *next = nil;
    NSInteger maxI = currentResponder.tag - FIRST_FIELD_TAG + self.responders.count;
    for (NSInteger i = currentResponder.tag - FIRST_FIELD_TAG; i < maxI; i++) {
        NSInteger index = i >= self.responders.count ? i - self.responders.count : i;
        UITextField *field = self.responders[index];
        if ((field != currentResponder && field.text.length == 0) ||
            (field != currentResponder && field == self.storeURLField && !checkURL(self.storeURLField.text))) {
            next = field;
            break;
        }
    }
    return next;
}

- (void)cancel:(id)sender {
    if ([MAAccounts sharedStorage].hasAccounts) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        if (self.soapRequest.hasRequests) {
            [self.soapRequest cancelRequests];
        } else {
            [MAUtils showInfoAlertWithText:NSLocalizedString(@"You must add at least one account to use the application", nil)];
        }
    }
}

- (void)save:(id)sender {
    [self.view endEditing:YES];
    [self.progressHUD show:YES];
    [self.soapRequest loginWithUsername:self.usernameField.text pass:self.APIKeyField.text URLString:self.storeURLField.text completionHandler:^(AFHTTPRequestOperation *request, NSString *sessionID) {
        __weak MAAddAccountViewController *weakSelf = self;
        [[MAAccounts sharedStorage] addAccountWithName:self.accountField.text storeURL:self.storeURLField.text sessionID:sessionID username:self.usernameField.text];
        [MAAccounts sharedStorage].currentAccountIndex = [MAAccounts sharedStorage].accounts.count - 1;
        [[MAAccounts sharedStorage] saveAccounts];
        [MAUtils showInfoAlertWithText:NSLocalizedString(@"Account was successfully added", nil) handler:^(id sender) {
            [weakSelf cancel:nil];
        }];
    } error:^(NSError *error, id responseData) {
        [MAUtils showInfoAlertWithError:error];
    } finally:^(id responseData) {
        [self.progressHUD hide:YES];
    }];
}

- (BOOL)validateTextField:(UITextField*)textField {
    BOOL result = NO;
    if (textField == self.storeURLField) {
        result = checkURL(textField.text);
    } else {
        result = textField.text.length > 0;
    }
    return result;
}

- (void)onSymbolEntered:(UITextField *)sender {
    self.navigationItem.rightBarButtonItem.enabled = [self findNextResponder:sender] == nil && [self validateTextField:sender];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (![self findNextResponder:textField]) {
        textField.returnKeyType = UIReturnKeySend;
    } else {
        textField.returnKeyType = UIReturnKeyNext;
    }
    return YES;
}

#define HTTP_PREFIX_LENGTH              7

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL result = YES;
    if (textField == self.storeURLField) {
        if (range.location < HTTP_PREFIX_LENGTH) {
            result = NO;
        }
    }
    return result;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    UITextField *nextResponder = [self findNextResponder:textField];
    if (nextResponder) {
        [nextResponder becomeFirstResponder];
    } else {
        if ([self validateTextField:textField]) {
            [self save:textField];
        } else {
            [MAUtils showInfoAlertWithText:NSLocalizedString(@"You have input incorrect URL", nil)];
        }
    }
    return NO;
}

@end
