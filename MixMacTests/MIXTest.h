//
//  MIXTest.h
//  MixMac
//
//  Created by Водолазкий В.В. on 19.02.15.
//  Copyright (c) 2015 Geomatix Laboratoriess S.R.O. All rights reserved.
//

#import <XCTest/XCTest.h>

#define TEST_CELL		2000			// memory cell where data is stored
#define TEST_PC			0				// Program counter to store command for testing

#define TEST_CINDEX		2010			// cell in memory addressed with index offset
#define TEST_CINDEX2	1500			// seconde cell whic his addressed by index register


#import "MIXCPU.h"



@interface MIXTest : XCTestCase {
	MIXCPU	*cpu;
}


@property (nonatomic, retain) MIXCPU *cpu;


- (long) integerFromMIXWORD:(MIXWORD) aWord;
- (MIXWORD) mixWordFromInteger:(long) aInt;
- (long) integerFromMIXINDEX:(MIXINDEX) aIndex;
- (MIXINDEX) mixIndexFromInteger:(long)aInt;

- (MIXINDEX) indexWithSign:(BOOL) aSign byte0:(Byte) b0 andByte1:(Byte) b1;
- (MIXWORD) wordWithNegativeSign:(BOOL)aSign andByte0:(Byte) b0 byte1:(Byte) b1 byte2:(Byte) b2
						   byte3:(Byte) b3 byte4:(Byte) b4;
- (void) printMemoryCell:(MIXWORD)cell;
- (void) printIndex:(MIXINDEX) cell;
- (BOOL) compareIndexA:(MIXINDEX) iA andIndexB:(MIXINDEX) iB;
- (BOOL) compareWordA:(MIXWORD) wordA withWordB:(MIXWORD) wordB;

- (long) longIntegerFromCpu;				// get long from A:X pair;

@end
