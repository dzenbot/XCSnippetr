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

@implementation GHBAPIClient

#pragma mark - XCSServiceAPIProtocol

- (NSMutableURLRequest *)requestfForPath:(NSString *)path andParams:(NSDictionary *)params
{
    NSLog(@"%s",__FUNCTION__);
    
    NSMutableDictionary *parameters = [params mutableCopy];
    NSMutableString *url = [NSMutableString stringWithFormat:@"%@%@", kGithubAPIBaseUrl, path];
    
    NSLog(@"url : %@", url);
    
    NSString *accessToken = [XCSAccount currentAccount].accessToken;
    
    NSLog(@"accessToken : %@", accessToken);
    
    if (accessToken) {
        [parameters setObject:accessToken forKey:kGithubAPIParamAccessToken];
    }
    
    for (int i = 0; i < [parameters allKeys].count; i++) {
        
        if (i == 0) {
            [url appendString:@"?"];
        }
        else {
            [url appendString:@"&"];
        }
        
        NSString *key = [parameters allKeys][i];
        [url appendFormat:@"%@=%@", key, NSStringEscapedFrom(parameters[key])];
    }
    
    NSLog(@"url : %@", url);

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];

    if ([path isEqualToString:kGithubAPIMethodGists]) {
        // Add HTTPBody
        request.HTTPBody = nil;
    }
    
    NSLog(@"request : %@", request);
    
//    {
//        "description":"Test",
//        "public":false,
//        "files": {
//            "file1.txt": {
//                "content":"Demo"
//            }
//        }
//    }
    
    return request;
}

- (void)authWithToken:(NSString *)token completion:(void (^)(XCSAccount *account, NSError *error))completion
{
    if (!isNonEmptyString(token)) {
        return;
    }
    
    NSDictionary *params = @{kGithubAPIParamAccessToken: token};
    
    
    
    [self post:kGithubAPIMethodUser params:params completion:^(id response, NSError *error) {
        
        XCSAccount *account = nil;
        
        NSLog(@"response : %@", response);
        
//        if (!error) {
//            account = [[XCSAccount alloc] initWithResponse:response service:XCSServiceGithub];
//            account.accessToken = token;
//        }
//        
        if (completion) {
            completion(nil, error);
        }
    }];
}

- (void)uploadSnippet:(XCSSnippet *)snippet completion:(void (^)(NSDictionary *JSON, NSError *error))completion
{
    if (!snippet) {
        return;
    }
    
    NSDictionary *params = [snippet params];
    NSString *path = kGithubAPIMethodGists;
    
    [self post:path params:params completion:completion];
}

@end
