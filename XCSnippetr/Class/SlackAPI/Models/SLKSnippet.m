//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "SLKSnippet.h"
#import "SLKAPIConstants.h"
#import "XCSMacros.h"

#import "ACEModeNames+Extension.h"
#import "NSObject+SmartDescription.h"

@implementation SLKSnippet

/**
 @method 'files.upload'
 
 @param channels The channel ids where to upload
 @param content The snippet string
 @param initial_comment The snippet comment
 @param title The class file name (ie: 'SLKBoardPlugin.h')
 @param filetype 'snippet'
 */

/**
 @method 'chat.postMessage'
 
 @param channel The channel id
 @param text The message string
 @param as_user True if posted as the user. If not, as Slackbot
 */
- (NSDictionary *)params
{
    // Checks for requiered fields
    if (!isNonEmptyString(self.content)) {
        return nil;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    if (self.uploadAsFile) {
        [params setObject:self.content forKey:kAPIParamContent];
        [params setObject:StringOrEmpty(self.channelId) forKey:kAPIParamChannels];
        [params setObject:StringOrEmpty(self.filename) forKey:kAPIParamFilename];
        [params setObject:StringOrEmpty(self.title) forKey:kAPIParamTitle];
        [params setObject:StringOrEmpty(self.comment) forKey:kAPIParamInitialComment];
        [params setObject:SLKStringFromACEMode(self.filetype) forKey:kAPIParamFiletype];
    }
    else {
        if (!isNonEmptyString(self.channelId)) {
            return nil;
        }
        
        NSMutableString *text = [NSMutableString stringWithFormat:@"```\n%@\n```", self.content];
        
        if (isNonEmptyString(self.comment)) {
            [text appendFormat:@"\n\n%@", self.comment];
        }
        
        [params setObject:text forKey:kAPIParamText];
        [params setObject:self.channelId forKey:kAPIParamChannel];
        [params setObject:@YES forKey:kAPIParamAsUser];
    }
        
    return params;
}

- (NSString *)description
{
    return [self smartDescription];
}

@end
