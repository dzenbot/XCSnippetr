//
//  XCSKit
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "XCSSnippet.h"
#import "XCSMacros.h"

#import "XCSSlackConstants.h"
#import "XCSGithubConstants.h"
#import "SLKRoomManager.h"

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
    
    if (service == XCSServiceSlack)
    {
        if (self.uploadAsSnippet)
        {
            [params setObject:self.content forKey:kSlackAPIParamContent];
            [params setObject:StringOrEmpty(self.filename) forKey:kSlackAPIParamFilename];
            [params setObject:StringOrEmpty(self.title) forKey:kSlackAPIParamTitle];
            [params setObject:StringOrEmpty(self.comment) forKey:kSlackAPIParamInitialComment];
            [params setObject:StringOrEmpty(self.typeString) forKey:kSlackAPIParamFiletype];
            
            if (!self.uploadAsPrivate) {
                [params setObject:StringOrEmpty(self.channelId) forKey:kSlackAPIParamChannels];
            }
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
            [params setObject:@YES forKey:kSlackAPIParamAsUser];
            
            if (!self.uploadAsPrivate) {
                [params setObject:self.channelId forKey:kSlackAPIParamChannel];
            }
            else {
                SLKRoom *room = [SLKRoomManager roomForName:kSlackAPISlackbotName];

                // Uploads to Slackbot DM
                [params setObject:room.tsid forKey:kSlackAPIParamChannel];
            }
        }
    }
    else if (service == XCSServiceGithub)
    {
        [params setObject:StringOrEmpty(self.comment) forKey:kGithubAPIParamDescription];
        [params setObject:@(!self.uploadAsPrivate) forKey:kGithubAPIParamPublic];
        
        NSString *key = self.filename ? : self.title;
        
        if (isNonEmptyString(key) && isNonEmptyString(self.content)) {
            NSDictionary *gist = @{key: @{kGithubAPIParamContent: self.content}};
            [params setObject:gist forKey:kGithubAPIParamFiles];
        }
        else {
            return nil;
        }
    }
    
    return params;
}


- (void)setFilename:(NSString *)filename
{
    if (!filename) {
        return;
    }
    
    _filename = filename;
    _title = [filename stringByDeletingPathExtension];
    
    self.type = ACEModeForFileName(filename);
}

- (void)setType:(ACEMode)type
{
    _type = type;
    _typeString = NSStringFromACEMode(_type);
    _typeHumanString = [ACEModeNames humanNameForMode:_type];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [self smartDescription];
}

@end
