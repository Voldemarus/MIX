//
//  MIXCPU.m
//  MixMac
//
//  Created by Водолазкий В.В. on 14.02.15.
//  Copyright (c) 2015 Geomatix Laboratoriess S.R.O. All rights reserved.
//

#import "MIXCPU.h"
#import "Preferences.h"

#import "DebugPrint.h"

@interface MIXCPU() {
	MIXWORD memory[MIX_MEMORY_SIZE];		// internal Memory
	
	MIXINDEX indexRegister[MIX_INDEX_REGISTERS];

	MIXINDEX	jumpRegister;					// register J
	MIXWORD		accumultor;						// register A
	MIXWORD		extension;						// register X
	
	BOOL overflowFlag;
	MIX_COMPARASION comparasionFlag;
}

@end

NSString * const MIXExceptionInvalidMemoryCellIndex	=	@"MIXExceptionInvalidMemoryCellIndex";
NSString * const MIXExceptionInvalidIndexRegister	=	@"MIXExceptionInvalidIndexRegister";


@implementation MIXCPU

+ (MIXCPU *) sharedInstance
{
	static MIXCPU *_instance;
	if (_instance == nil) {
		_instance = [[MIXCPU alloc] init];
	}
	return _instance;
}

- (id) init
{
	if (self = [super init]) {
		self.sixBitByte = [Preferences sharedPreferences].byteHas6Bit;
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(byteSizeChanged:) name:VVVbyteSizeChanged object:nil];
	}
	return self;
}

#pragma mark - Public methods

- (void) resetCPU
{
	// Clear flags
	comparasionFlag = MIX_NOT_SET;
	overflowFlag = NO;
	
	MIXWORD emptyCell;
	self.A = emptyCell;
	self.X = emptyCell;
	MIXINDEX emptyIndex;
	for (int i = 1; i <= MIX_INDEX_REGISTERS;i++) {
		[self setIndexRegister:emptyIndex withNumber:i];
	}
	self.J = emptyIndex;
	
	// clear memory
	for (int i = 0; i < MIX_MEMORY_SIZE; i++) {
		MIXWORD cell = memory[i];
		cell.sign = 0;
		for (int j = 0; j < MIX_WORD_SIZE; j++) {
			cell.byte[j] = 0;
		}
	}
}

- (void) setMemoryWord:(MIXWORD)aWord forCellIndex:(int) index
{
	if (index < 0 || index >= MIX_MEMORY_SIZE) {
		[NSException raise:MIXExceptionInvalidMemoryCellIndex
					format:RStr(MIXExceptionInvalidMemoryCellIndex)];
		return;
	}
	MIXWORD cell = memory[index];
	cell.sign = aWord.sign;
	for (int i = 0; i < MIX_WORD_SIZE; i++) {
		cell.byte[i] = aWord.byte[i];
	}
}

- (MIXWORD) memoryWordForCellIndex:(int) index
{
	MIXWORD result;
	if (index < 0 || index >= MIX_MEMORY_SIZE) {
		[NSException raise:MIXExceptionInvalidMemoryCellIndex
					format:RStr(MIXExceptionInvalidMemoryCellIndex)];
		return result;
	}
	MIXWORD cell = memory[index];
	result.sign = cell.sign ;
	for (int i = 0; i < MIX_WORD_SIZE; i++) {
		result.byte[i] = cell.byte[i];
	}
	return result;
}

#pragma mark - properties getter/seeter methods

- (MIXWORD) A
{
	MIXWORD result;
	result.sign = accumultor.sign;
	for (int i = 0; i < MIX_WORD_SIZE; i++) {
		result.byte[i] = accumultor.byte[i];
	}
	return result;
}

- (void) setA:(MIXWORD) newA
{
	accumultor.sign = newA.sign;
	for (int i = 0; i < MIX_WORD_SIZE; i++) {
		accumultor.byte[i] = newA.byte[i];
	}
}

- (MIXWORD) X
{
	MIXWORD result;
	result.sign = extension.sign;
	for (int i = 0; i < MIX_WORD_SIZE; i++) {
		result.byte[i] = extension.byte[i];
	}
	return result;
}

- (void) setX:(MIXWORD)X
{
	extension.sign = X.sign;
	for (int i = 0; i < MIX_WORD_SIZE; i++) {
		extension.byte[i] = X.byte[i];
	}
}


- (MIXINDEX) J
{
	MIXINDEX result;
	result.sign = jumpRegister.sign;
	result.indexByte[0] = jumpRegister.indexByte[0];
	result.indexByte[1] = jumpRegister.indexByte[1];
	return result;
}

- (void) setJ:(MIXINDEX)J
{
	jumpRegister.sign = J.sign;
	jumpRegister.indexByte[0] = J.indexByte[0];
	jumpRegister.indexByte[1] = J.indexByte[1];
}

- (void) setIndexRegister:(MIXINDEX) aValue withNumber:(int)aIndex
{
	if (aIndex < 1 || aIndex > MIX_INDEX_REGISTERS) {
		[NSException raise:MIXExceptionInvalidIndexRegister
					format:RStr(MIXExceptionInvalidIndexRegister)];
		return;
	}
	MIXINDEX result = indexRegister[aIndex-1];
	result.sign = aValue.sign;
	result.indexByte[0] = aValue.indexByte[0];
	result.indexByte[1] = aValue.indexByte[1];
}

- (MIXINDEX) indexRegisterValue:(int)aIndex
{
	MIXINDEX result;
	// OPTION BASE 1  !!!
	if (aIndex < 1 || aIndex > MIX_INDEX_REGISTERS) {
		[NSException raise:MIXExceptionInvalidIndexRegister
					format:RStr(MIXExceptionInvalidIndexRegister)];
		return result;
	}
	MIXINDEX indexReg = indexRegister[aIndex-1];
	result.sign = indexReg.sign;
	result.indexByte[0] = indexReg.indexByte[0];
	result.indexByte[1] = indexReg.indexByte[1];
	return result;
}

- (BOOL) overflow
{
	return overflowFlag;
}

- (MIX_COMPARASION) flag
{
	return comparasionFlag;
}

- (MIXINDEX) index1
{
	return [self indexRegisterValue:1];
}

- (void) setIndex1:(MIXINDEX)index1
{
	[self setIndexRegister:index1 withNumber:1];
}

- (MIXINDEX) index2
{
	return [self indexRegisterValue:2];
}

- (void) setIndex2:(MIXINDEX)index1
{
	[self setIndexRegister:index1 withNumber:2];
}

- (MIXINDEX) index3
{
	return [self indexRegisterValue:3];
}

- (void) setIndex3:(MIXINDEX)index1
{
	[self setIndexRegister:index1 withNumber:3];
}

- (MIXINDEX) index4
{
	return [self indexRegisterValue:4];
}

- (void) setIndex4:(MIXINDEX)index1
{
	[self setIndexRegister:index1 withNumber:4];
}

- (MIXINDEX) index5
{
	return [self indexRegisterValue:5];
}

- (void) setIndex5:(MIXINDEX)index1
{
	[self setIndexRegister:index1 withNumber:5];
}

- (MIXINDEX) index6
{
	return [self indexRegisterValue:6];
}

- (void) setIndex6:(MIXINDEX)index1
{
	[self setIndexRegister:index1 withNumber:6];
}


#pragma mark - Internal service methods


- (void) updateCPUCells
{
	
}


#pragma mark - Selectors

//
// Called when size of the byte is changed
//
- (void) byteSizeChanged:(NSNotification *) note
{
	self.sixBitByte = [[note object] boolValue];
	[self updateCPUCells];
}

@end
