//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "XCSSnippet.h"
#import "XCSMacros.h"

#import "SLKAPIConstants.h"
#import "GHBAPIConstants.h"

#import "ACEModeNames+Extension.h"
#import "NSObject+SmartDescription.h"

@implementation XCSSnippet

#pragma mark - Data Payload Converter

- (NSDictionary *)paramsForService:(XCSService)service
{
    // Checks for requiered fields
    if (!isNonEmptyString(self.content)) {
        return nil;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    if (service == XCSServiceSlack) {
        if (self.uploadAsSnippet) {
            [params setObject:self.content forKey:kSlackAPIParamContent];
            [params setObject:StringOrEmpty(self.channelId) forKey:kSlackAPIParamChannels];
            [params setObject:StringOrEmpty(self.filename) forKey:kSlackAPIParamFilename];
            [params setObject:StringOrEmpty(self.title) forKey:kSlackAPIParamTitle];
            [params setObject:StringOrEmpty(self.comment) forKey:kSlackAPIParamInitialComment];
            [params setObject:SLKStringFromACEMode(self.filetype) forKey:kSlackAPIParamFiletype];
        }
        else {
            if (!isNonEmptyString(self.channelId)) {
                return nil;
            }
            
            NSString *encedCode = @"```";
            NSMutableString *text = [NSMutableString stringWithFormat:@"%@\n%@\n%@", encedCode, self.content, encedCode];
            
            if (isNonEmptyString(self.comment)) {
                [text appendFormat:@"\n\n%@", self.comment];
            }
            
            [params setObject:text forKey:kSlackAPIParamText];
            [params setObject:self.channelId forKey:kSlackAPIParamChannel];
            [params setObject:@YES forKey:kSlackAPIParamAsUser];
        }
    }
    else if (service == XCSServiceGithub) {
        
        [params setObject:StringOrEmpty(self.comment) forKey:kGithubAPIParamDescription];
        [params setObject:@(!self.uploadAsPrivate) forKey:kGithubAPIParamPublic];
        
        NSDictionary *gist = @{self.filename: @{kGithubAPIParamContent: self.content}};
        [params setObject:gist forKey:kGithubAPIParamFiles];
    }
    
    return params;
}


#pragma mark - NSObject

- (NSString *)description
{
    return [self smartDescription];
}

@end