//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "SLKAPIClient.h"

#import "XCSAccount.h"
#import "XCSSnippet.h"
#import "SLKRoom.h"
#import "XCSMacros.h"

#import "NSString+RequestSerialization.h"

@implementation SLKAPIClient

#pragma mark - XCSServiceAPIProtocol

- (NSMutableURLRequest *)requestfForPath:(NSString *)path andParams:(NSDictionary *)params
{
    NSMutableDictionary *parameters = [params mutableCopy];
    
    NSString *accessToken = [XCSAccount currentAccountForService:XCSServiceSlack].accessToken;
    
    if (accessToken && ![parameters.allKeys containsObject:kSlackAPIParamToken]) {
        [parameters setObject:accessToken forKey:kSlackAPIParamToken];
    }
    
    NSString *url = [[NSString stringWithFormat:@"%@%@", kSlackAPIBaseUrl, path] stringByAppendingRequestParameters:parameters];
    
    return [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
}

- (NSString *)errorResponseKey
{
    return kSlackAPIParamError;
}

- (void)authWithToken:(NSString *)token completion:(void (^)(XCSAccount *account, NSError *error))completion
{
    if (!isNonEmptyString(token)) {
        return;
    }
    
    NSDictionary *params = @{kSlackAPIParamToken: token};
    
    [self POST:kSlackAPIMethodAuthTest params:params completion:^(id response, NSError *error) {
        
        XCSAccount *account = nil;
        
        if (!error) {
            account = [[XCSAccount alloc] initWithResponse:response service:XCSServiceSlack];
            account.accessToken = token;
        }
        
        if (completion) {
            completion(account, error);
        }
    }];
}

- (void)uploadSnippet:(XCSSnippet *)snippet completion:(void (^)(NSDictionary *JSON, NSError *error))completion
{
    if (!snippet) {
        return;
    }
    
    NSDictionary *params = [snippet paramsForService:XCSServiceSlack];
    NSString *path = snippet.uploadAsSnippet ? kSlackAPIMethodFilesUpload : kSlackAPIMethodChatPostMessage;
    
    [self POST:path params:params completion:^(NSDictionary *JSON, NSError *error) {
        if (!error) {
            snippet.URL = [NSURL URLWithString:[JSON valueForKeyPath:@"file.url"]];
        }
        
        if (completion) {
            completion(JSON, error);
        }
    }];
}


#pragma mark - SLKAPIClient

- (void)getAvailableRooms:(void (^)(NSDictionary *rooms, NSError *error))completion
{
    XCSAccount *account = [XCSAccount currentAccountForService:XCSServiceSlack];
    NSString *teamId = account.teamId;
    
    if (!isNonEmptyString(teamId)) {
        return;
    }
    
    NSDictionary *params = @{kSlackAPIParamTeam: teamId};
    
    [self POST:kSlackAPIMethodRTMStart params:params completion:^(id response, NSError *error) {
        
        if (completion) {
            completion([SLKRoom roomsFromResponse:response], error);
        }
    }];
}


@end
