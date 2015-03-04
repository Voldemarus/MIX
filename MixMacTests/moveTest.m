//
//  moveTest.m
//  MixMac
//
//  Created by Водолазкий В.В. on 02.03.15.
//  Copyright (c) 2015 Geomatix Laboratoriy S.R.O. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MIXTest.h"

@interface moveTest : MIXTest

@end


#define BLOCK_SIZE	25
#define FROM_ADDR	1000
#define TO_ADDR		2000

#define TO_OVERLAP	1020

@implementation moveTest


- (void) testMove
{
	[cpu resetCPU];			// clear all registers and memory
	
	MIXWORD data[BLOCK_SIZE];
	[self prepareTestWithSrcAddress:FROM_ADDR destAddress:TO_ADDR andRepetitionCount:BLOCK_SIZE];
	
	// create template to fill/move/verify
	for (int i = 0; i < BLOCK_SIZE; i++) {
		data[i] = [self mixWordFromInteger:i+10];
		[cpu setMemoryWord:data[i] forCellIndex:(FROM_ADDR+i)];
	}
	
	[cpu executeCurrentOperation];			// move block
	
	for (int i = 0; i < BLOCK_SIZE; i++) {
		MIXWORD tmp = [cpu memoryWordForCellIndex:TO_ADDR+i];
		BOOL isEqual = [self compareWordA:tmp withWordB:data[i]];
		XCTAssertTrue(isEqual, @"memory cell should be copied properly");
	}
}


- (void) testNOP
{
	MIXWORD command = [self mixCommandForMnemonic:@"NOP" withAddress:0 index:0 andModifier:MIX_F_NOTDEFINED];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;

	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"program counter shpuld be incremented");
}

- (void) testHlt
{
	[cpu resetCPU];
	
	XCTAssertFalse(cpu.haltStatus, @"should be resetted after reset");
	MIXWORD command = [self mixCommandForMnemonic:@"HLT" withAddress:0 index:0 andModifier:MIX_F_NOTDEFINED];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC, @"program counter shpuld not be incremented");
	XCTAssertTrue(cpu.haltStatus, @"should be halted");

	
}


#pragma mark -

- (void) prepareTestWithSrcAddress:(int)srcAddr destAddress:(int)dstAddr andRepetitionCount:(int)repeat
{
	XCTAssertTrue(srcAddr >= 0, @"Source address should be valid");
	XCTAssertTrue(srcAddr < MIX_MEMORY_SIZE, @"Source address should be valid");
	XCTAssertTrue(dstAddr >= 0, @"Destination address should be valid");
	XCTAssertTrue(dstAddr < MIX_MEMORY_SIZE, @"Destination address should be valid");
	XCTAssertTrue(repeat >= 0, @"Repeat counter should be valid");
	XCTAssertTrue(repeat < (cpu.sixBitByte ? 0x3F : 0xFF), @"RepeatCounter should be valid");

	
	MIXWORD command = [self mixCommandForMnemonic:@"MOVE" withAddress:srcAddr index:0 andModifier:repeat];
	cpu.index1 = [self mixIndexFromInteger:dstAddr];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
}


@end
