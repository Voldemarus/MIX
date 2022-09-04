//
//  Parser.h
//  MixMac
//
//  Created by Водолазкий В.В. on 04.09.2022.
//  Copyright © 2022 Geomatix Laboratoriy S.R.O. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ParserConsumer.h"
#import "Parser.h"
#import "Lexer.h"


NS_ASSUME_NONNULL_BEGIN



@interface MixParser : NSObject

+ (MixParser *) sharedInstance;

@end

NS_ASSUME_NONNULL_END
