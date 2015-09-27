//
//  XCSSnippetRepository.m
//  XCSnippetr
//
//  Created by Ignacio Romero on 9/26/15.
//  Copyright © 2015 DZN Labs. All rights reserved.
//

#import "XCSSnippetRepository.h"

static NSString const *XCSSnippetRepositoryPath = @"~/Library/Developer/Xcode/UserData/CodeSnippets/";
static NSString const *XCSSnippetLanguageDomain = @"Xcode.SourceCodeLanguage";

static NSString const *XCSSnippetTemplateName = @"XCSSnippetTemplate";

@implementation XCSSnippetRepository

#pragma mark - Initialization

+ (instancetype)defaultRepository
{
    static XCSSnippetRepository *_defaultRepository;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultRepository = [[self alloc] init];
    });
    return _defaultRepository;
}

- (NSString *)libraryDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)saveSnippet:(XCSSnippet *)snippet completion:(void (^)(NSString *filePath, NSError *error))completion
{
    NSString *identifier = [NSUUID UUID].UUIDString;
    NSString *filePath = [[self libraryDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"Developer/Xcode/UserData/CodeSnippets/%@.codesnippet", identifier]];

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *plistPath = [bundle pathForResource:[XCSSnippetTemplateName copy] ofType:@"plist"];
    
    NSMutableDictionary *template = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];

    template[@"IDECodeSnippetContents"] = snippet.content;
    template[@"IDECodeSnippetIdentifier"] = identifier;
    template[@"IDECodeSnippetLanguage"] = [NSString stringWithFormat:@"%@.%@", XCSSnippetLanguageDomain, snippet.typeHumanString];
    template[@"IDECodeSnippetTitle"] = snippet.title;
    template[@"IDECodeSnippetCompletionPrefix"] = snippet.title;
    
    if ([template writeToURL:[NSURL fileURLWithPath:filePath] atomically:YES]) {
        if (completion) {
            completion(filePath, nil);
        }
    }
    else if (completion) {
        completion(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:NSURLErrorCannotCreateFile userInfo:nil]);
    }
}

@end
