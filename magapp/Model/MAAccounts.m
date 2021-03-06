//
//  MAAccounts.m
//  magapp
//
//  Created by Viktor Kalinchuk on 10/24/14.
//  Copyright (c) 2014 Viktor Kalinchuk. All rights reserved.
//

#import "MAAccounts.h"
#import "SSKeychain.h"

@implementation MAAccount

NSString * const kAFOAuth1CredentialServiceName = @"AFOAuthCredentialService";

- (void)saveSession {
    [SSKeychain setPassword:self.sessionID forService:self.storeURL account:self.accountName];
}

#warning TODO call endSession API method on deleting saved
- (void)deleteSavedSession {
    [SSKeychain deletePasswordForService:self.storeURL account:self.accountName];
}

- (void)loadSavedSession {
    self.sessionID = [SSKeychain passwordForService:self.storeURL account:self.accountName];
}

+ (instancetype)accountWithName:(NSString*)name storeURL:(NSString*)storeURL sessionID:(NSString*)sessionID username:(NSString *)username {
    MAAccount *account = [[MAAccount alloc] init];
    account.accountName = name;
    account.storeURL = storeURL;
    account.sessionID = sessionID;
    account.username = username;
    account.enableNotifications = YES;
    return account;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.storeURL forKey:NSStringFromSelector(@selector(storeURL))];
    [aCoder encodeObject:self.accountName forKey:NSStringFromSelector(@selector(accountName))];
    [aCoder encodeObject:self.username forKey:NSStringFromSelector(@selector(username))];
    [aCoder encodeBool:self.enableNotifications forKey:NSStringFromSelector(@selector(enableNotifications))];
    [self saveSession];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [self init]) {
        self.storeURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(storeURL))];
        self.accountName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(accountName))];
        self.username = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(username))];
        self.enableNotifications = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(enableNotifications))];
        [self loadSavedSession];
    }
    return self;
}

@end

@interface MAAccounts ()

@property (nonatomic, strong) NSMutableArray *mutableAccounts;

@end

@implementation MAAccounts

static MAAccounts *sharedInstance;

+ (MAAccounts *)sharedStorage {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *encodedObject = [defaults objectForKey:NSStringFromClass([self class])];
        if (encodedObject) {
            sharedInstance = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
        } else {
            sharedInstance = [[MAAccounts alloc] init];
        }
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.mutableAccounts = [[NSMutableArray alloc] init];
        self.currentAccountIndex = 0;
    }
    return self;
}

- (BOOL)hasAccounts {
    return self.mutableAccounts.count > 0;
}

- (NSArray *)accounts {
    return self.mutableAccounts;
}

- (void)saveAccounts {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:NSStringFromClass([self class])];
    [defaults synchronize];
}

- (void)setCurrentAccountIndex:(NSInteger)currentAccountIndex {
   [self.currentAccount deleteSavedSession];
    _currentAccountIndex = currentAccountIndex;
}

- (MAAccount *)currentAccount {
    MAAccount *account = nil;
    if (self.currentAccountIndex < self.mutableAccounts.count) {
        account = self.mutableAccounts[self.currentAccountIndex];
    }
    return account;
}

- (void)addAccountWithName:(NSString*)name storeURL:(NSString*)storeURL sessionID:(NSString*)sessionID username:(NSString *)username {
    [self.mutableAccounts addObject:[MAAccount accountWithName:name storeURL:storeURL sessionID:sessionID username:username]];
}

- (void)deleteAccountWithIndex:(NSInteger)index {
    [self.mutableAccounts removeObjectAtIndex:index];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.mutableAccounts forKey:NSStringFromSelector(@selector(mutableAccounts))];
    [aCoder encodeInteger:self.currentAccountIndex forKey:NSStringFromSelector(@selector(currentAccountIndex))];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [self init]) {
        self.mutableAccounts = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(mutableAccounts))];
        self.currentAccountIndex = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(currentAccountIndex))];
    }
    return self;
}

@end
