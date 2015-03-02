//
//  MIXTest.m
//  MixMac
//
//  Created by Водолазкий В.В. on 19.02.15.
//  Copyright (c) 2015 Geomatix Laboratoriess S.R.O. All rights reserved.
//

#import "MIXTest.h"

@implementation MIXTest

@synthesize cpu = cpu;

- (void)setUp {
	[super setUp];
	cpu = [MIXCPU sharedInstance];
	XCTAssert(cpu, @"CPU instance should be ceated");
	
	MIXWORD memoryCell;
	memoryCell.sign = YES;
	memoryCell.byte[0] = 80 >> 6;
	memoryCell.byte[1] = 80 & 0x3f;
	memoryCell.byte[2] = 3;
	memoryCell.byte[3] = 5;
	memoryCell.byte[4] = 4;
	
//	NSLog(@"Value stored to memory");
//	[self printMemoryCell:memoryCell];
	
	[cpu setMemoryWord:memoryCell forCellIndex:TEST_CELL];
	
	//	NSLog(@"memory contents");
	MIXWORD cellInMem = [cpu memoryWordForCellIndex:TEST_CELL];
	//	[self printMemoryCell:cellInMem];
	BOOL equal = [self compareWordA:memoryCell withWordB:cellInMem];
	XCTAssertTrue(equal,@"Word should be properly written to memory and read back");
}


- (void)tearDown {
	// Put teardown code here. This method is called after the invocation of each test method in the class.
	[super tearDown];
}

#pragma mark - command generator

- (MIXWORD) mixCommandForMnemonic:(NSString *)mnemoCode withAddress:(long) address
							index:(int)indexReg
					  andModifier:(MIX_F) modifier
{

	MIXWORD memoryCell;

	if (indexReg > 0) {
		NSLog(@"%@ %ld, %d", mnemoCode, address, indexReg);
	} else {
		NSLog(@"%@ %ld", mnemoCode, address);
	}
	MixCommand *cmd = [[MixCommands sharedInstance] getCommandByMnemonic:mnemoCode];
	XCTAssert(cmd, "@Command %@ should be present in commands list!", mnemoCode);
	if (!cmd) {
		return [self mixWordFromInteger:0];		// equivalent of NOP
	}
	
	memoryCell.sign = (address < 0 ? YES : NO);
	if (address < 0) {
		address = -address;
	}
	XCTAssertTrue(address <= [cpu maxIndex], @"Value supplied as address should not exceed %ld", [cpu maxIndex]);
	memoryCell.byte[1] = address & (cpu.sixBitByte ? 0x3f : 0xff);
	address >>= (cpu.sixBitByte ? 6 : 8);
	memoryCell.byte[0] = address & (cpu.sixBitByte ? 0x3f : 0xff);;
	memoryCell.byte[2] = indexReg;
	memoryCell.byte[3] = (modifier == MIX_F_NOTDEFINED ? cmd.defaultFField : modifier);
	memoryCell.byte[4] = cmd.commandCode;

	return memoryCell;
}

#pragma mark - Data conversion methods

- (long) integerFromMIXWORD:(MIXWORD) memCell
{
	long result = 0;
	for (int i=0; i < MIX_WORD_SIZE; i++) {
		result <<= (cpu.sixBitByte ? 6 : 8);
		result += memCell.byte[i];
	}
	if (memCell.sign) {
		result = -result;
	}
	return result;
}

- (MIXWORD) mixWordFromInteger:(long) sum
{
	MIXWORD summator;
	if (sum < 0) {
		sum = -sum;
		summator.sign = YES;
	} else {
		summator.sign = NO;
	}
	for (int i = MIX_WORD_SIZE-1; i >=0; i--) {
		Byte part = sum & (cpu.sixBitByte ? 0x3F : 0xFF);
		sum = sum >> (cpu.sixBitByte ? 6 : 8);
		summator.byte[i] = part;
	}
	return summator;
}

- (long) integerFromMIXINDEX:(MIXINDEX) aIndex
{
	long result = 0;
	for (int i = 0; i < 2; i++) {
		result <<= (cpu.sixBitByte ? 6 : 8);
		result += aIndex.indexByte[i];
	}
	if (aIndex.sign) {
		result = -result;
	}
	return result;
}

- (MIXINDEX) mixIndexFromInteger:(long)aInt
{
	MIXINDEX result;
	result.sign = (aInt < 0);
	result.sign = (aInt < 0);
	if (aInt < 0) {
		aInt = -aInt;
	}
	for (int i = 1;i >= 0; i--) {
		result.indexByte[i] = aInt & (cpu.sixBitByte ? 0x3f : 0xFF);
		aInt = aInt >> (cpu.sixBitByte ? 6 : 8);
	}
	return result;
}




#pragma mark - Service methods

- (MIXINDEX) indexWithSign:(BOOL) aSign byte0:(Byte) b0 andByte1:(Byte) b1
{
	MIXINDEX result;
	result.sign = aSign;
	result.indexByte[0] = b0;
	result.indexByte[1] = b1;
	return result;
}

- (MIXWORD) wordWithNegativeSign:(BOOL)aSign andByte0:(Byte) b0 byte1:(Byte) b1 byte2:(Byte) b2
						   byte3:(Byte) b3 byte4:(Byte) b4
{
	MIXWORD testData;
	testData.sign = aSign;
	testData.byte[0] = b0;
	testData.byte[1] = b1;
	testData.byte[2] = b2;
	testData.byte[3] = b3;
	testData.byte[4] = b4;
	
	return testData;
}


- (void) printMemoryCell:(MIXWORD)cell
{
	NSLog(@  "------------------------------");
	NSLog(@"| %@ | %2d | %2d | %2d | %2d | %2d |", (cell.sign ? @"-" : @"+"),
		  cell.byte[0], cell.byte[1], cell.byte[2], cell.byte[3], cell.byte[4]);
	NSLog(@  "------------------------------");
	
}


- (void) printIndex:(MIXINDEX) cell
{
	NSLog(@  "---------------");
	NSLog(@"| %@ | %2d | %2d |",
		  (cell.sign ? @"-" : @"+"),
		  cell.indexByte[0], cell.indexByte[1]);
	NSLog(@  "---------------");
	
}

//
// Compare index values
//
- (BOOL) compareIndexA:(MIXINDEX) iA andIndexB:(MIXINDEX) iB
{
	if (iA.sign != iB.sign) {
		return NO;
	}
	if (iA.indexByte[0] != iB.indexByte[0]) {
		return NO;
	}
	if (iA.indexByte[1] != iB.indexByte[1]) {
		return NO;
	}
	
	return YES;
}

//
// Compare two words
//
- (BOOL) compareWordA:(MIXWORD) wordA withWordB:(MIXWORD) wordB
{
	if (wordA.sign != wordB.sign) {
		return NO;
	}
	for (int i = 0; i < MIX_WORD_SIZE; i++) {
		if (wordA.byte[i] != wordB.byte[i]) {
			return NO;
		}
	}
	return YES;
}

- (long) longIntegerFromCpu
{
	long msw = [self integerFromMIXWORD:cpu.A];
	long lsw = [self integerFromMIXWORD:cpu.X];
	
	msw = msw << (cpu.sixBitByte ? 6 * MIX_WORD_SIZE : 8 * MIX_WORD_SIZE);
	
	return lsw + msw ;
}


@end
