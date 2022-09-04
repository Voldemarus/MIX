//
//  Parser.m
//  MixMac
//
//  Created by Водолазкий В.В. on 04.09.2022.
//  Copyright © 2022 Geomatix Laboratoriy S.R.O. All rights reserved.
//

//


#import "MixParser.h"


@interface ParserConsumer : NSObject <ParserConsumer>
@end

@implementation ParserConsumer

- (void)parserDidParseString:(char *)string {
    printf("[Consumer, string] %s\n", string);
}

- (void)parserDidParseNumber:(int)number {
    printf("[Consumer: number] %d\n", number);
}

@end

@interface MixParser ()

@property (nonatomic, retain) ParserConsumer *parserConsumer;

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


- (void)parserDidParseString:(char *)string {
    printf("[Consumer, string] %s\n", string);
}

- (void)parserDidParseNumber:(int)number {
    printf("[Consumer: number] %d\n", number);
}

@end
