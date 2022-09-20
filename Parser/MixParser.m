//
//  Parser.m
//  MixMac
//
//  Created by Водолазкий В.В. on 04.09.2022.
//  Copyright © 2022 Geomatix Laboratoriy S.R.O. All rights reserved.
//

//


#import "MixParser.h"
#import "Preferences.h"


@interface ParserConsumer : NSObject <ParserConsumer>
@end

@implementation ParserConsumer

- (void)parserDidParseString:(char *)string {
    printf("[Consumer, string] %s\n", string);
}

- (void)parserDidParseNumber:(int)number {
    printf("[Consumer: number] %d\n", number);
}

- (void) parserDidParseLabel:(char *)string {
    printf("[Consumer, label] %s\n", string);
}

- (void) parserDidParseConstants:(char *)string {
    printf("[Consumer, constant] %s\n", string);
}



@end

@interface MixParser ()

@property (nonatomic, retain) ParserConsumer *parserConsumer;
@property (nonatomic, readwrite) NSInteger pc;
@end


@implementation MixParser


+ (MixParser *) sharedInstance
{
    static MixParser * _instance = nil;
    if (_instance == nil) {
        _instance = [[MixParser alloc] init];
    }
    return _instance;
}

- (instancetype) init
{
    if (self = [super init]) {
        self.parserConsumer = [[ParserConsumer alloc] init];
        self.labels = [NSMutableDictionary new];
        self.constants = [NSMutableDictionary new];
        self.pc = 0;
    }
    return self;
}

- (void) parseLine:(NSString *) aLine lineNum:(NSInteger) aNum
{
    @autoreleasepool {
        yyscan_t scanner;

        if (yylex_init(&scanner)) {
            perror("yylex_init error");
        }

 //       char input[] = "RAINBOW UNICORN 1234 UNICORN garbage garbage";

        yy_scan_string([aLine UTF8String], scanner);

        yyparse(scanner, self.parserConsumer);

        yylex_destroy(scanner);


    }
}

// Parser delegats methods

- (void)parserDidParseString:(char *)string {
    printf("[Consumer, string] %s\n", string);
}

- (void)parserDidParseNumber:(int)number {
    printf("[Consumer: number] %d\n", number);
}

- (void) parserDidParseLabel:(char *)string
{
    NSString *label = [NSString stringWithCString:string encoding:NSUTF8StringEncoding];
    if ([[Preferences sharedPreferences] caseSensitive] == NO ) {
        [label uppercaseString];
    }
    if (self.labels[label]) {
#warning FIX ME!
        //OOPS!  Error - attempt to redefine label!!!
    } else {
        // Register new label in the label's table
        self.labels[label] = @(self.pc);
    }
}

- (void) parserDidParseConstant:(char *)string
{
    NSString *cnst = [NSString stringWithCString:string encoding:NSUTF8StringEncoding];

    if (self.constants[cnst]) {
#warning FIX ME!
        //OOPS!  Error - attempt to redefine constnatl!!!
    } else {
        // Register new label in the label's table
        self.constants[cnst] = @(self.pc);
    }
}


@end
