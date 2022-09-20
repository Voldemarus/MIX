//
//  ParserConsumer.h
//  Reentrant-Parser-Using-Flex-and-Bison
//
//  Created by Stanislaw Pankevich on 19/11/15.
//  Copyright © 2015 Stanislaw Pankevich. All rights reserved.
//
//  Update and modification for MIX assembler
//  Copyright  © 2022 Geomatix Laboratory s.r.o.

#import <Foundation/Foundation.h>

@protocol ParserConsumer <NSObject>

- (void)parserDidParseString:(char *)string;
- (void)parserDidParseNumber:(int)number;


- (void) parserDidParseLabel:(char *) string;

@end
