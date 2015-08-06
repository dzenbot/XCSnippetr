//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "GHBAPIClient.h"
#import "GHBAPIConstants.h"

#import "XCSMacros.h"

#import "XCSSnippet.h"
#import "XCSAccount.h"

#import "NSString+RequestSerialization.h"

@implementation GHBAPIClient

#pragma mark - XCSServiceAPIProtocol

- (NSMutableURLRequest *)requestfForPath:(NSString *)path andParams:(NSDictionary *)params
{
    NSMutableDictionary *parameters = [params mutableCopy];
    
    XCSAccount *currentAccount = [XCSAccount currentAccountForService:XCSServiceGithub];
    NSString *accessToken = currentAccount.accessToken;
    
    if (accessToken && ![parameters.allKeys containsObject:kGithubAPIParamAccessToken]) {
        [parameters setObject:accessToken forKey:kGithubAPIParamAccessToken];
    }
    
    NSString *url = [[NSString stringWithFormat:@"%@%@", kGithubAPIBaseUrl, path] stringByAppendingRequestParameters:parameters];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];

    if ([path isEqualToString:kGithubAPIMethodGists]) {
        NSDictionary *JSON = @{kGithubAPIParamFiles: parameters[kGithubAPIParamFiles]};
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:JSON options:0 error:nil];
    }
    
    return request;
}

- (NSString *)errorResponseKey
{
    return kGithubAPIParamErrorMessage;
}

- (void)authWithToken:(NSString *)token completion:(void (^)(XCSAccount *account, NSError *error))completion
{
    if (!isNonEmptyString(token)) {
        return;
    }
    
    NSDictionary *params = @{kGithubAPIParamAccessToken: token};
    
    [self GET:kGithubAPIMethodUser params:params completion:^(id response, NSError *error) {
        
        XCSAccount *account = nil;
        
        if (!error) {
            account = [[XCSAccount alloc] initWithResponse:response service:XCSServiceGithub];
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
    
    NSDictionary *params = [snippet paramsForService:XCSServiceGithub];
    NSString *path = kGithubAPIMethodGists;
    
    [self POST:path params:params completion:^(NSDictionary *JSON, NSError *error) {
        if (!error) {
            snippet.URL = [NSURL URLWithString:[JSON objectForKey:@"html_url"]];
        }
        
        if (completion) {
            completion(JSON, error);
        }
    }];
}

@end
