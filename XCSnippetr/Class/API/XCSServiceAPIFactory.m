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

@implementation XCSServiceAPIFactory

+ (id<XCSServiceAPIProtocol>)APIClientForService:(XCSService)service
{
    switch (service) {
        case XCSServiceSlack:       return [SLKAPIClient sharedClient];
        case XCSServiceGithub:      return [GHBAPIClient sharedClient];
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

@end
