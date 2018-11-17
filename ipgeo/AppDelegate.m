//
//  AppDelegate.m
//  ipgeo
//
//  Created by Bruno Vandekerkhove on 25/10/18.
//  Copyright (c) 2018 Bruno Vandekerkhove. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

#define IP_MATCH @"[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}"

@implementation AppDelegate

const NSString *selectedCountry = @"France";

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames {
    
    if (filenames.count > 0) {
        
        NSArray *geodata = [self readGeoData];
        
        NSStringEncoding encoding = NSUTF8StringEncoding;
        NSString *ipdata = [[NSString alloc] initWithContentsOfFile:[filenames firstObject]
                                                       usedEncoding:&encoding
                                                              error:NULL];
        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:IP_MATCH
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        __block NSString *results = @"";
        
        [regex enumerateMatchesInString:ipdata options:0 range:NSMakeRange(0, [ipdata length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
            
            NSRange matchRange = [match range];
            NSString *IP = [ipdata substringWithRange:matchRange];
            if ([self address:IP isInRange:geodata])
                results = [results stringByAppendingString:[NSString stringWithFormat:@"%@\n", IP]];
        }];
        
        NSAlert *resultAlert = [NSAlert new];
        [resultAlert setMessageText:@"Results"];
        [resultAlert setInformativeText:(results.length == 0 ? @"No matches" : results)];
        [resultAlert runModal];
        
        
    }
    
}

- (BOOL)address:(NSString *)ip isInRange:(NSArray *)geodata {
    
    NSArray *ipElements = [ip componentsSeparatedByString:@"."];
    
    for (int i=0 ; i<geodata.count ; i+=2) {
        NSString *from = [geodata objectAtIndex:i], *to = [geodata objectAtIndex:i+1];
        NSArray *fromElements = [from componentsSeparatedByString:@"."],
                *toElements = [to componentsSeparatedByString:@"."];
        BOOL valid = false;
        for (int j=0 ; j<fromElements.count ; j++) {
            int lower = [(NSString *)[fromElements objectAtIndex:j] intValue];
            int upper = [(NSString *)[toElements objectAtIndex:j] intValue];
            int ip = [(NSString *)[ipElements objectAtIndex:j] intValue];
            if (ip > lower && ip < upper) {
                valid = true;
                break;
            }
            else if (ip < lower || ip > upper)
                break;
        }
        if (valid)
            return true;
    }
    
    return false;
    
}

- (NSArray *)readGeoData {
    
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"geo" withExtension:@"csv"];
    NSString *geodata = [NSString stringWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:NULL];
    NSArray *rows = [geodata componentsSeparatedByString:@"\n"];
    NSMutableArray *ranges = [NSMutableArray array];
    for (int i = 0; i < rows.count; i ++){
        NSString *row = [rows objectAtIndex:i];
        NSArray *columns = [row componentsSeparatedByString:@","];
        if (columns.count != 6)
            continue;
        if ([[(NSString *)[columns objectAtIndex:5] lowercaseString] containsString:[selectedCountry lowercaseString]]) {
            NSString *fromRange = [columns objectAtIndex:0], *toRange = [columns objectAtIndex:1];
            [ranges addObject:[fromRange stringByReplacingOccurrencesOfString:@"\"" withString:@""]];
            [ranges addObject:[toRange stringByReplacingOccurrencesOfString:@"\"" withString:@""]];
        }
    }
    
    return ranges;
    
}

@end
