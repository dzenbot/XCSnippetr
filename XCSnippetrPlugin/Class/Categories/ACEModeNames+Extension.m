//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "ACEModeNames+Extension.h"

ACEMode ACEModeForFileName(NSString *fileName)
{
    NSString *name = [fileName lowercaseString];
    NSString *extension = [name pathExtension];
    
    if ([extension isEqualToString:@"h"] || [extension isEqualToString:@"m"]) {
        return ACEModeObjC;
    }
    else if ([extension isEqualToString:@"cpp"] || [extension isEqualToString:@"mm"]) {
        return ACEModeCPP;
    }
    else if ([extension isEqualToString:@"js"]) {
        return ACEModeJavaScript;
    }
    else if ([extension isEqualToString:@"php"]) {
        return ACEModePHP;
    }
    else if ([extension isEqualToString:@"html"] || [extension isEqualToString:@"htm"]) {
        return ACEModeHTML;
    }
    else if ([extension isEqualToString:@"css"]) {
        return ACEModeCSS;
    }
    else if ([extension isEqualToString:@"less"]) {
        return ACEModeLESS;
    }
    else if ([extension isEqualToString:@"hx"]) {
        return ACEModeHaxe;
    }
    else if ([extension isEqualToString:@"rb"] || [name isEqualToString:@"gemspec"] || [name isEqualToString:@"podspec"] || [name isEqualToString:@"podfile"]) {
        return ACEModeRuby;
    }
    else if ([extension isEqualToString:@"py"]) {
        return ACEModePython;
    }
    else if ([extension isEqualToString:@"java"]) {
        return ACEModeJava;
    }
    else if ([extension isEqualToString:@"scala"]) {
        return ACEModeScala;
    }
    else if ([extension isEqualToString:@"svg"]) {
        return ACEModeSVG;
    }
    else if ([extension isEqualToString:@"sh"]) {
        return ACEModeSH;
    }
    else if ([extension isEqualToString:@"json"]) {
        return ACEModeJSON;
    }
    else if ([extension isEqualToString:@"xml"]) {
        return ACEModeXML;
    }
    else if ([extension isEqualToString:@"yaml"]) {
        return ACEModeYAML;
    }
    else if ([extension isEqualToString:@"md"]) {
        return ACEModeMarkdown;
    }
    else {
        return ACEModeText;
    }
}

NSString *NSStringFromACEMode(ACEMode mode)
{
    switch (mode) {
        case ACEModeObjC:           return @"objc";
        case ACEModeCPP:            return @"cpp";
        case ACEModeJavaScript:     return @"javascript";
        case ACEModePHP:            return @"php";
        case ACEModeHTML:           return @"html";
        case ACEModeCSS:            return @"css";
        case ACEModeRuby:           return @"ruby";
        case ACEModePython:         return @"python";
        case ACEModeJava:           return @"java";
        case ACEModeScala:          return @"scala";
        case ACEModeSH:             return @"shell";
        case ACEModeJSON:           return @"javascript";
        case ACEModeXML:            return @"xml";
        case ACEModeYAML:           return @"yaml";
        case ACEModeMarkdown:       return @"markdown";
        default:                    return @"text";
    }
}
