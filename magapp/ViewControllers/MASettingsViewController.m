//
//  MASettingsViewController.m
//  magapp
//
//  Created by Viktor Kalinchuk on 12/26/14.
//  Copyright (c) 2014 Viktor Kalinchuk. All rights reserved.
//

#import "MASettingsViewController.h"
#import "MAAccounts.h"
#import "MAAccountsViewController.h"

@interface MASettingsViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UILabel *enableNotificationsLabel;
@property (nonatomic, weak) IBOutlet UILabel *currentAccountLabel;
@property (nonatomic, weak) IBOutlet UISwitch *notificationsSwitch;
@property (nonatomic, weak) IBOutlet UITextField *currentAccountField;

- (IBAction)onSwitch:(id)sender;

@end

@implementation MASettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Settings", nil);
    self.enableNotificationsLabel.text = NSLocalizedString(@"Enable notifications", nil);
    self.currentAccountLabel.text = NSLocalizedString(@"Current account", nil);
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.currentAccountField.text = [MAAccounts sharedStorage].currentAccount.accountName;
    self.notificationsSwitch.on = [MAAccounts sharedStorage].currentAccount.enableNotifications;
}

#pragma mark - Actions

- (void)onSwitch:(UISwitch*)sender {
    [MAAccounts sharedStorage].currentAccount.enableNotifications = sender.on;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    MAAccountsViewController *ac = [[MAAccountsViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:ac animated:YES];
    return NO;
}

@end
