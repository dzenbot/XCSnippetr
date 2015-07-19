//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

// Urls
static NSString * const kSlackAPIBaseUrl =                  @"https://slack.com/api/";
static NSString * const kSlackWebAPIUrl =                   @"https://api.slack.com/web";

// API Methods
static NSString * const kSlackAPIMethodAuthTest =           @"auth.test";
static NSString * const kSlackAPIMethodFilesUpload =        @"files.upload";
static NSString * const kSlackAPIMethodChatPostMessage =    @"chat.postMessage";
static NSString * const kSlackAPIMethodRTMStart =           @"rtm.start"; // To get all lists w/ 1 request (users, groups and channels)

// API Param keys
static NSString * const kSlackAPIParamTeam =                @"team";
static NSString * const kSlackAPIParamTeamId =              @"team_id";
static NSString * const kSlackAPIParamToken =               @"token";
static NSString * const kSlackAPIParamIsArchived =          @"is_archived";
static NSString * const kSlackAPIParamIsMember =            @"is_member";
static NSString * const kSlackAPIParamIsChannel =           @"is_channel";
static NSString * const kSlackAPIParamIsGroup =             @"is_group";
static NSString * const kSlackAPIParamIsIM =                @"is_im";
static NSString * const kSlackAPIParamIsOpen =              @"is_open";
static NSString * const kSlackAPIParamId =                  @"id";
static NSString * const kSlackAPIParamTsid =                @"tsid";
static NSString * const kSlackAPIParamName =                @"name";
static NSString * const kSlackAPIParamRealName =            @"real_name";
static NSString * const kSlackAPIParamUser =                @"user";
static NSString * const kSlackAPIParamUserId =              @"user_id";
static NSString * const kSlackAPIParamUsers =               @"users";
static NSString * const kSlackAPIParamAsUser =              @"as_user";
static NSString * const kSlackAPIParamChannel =             @"channel";
static NSString * const kSlackAPIParamChannels =            @"channels";
static NSString * const kSlackAPIParamGroups =              @"groups";
static NSString * const kSlackAPIParamIMs =                 @"ims";
static NSString * const kSlackAPIParamContent =             @"content";
static NSString * const kSlackAPIParamFilename =            @"filename";
static NSString * const kSlackAPIParamTitle =               @"title";
static NSString * const kSlackAPIParamInitialComment =      @"initial_comment";
static NSString * const kSlackAPIParamFiletype =            @"filetype";
static NSString * const kSlackAPIParamText =                @"text";
static NSString * const kSlackAPIParamError =               @"error";

// API values
static NSString * const kSlackAPISlackbotId =               @"USLACKBOT";
static NSString * const kSlackAPISlackbotName =             @"Slackbot";
