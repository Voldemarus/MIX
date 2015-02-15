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
	
	MixCommands *commands;
	
	MIXWORD memory[MIX_MEMORY_SIZE];		// internal Memory
	
	MIXINDEX indexRegister[MIX_INDEX_REGISTERS];

	MIXINDEX	jumpRegister;					// register J (Program Counter)
	MIXWORD		accumultor;						// register A
	MIXWORD		extension;						// register X
	
	BOOL overflowFlag;
	MIX_COMPARASION comparasionFlag;
}

@end

NSString * const MIXExceptionInvalidMemoryCellIndex	=	@"MIXExceptionInvalidMemoryCellIndex";
NSString * const MIXExceptionInvalidIndexRegister	=	@"MIXExceptionInvalidIndexRegister";
NSString * const MIXExceptionInvalidOperationCode	=	@"MIXExceptionInvalidOperationCode";
NSString * const MIXExceptionInvalidFieldModifer	=	@"MIXExceptionInvalidFieldModifer";


@implementation MIXCPU

@synthesize PC;

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
		
		commands = [MixCommands sharedInstance];	// set up commands data
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
	self.PC = 0;
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
	MIXWORD cell;
	cell.sign = aWord.sign;
	for (int i = 0; i < MIX_WORD_SIZE; i++) {
		cell.byte[i] = aWord.byte[i];
	}
	memory[index] = cell;
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

- (void) storeNumber:(int)aValue forCellIndex:(int) index
{
	MIXWORD storeValue;
	if (aValue < 0) {
		storeValue.sign = YES;
		aValue = -aValue;
	}
	for (int i = MIX_WORD_SIZE-1; i >= 0; i--) {
		Byte tmp = aValue & (self.sixBitByte ? 0x3F : 0xFF);
		storeValue.byte[i] = tmp;
		aValue >>= (self.sixBitByte ? 6 : 8);
	}
	[self setMemoryWord:storeValue forCellIndex:index];
}

- (int) memoryContentForCellIndex:(int)index
{
	int result = 0;
	if (index < 0 || index >= MIX_MEMORY_SIZE) {
		[NSException raise:MIXExceptionInvalidMemoryCellIndex
					format:RStr(MIXExceptionInvalidMemoryCellIndex)];
		return result;
	}
	MIXWORD memCell = memory[index];
	for (int i=0; i < MIX_WORD_SIZE; i++) {
		result <<= (self.sixBitByte ? 6 : 8);
		result += memCell.byte[i];
	}
	if (memCell.sign) {
		result = -result;
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

#pragma mark Index Registers access

- (void) setIndexRegister:(MIXINDEX) aValue withNumber:(int)aIndex
{
	if (aIndex < 1 || aIndex > MIX_INDEX_REGISTERS) {
		[NSException raise:MIXExceptionInvalidIndexRegister
					format:RStr(MIXExceptionInvalidIndexRegister)];
		return;
	}
	MIXINDEX result;
	result.sign = aValue.sign;
	result.indexByte[0] = aValue.indexByte[0];
	result.indexByte[1] = aValue.indexByte[1];
	indexRegister[aIndex-1] = result;
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

- (void) storeOffset:(int)offset inIndexRegister:(int)aIndex
{
	MIXINDEX indexData;
	if (offset < 0) {
		indexData.sign = YES;
		offset = -offset;
	}
	if (offset > MIX_MEMORY_SIZE) {
		[NSException raise:MIXExceptionInvalidMemoryCellIndex format:RStr(MIXExceptionInvalidMemoryCellIndex)];
		return;
	}
	indexData.indexByte[0] = offset >> (self.sixBitByte ? 6 : 8);
	indexData.indexByte[1] = offset & (self.sixBitByte ? 0x3F : 0xFF);
	
	[self setIndexRegister:indexData withNumber:aIndex];
}

- (int) offsetInIndexRegister:(int)aIndex
{
	MIXINDEX ind = [self indexRegisterValue:aIndex];
	int result = ind.indexByte[0] << (self.sixBitByte ? 6 : 8);
	result += ind.indexByte[1];
	if (ind.sign) {
		result = -result;
	}
	return result;
}


#pragma mark Auxillary Registers Access

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

#pragma mark - Execution methods

//
// Interprets content of the memory cell as command and eecute proper CPU command
//
- (void) executeCurrentOperation
{
	NSInteger effectiveAddr = [self executionAddr];
	MIXWORD command = memory[effectiveAddr];
	Byte operCode = command.byte[4];			// C Field
	
	MixCommand *cmd = [commands getCommandByCode:operCode];
	if (!cmd) {
		[NSException raise:MIXExceptionInvalidOperationCode format:RStr(MIXExceptionInvalidOperationCode)];
	} else {
		//
		// Increment program counter
		//
		self.PC = self.PC+1;
		if (self.PC >= MIX_MEMORY_SIZE) self.PC = 0;
		//
		// Decode CPU commands
		//
		switch (operCode) {
			case CMD_LDA:		[self processLDACommand:command]; break;
				
			default: {
				[NSException raise:MIXExceptionInvalidOperationCode
							format:RStr(MIXExceptionInvalidOperationCode)];
				return;
			}
		}
	}
}


// LDA - load accumulator with memory cell' value
- (void) processLDACommand:(MIXWORD) command
{
	NSInteger effectiveAddress = [self effectiveAddress:command];
	// This address should pount to cell in memoty space
	if (effectiveAddress < 0 || effectiveAddress >= MIX_MEMORY_SIZE) {
		[NSException raise:MIXExceptionInvalidMemoryCellIndex
					format:RStr(MIXExceptionInvalidMemoryCellIndex)];
		return;
	}
	// Read value from the memory
	MIXWORD valueToProcess = memory[effectiveAddress];
	MIXWORD finalValue = [self extractFieldswithModifier:command.byte[3] from:valueToProcess];
	// put result inti accumulator
	self.A = finalValue;
}


#pragma mark - Internal service methods


- (MIXWORD) extractFieldswithModifier:(MIX_F)fieldModifier from:(MIXWORD)src
{
	// special cases will be processed first
	if (fieldModifier == MIX_F_FIELD) {
		return src;
	}
	MIXWORD result;
	result.sign = NO;			// it is set yo YES when initialized
	for (int i = 0; i < MIX_WORD_SIZE; i++) result.byte[i] = 0;
	if (fieldModifier == MIX_F_SIGNONLY) {
		result.sign = src.sign;
	} else {
		// complex case - should analyze fields
		int leftPos = (fieldModifier >> 3) & 0x7;
		int rightPos = fieldModifier & 0x7;
		if (rightPos < leftPos) {
			[NSException raise:MIXExceptionInvalidFieldModifer
						format:RStr(MIXExceptionInvalidFieldModifer)];
		}
		if (leftPos == 0) {
			// sign should be copied
			result.sign = src.sign;
			leftPos = 1;
		}
		// now we'll select fields and place them to the right side
		rightPos--;				// option base 0 in internal representation
		leftPos--;
		int outputPos = 4;		// last element
		for (int i = rightPos; i >= leftPos; i--) {
			result.byte[outputPos--] = src.byte[i];
		}
	}
	return result;
}

//
// Calculates effective address (memory cell index) from the J register
// sign bit is not used, this is a pointer to absolute address
//
- (NSInteger) executionAddr
{
	Byte left = jumpRegister.indexByte[0];
	Byte right = jumpRegister.indexByte[1];
	NSInteger address;
	address = left << (self.sixBitByte ? 6 : 8);
	address += right;
	
	//
	// Sanity check - wrap around memory_size
	//
	address = address % MIX_MEMORY_SIZE;

	return address;
}

//
// Calculates effective address of the data to be used in command
// supplied in argument
//
- (NSInteger) effectiveAddress:(MIXWORD) command
{
	Byte addrLeft = command.byte[0];
	Byte addrRight = command.byte[1];
	NSInteger address = addrLeft << (self.sixBitByte ? 6 : 8);
	address += addrRight;
	if (command.sign) {
		address = - address;
	}
	// apply index register if any
	Byte index = command.byte[2];
	if (index > 0) {
		if (index > MIX_INDEX_REGISTERS) {
			[NSException raise:MIXExceptionInvalidIndexRegister
						format:RStr(MIXExceptionInvalidIndexRegister)];
			return -10000;
		}
		MIXINDEX indexValue = [self indexRegisterValue:index];
		NSInteger ind = indexValue.indexByte[0] << (self.sixBitByte ? 6 : 8);
		ind += indexValue.indexByte[1];
		if (indexValue.sign) {
			ind = -ind;
		}
		address += ind;
	}
	return address;
}



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
