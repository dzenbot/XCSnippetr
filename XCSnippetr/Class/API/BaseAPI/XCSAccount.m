//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "XCSAccount.h"
#import "SLKAPIConstants.h"
#import "XCSMacros.h"

#import "NSObject+SmartDescription.h"

#import <SSKeychain/SSKeychain.h>

static NSString *kUserDefaultsAccounts = @"com.dzn.XCSnippetr.userdefaults.accounts";
static NSString *kUserDefaultsAccountId = @"com.dzn.XCSnippetr.userdefaults.accountId";

@interface XCSAccountManager : NSObject
@property (nonatomic, strong) NSMutableArray *accounts;
@property (nonatomic, copy) NSString *currentAccountId;
@end

@implementation XCSAccountManager

+ (instancetype)defaultManager
{
    static XCSAccountManager *_defaultManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultManager = [[XCSAccountManager alloc] init];
    });
    return _defaultManager;
}

- (NSMutableArray *)accounts
{
    if (!_accounts) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *encodedObject = [defaults objectForKey:kUserDefaultsAccounts];
        NSArray *values = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
        
        NSArray *array = [[NSSet setWithArray:values] allObjects];
        _accounts = [[NSMutableArray alloc] initWithArray:array];
    }
    
    if (!_accounts) {
        _accounts = [NSMutableArray new];;
    }
    
    return _accounts;
}

- (NSString *)currentAccountId
{
    if (!_currentAccountId) {
        _currentAccountId = [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsAccountId];
    }
    
    return _currentAccountId;
}

- (NSInteger)indexOfAccount:(XCSAccount *)account
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", NSStringFromSelector(@selector(accountId)), account.accountId];
    XCSAccount *anAccount = [[self.accounts filteredArrayUsingPredicate:predicate] firstObject];
    
    if (anAccount) {
        return [self.accounts indexOfObject:anAccount];
    }
    else {
        return NSNotFound;
    }
}

- (BOOL)save
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                
    if (_accounts) {
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:_accounts];
        [defaults setObject:encodedObject forKey:kUserDefaultsAccounts];
    }
    
    if (_currentAccountId) {
        [defaults setObject:_currentAccountId forKey:kUserDefaultsAccountId];
    }
    
    return [defaults synchronize];
}

- (BOOL)delete
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:kUserDefaultsAccounts];
    [defaults setObject:nil forKey:kUserDefaultsAccountId];
    return [defaults synchronize];
}

@end

@implementation XCSAccount

- (instancetype)initWithResponse:(NSDictionary *)response service:(XCSService)service
{
    if (!response) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _service = XCSServiceGithub;

        _teamName = response[kSlackAPIParamTeam];
        _teamId = response[kSlackAPIParamTeamId];
        _userName = response[kSlackAPIParamUser];
        _userId = response[kSlackAPIParamUserId];
    }
    return self;
}

+ (instancetype)currentAccount
{
    XCSAccountManager *manager = [XCSAccountManager defaultManager];
    
    if (!manager.accounts) {
        return nil;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", NSStringFromSelector(@selector(accountId)), manager.currentAccountId];
    return [[manager.accounts filteredArrayUsingPredicate:predicate] firstObject];
}


#pragma mark - Getters

+ (BOOL)forceLogin
{
    return ([XCSAccount allAccounts].count == 0) ? YES : NO;
}

+ (NSArray *)allAccounts
{
    return [XCSAccountManager defaultManager].accounts;
}

+ (NSArray *)teamNames
{
    XCSAccountManager *manager = [XCSAccountManager defaultManager];
    
    NSMutableArray *names = [[NSMutableArray alloc] initWithCapacity:manager.accounts.count];
    for (XCSAccount *account in manager.accounts) {
        if (account.teamName) {
            [names addObject:account.teamName];
        }
    }
    
    return names;
}

- (NSString *)accountId
{
    switch (self.service) {
        case XCSServiceSlack:
        {
            if (!isNonEmptyString(_teamId) || !isNonEmptyString(_userId)) {
                return nil;
            }
            
            return [NSString stringWithFormat:@"%@_%@", self.teamId, self.userId];
        }
        case XCSServiceGithub:
        {
            return self.userId;
        }
            
        default:
            break;
    }
    
    return nil;
}

- (BOOL)isCurrent
{
    if ([self.accountId isEqualToString:[XCSAccountManager defaultManager].currentAccountId]) {
        return YES;
    }
    return NO;
}


#pragma mark - Setters

- (void)setAccessToken:(NSString *)accessToken
{
    _accessToken = accessToken;
    [SSKeychain setPassword:accessToken forService:SLKBundleIdentifier() account:self.accountId];
}

- (void)setAsCurrent
{
    if (!isNonEmptyString(self.accountId)) {
        return;
    }
    
    [XCSAccountManager defaultManager].currentAccountId = self.accountId;
    
    [self save];
}

- (void)setChannelId:(NSString *)channelId
{
    if (!isNonEmptyString(self.accountId)) {
        return;
    }
    
    _channelId = channelId;
    
    [self save];
}


#pragma mark - Save/Remove

- (BOOL)save
{
    XCSAccountManager *manager = [XCSAccountManager defaultManager];
    
    if (!isNonEmptyString(_accessToken) || !isNonEmptyString(self.accountId)) {
        return NO;
    }
    
    NSInteger idx = [manager indexOfAccount:self];
    
    if (idx == NSNotFound) {
        [manager.accounts addObject:self];
    }
    else {
        [manager.accounts replaceObjectAtIndex:idx withObject:self];
    }
    
    return [manager save];
}

- (BOOL)clear
{
    XCSAccountManager *manager = [XCSAccountManager defaultManager];
    
    if (manager.accounts.count == 0) {
        return NO;
    }
   
    // Removes the token from the keychain
    [SSKeychain deletePasswordForService:SLKBundleIdentifier() account:self.accountId];
    
    NSInteger idx = [manager indexOfAccount:self];
    
    if (idx != NSNotFound) {
        
        if (manager.accounts.count > 1 && self.isCurrent) {
            // TODO: Set another account as current
        }
        
        [manager.accounts removeObjectAtIndex:idx];
    }
    
    return [manager save];
}

+ (BOOL)clearAll
{
    XCSAccountManager *manager = [XCSAccountManager defaultManager];

    if (manager.accounts.count == 0) {
        return NO;
    }
    
    // Removes all tokens from the keychain
    for (XCSAccount *account in manager.accounts) {
        [SSKeychain deletePasswordForService:SLKBundleIdentifier() account:account.accountId];
    }
    
    [manager.accounts removeAllObjects];
    
    return [manager delete];
}

- (NSString *)description
{
    return [self smartDescription];
}


#pragma mark - Save/Remove

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _accessToken = [SSKeychain passwordForService:SLKBundleIdentifier() account:self.accountId];
        _service = [[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(service))] integerValue];

        _teamId = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(teamId))];
        _teamName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(teamName))];
        _userId = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(userId))];
        _userName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(userName))];
        _channelId = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(channelId))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:@(self.service) forKey:NSStringFromSelector(@selector(service))];

    [aCoder encodeObject:self.teamId forKey:NSStringFromSelector(@selector(teamId))];
    [aCoder encodeObject:self.teamName forKey:NSStringFromSelector(@selector(teamName))];
    [aCoder encodeObject:self.userId forKey:NSStringFromSelector(@selector(userId))];
    [aCoder encodeObject:self.userName forKey:NSStringFromSelector(@selector(userName))];
    [aCoder encodeObject:self.channelId forKey:NSStringFromSelector(@selector(channelId))];
}

@end
