//
//  MAAccounts.h
//  magapp
//
//  Created by Viktor Kalinchuk on 10/24/14.
//  Copyright (c) 2014 Viktor Kalinchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MAAccount : NSObject <NSCoding>

+ (instancetype)accountWithName:(NSString*)name storeURL:(NSString*)storeURL sessionID:(NSString*)sessionID;
- (void)saveSession;
- (void)deleteSaved;
- (void)loadSavedSession;

@property (nonatomic, strong) NSString *storeURL;
@property (nonatomic, strong) NSString *accountName;
@property (nonatomic, strong) NSString *sessionID;

@end

@interface MAAccounts : NSObject <NSCoding>

+ (MAAccounts*)sharedStorage;

- (BOOL)hasAccounts;
- (void)saveAccounts;

@property (nonatomic, readonly) NSArray *accounts;
@property (nonatomic, assign) NSInteger currentAccountIndex;
@property (nonatomic, readonly) MAAccount *currentAccount;

- (void)addAccountWithName:(NSString*)name storeURL:(NSString*)storeURL sessionID:(NSString*)sessionID;
- (void)deleteAccountWithIndex:(NSInteger)index;

@end
