//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "XCSServiceAPIFactory.h"
#import "XCSMacros.h"

#import "SLKAPIClient.h"
#import "GHBAPIClient.h"

static XCSBaseAPI *_client;

@interface XCSServiceAPIFactory ()
@end

@implementation XCSServiceAPIFactory

+ (id<XCSServiceAPIProtocol>)APIClientForService:(XCSService)service
{
    if (_client) return _client;
    
    _client = [[self APIClientClassForService:service] new];
    
    return _client;
}

+ (Class)APIClientClassForService:(XCSService)service
{
    switch (service) {
        case XCSServiceSlack:       return [SLKAPIClient class];
        case XCSServiceGithub:      return [GHBAPIClient class];
        default:                    return nil;
    }
}

+ (NSString *)tokenSourceUrlForService:(XCSService)service
{
    switch (service) {
        case XCSServiceSlack:       return kSlackWebAPIUrl;
        case XCSServiceGithub: {
            return [NSString stringWithFormat:@"%@?%@=%@&%@=%@", kGistWebAPIUrl, kGithubAPIParamDescription, SLKBundleName(), kGithubAPIParamScopes, kGithubAPIParamGist];
        }
        default:                    return nil;
    }
}

+ (void)reset
{
    _client = nil;
}

@end
