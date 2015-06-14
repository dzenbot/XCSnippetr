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

#import "SLKSnippet.h"
#import "SLKAccount.h"

@implementation GHBAPIClient

#pragma mark - XCSServiceAPIProtocol

- (NSMutableURLRequest *)requestfForPath:(NSString *)path andParams:(NSDictionary *)params
{
    NSMutableDictionary *parameters = [params mutableCopy];
    NSMutableString *url = [NSMutableString stringWithFormat:@"%@%@", kGithubAPIBaseUrl, path];
    
    NSString *accessToken = [SLKAccount currentAccount].accessToken;
    
    [parameters setObject:accessToken forKey:kGithubAPIParamAccessToken];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    if ([path isEqualToString:kGithubAPIMethodGists]) {
        // Add HTTPBody
        request.HTTPBody = nil;
    }
    
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

- (void)createGist:(SLKSnippet *)snippet completion:(void (^)(NSDictionary *JSON, NSError *error))completion;
{
    if (!snippet) {
        return;
    }
    
    NSDictionary *params = [snippet params];
    NSString *path = kGithubAPIMethodGists;
    
    [self post:path params:params completion:completion];
}

@end
