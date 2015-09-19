//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "XCSClientFactory.h"
#import "XCSMacros.h"

#import "XCSSlackClient.h"
#import "XCSGithubClient.h"

static XCSBaseClient *_client = nil;

@interface XCSClientFactory ()
@end

@implementation XCSClientFactory

+ (id<XCSClientProtocol>)clientForService:(XCSService)service
{
    if (_client) return _client;
    
    _client = [[self APIClientClassForService:service] new];
    
    return _client;
}

+ (Class)APIClientClassForService:(XCSService)service
{
    switch (service) {
        case XCSServiceSlack:       return [XCSSlackClient class];
        case XCSServiceGithub:      return [XCSGithubClient class];
        default:                    return nil;
    }
}

+ (NSString *)tokenSourceUrlForService:(XCSService)service
{
    switch (service) {
        case XCSServiceSlack:       return kSlackWebAPIUrl;
        case XCSServiceGithub: {
            return [NSString stringWithFormat:@"%@?%@=%@&%@=%@", kGistWebAPIUrl, kGithubAPIParamDescription, kXCSnippetrName, kGithubAPIParamScopes, kGithubAPIParamGist];
        }
        default:                    return nil;
    }
}

+ (void)reset
{
    [_client cancelRequestsIfNeeded];

    _client = nil;
}

@end
