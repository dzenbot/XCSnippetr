//
//  XCSKit
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "XCSAccount.h"
#import "XCSMacros.h"

#import "XCSSlackConstants.h"
#import "XCSGithubConstants.h"

#import "NSObject+SmartDescription.h"

#import "SSKeychain.h"

#define kUserDefaults [NSUserDefaults standardUserDefaults]

static NSString *kUserDefaultsAccounts = @"com.dzn.XCSnippetr.userdefaults.accounts";
static NSString *kUserDefaultsAccountIds = @"com.dzn.XCSnippetr.userdefaults.accountIds";

@interface XCSAccountManager : NSObject
@property (nonatomic, strong) NSMutableArray *accounts;
@property (nonatomic, strong) NSMutableDictionary *currentAccountIds;
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
        id unarchiveObjects = [self unarchiveObjectsWithKey:kUserDefaultsAccounts];
        NSArray *array = [[NSSet setWithArray:unarchiveObjects] allObjects];
        
        _accounts = [[NSMutableArray alloc] initWithArray:array];
    }
    
    if (!_accounts) {
        _accounts = [NSMutableArray new];;
    }
    
    return _accounts;
}

- (NSMutableDictionary *)currentAccountIds
{
    if (!_currentAccountIds) {
        id unarchiveObjects = [self unarchiveObjectsWithKey:kUserDefaultsAccountIds];
        
        if (unarchiveObjects) {
            _currentAccountIds = [[NSMutableDictionary alloc] initWithDictionary:unarchiveObjects];
        }
    }
    
    if (!_currentAccountIds) {
        _currentAccountIds = [NSMutableDictionary new];
    }
    
    return _currentAccountIds;
}

- (id)unarchiveObjectsWithKey:(NSString *)key
{
    NSData *encodedObject = [kUserDefaults objectForKey:key];
    
    if (encodedObject) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    }
    else {
        return nil;
    }
}

- (NSString *)currentAccountIdForService:(XCSService)service
{
    NSString *serviceName = NSStringFromXCSService(service);
    NSString *currentAccountId = self.currentAccountIds[serviceName];
    
    if (isNonEmptyString(currentAccountId)) {
        return currentAccountId;
    }
    
    return nil;
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
    if (_accounts) {
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:_accounts];
        [kUserDefaults setObject:encodedObject forKey:kUserDefaultsAccounts];
    }
    
    if (_currentAccountIds) {
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:_currentAccountIds];
        [kUserDefaults setObject:encodedObject forKey:kUserDefaultsAccountIds];
    }
    
    return [kUserDefaults synchronize];
}

- (BOOL)delete
{
    [kUserDefaults setObject:nil forKey:kUserDefaultsAccounts];
    [kUserDefaults setObject:nil forKey:kUserDefaultsAccountIds];
    return [kUserDefaults synchronize];
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
        _service = service;

        if (service == XCSServiceSlack) {
            _teamName = response[kSlackAPIParamTeam];
            _teamId = response[kSlackAPIParamTeamId];
            _userName = response[kSlackAPIParamUser];
            _userId = response[kSlackAPIParamUserId];
        }
        else if (service == XCSServiceGithub) {
            _userName = response[kGithubAPIParamLogin];
            _userId = [response[kGithubAPIParamId] stringValue];
        }
    }
    return self;
}

+ (instancetype)currentAccountForService:(XCSService)service
{
    XCSAccountManager *manager = [XCSAccountManager defaultManager];
    
    NSArray *accounts = [self allAccountsForService:service];
    
    if (accounts.count == 0) {
        return nil;
    }
    
    NSString *currentAccountId = [manager currentAccountIdForService:service];

    if (isNonEmptyString(currentAccountId)) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", NSStringFromSelector(@selector(accountId)), currentAccountId];
        return [[accounts filteredArrayUsingPredicate:predicate] firstObject];
    }
    
    return nil;
}


#pragma mark - Getters

+ (BOOL)needsForcedLoginForService:(XCSService)service
{
    return ([XCSAccount allAccountsForService:service].count == 0) ? YES : NO;
}

+ (NSArray *)allAccountsForService:(XCSService)service
{
    NSArray *accounts = [XCSAccountManager defaultManager].accounts;
    return [accounts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"service == %ld", service]];
}

+ (NSArray *)accountNamesForService:(XCSService)service
{
    NSArray *accounts = [self allAccountsForService:service];
    
    NSMutableArray *names = [[NSMutableArray alloc] initWithCapacity:accounts.count];
    
    for (XCSAccount *account in accounts) {
        
        if (service == XCSServiceSlack) {
            if (account.teamName) [names addObject:account.teamName];
        }
        else if (service == XCSServiceGithub) {
            if (account.userName) [names addObject:account.userName];
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

- (BOOL)isCurrentForService:(XCSService)service
{
    NSString *currentAccountId = [[XCSAccountManager defaultManager] currentAccountIdForService:service];

    if ([self.accountId isEqualToString:currentAccountId]) {
        return YES;
    }
    return NO;
}


#pragma mark - Setters

- (void)setAccessToken:(NSString *)accessToken
{
    _accessToken = accessToken;
    
    [SSKeychain setPassword:accessToken forService:XCSBundleIdentifier() account:self.accountId];
}

- (void)setAsCurrentForService:(XCSService)service
{
    if (!isNonEmptyString(self.accountId)) {
        return;
    }
    
    NSString *serviceName = NSStringFromXCSService(service);
    [[XCSAccountManager defaultManager].currentAccountIds setObject:self.accountId forKey:serviceName];
    
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
    [SSKeychain deletePasswordForService:XCSBundleIdentifier() account:self.accountId];
    
    NSInteger idx = [manager indexOfAccount:self];
    
    if (idx != NSNotFound) {
        
        if (manager.accounts.count > 1 && [self isCurrentForService:self.service]) {
            // TODO: Set another account as current
        }
        
        [manager.accounts removeObjectAtIndex:idx];
    }
    
    return [manager save];
}

+ (BOOL)clearForService:(XCSService)service
{
    NSArray *accounts = [self allAccountsForService:service];
    
    XCSAccountManager *manager = [XCSAccountManager defaultManager];
    
    if (manager.accounts.count == 0) {
        return NO;
    }
    
    // Removes all tokens from the keychain
    for (XCSAccount *account in accounts) {
        [SSKeychain deletePasswordForService:XCSBundleIdentifier() account:account.accountId];
        
        [account clear];
    }
    
    return YES;
}

+ (BOOL)clearAll
{
    XCSAccountManager *manager = [XCSAccountManager defaultManager];

    if (manager.accounts.count == 0) {
        return NO;
    }
    
    // Removes all tokens from the keychain
    for (XCSAccount *account in manager.accounts) {
        [SSKeychain deletePasswordForService:XCSBundleIdentifier() account:account.accountId];
    }
    
    [manager.accounts removeAllObjects];
    
    return [manager delete];
}


#pragma mark - NSObject

- (NSString *)description
{
    return [self smartDescription];
}


#pragma mark - Save/Remove

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _service = [[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(service))] integerValue];
        _serviceName = NSStringFromXCSService(_service);
        
        _teamId = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(teamId))];
        _teamName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(teamName))];
        _userId = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(userId))];
        _userName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(userName))];
        _channelId = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(channelId))];
        
        _accessToken = [SSKeychain passwordForService:XCSBundleIdentifier() account:self.accountId];
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
