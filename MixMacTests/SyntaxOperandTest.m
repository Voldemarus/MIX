//
//  SyntaxOperandTest.m
//  MixMacTests
//
//  Created by Dmitry Likhtarov on 09/01/2019.
//  Copyright © 2019 Geomatix Laboratoriy S.R.O. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DebugPrint.h"

@interface SyntaxOperandTest : XCTestCase

@end

@implementation SyntaxOperandTest

- (void)testExample {
    NSArray * ops = @[
                      @"METKA,2(1METKADIGIT//2)",
                      @"24",
                      @"METKA",
                      @"*",
                      @"3B+1111",
                      @"=20-METKA=",
                      @"20-METKA2",
                      @"2000",
                      @"235(3)",
                      @"S1+3(S2),3000",
                      @"S1,S2(3:5),23",
                      @"1(1:2),66(4:5)",
                      @"-S1(1:5)", //  Ссылки вперёд допускаются только если встречаются отдельно
                                   //  (или с унарной операцией) в части ADDRESS инструкции MIXAL
                      @"2-S1", // ссылка вперед НЕДопустима!
                      ];
}


@end
