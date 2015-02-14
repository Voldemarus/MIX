//
//  MIXCPU.h
//  MixMac
//
//  Created by Водолазкий В.В. on 14.02.15.
//  Copyright (c) 2015 Geomatix Laboratoriess S.R.O. All rights reserved.
//

#import <Foundation/Foundation.h>

// Byte* -- local byte interpretation, per Knuth' original text byte contains 6 bits
//			In this implemetation we can switch between 6 and 8 bits. To emphasize usage
//			of local byte definiton asterisk is used.

#define MIX_WORD_SIZE		5				// Machine word size (in bytes*)
#define MIX_MEMORY_SIZE		4000			// Memory size

#define MIX_INDEX_REGISTERS	6				// amount of index registers in CPU

#define MIX_IO_CHANNELS		20				// Total amount of i/o channels

#define MT_AMOUNT			8				// Magnetic tapes / sequential read/write
#define MT_START			0
#define	MD_AMOUNT			8				// Magnetic disks / random i/o
#define MD_OFFSET			MT_AMOUNT
#define PUNCH_READER		(MT_AMOUNT+MD_AMOUNT)		// punchcard reader
#define PUNCH_WRITER		(PUNCH_READER+1)			// punchcard writer
#define PRINTER				(PUNCH_WRITER+1)			// printer
#define PERFOLENTA			(PRINTER+1)					// punch ribbon

// Memeory cell consists of 5 bytes and sign
typedef struct {
	BOOL sign;
	Byte byte[MIX_WORD_SIZE];
} MIXWORD;

// index Register consists of two bytes and sign - it is enough to address any cell in
// current memory space
typedef struct {
	BOOL sign;
	Byte indexByte[2];
} MIXINDEX;

// Comparasion flag register can get one of three meaningful values
typedef enum
{
	MIX_NOT_SET	=	-100,
	MIX_LESS	=	-1,
	MIX_EQUAL,
	MIX_GREATER,
} MIX_COMPARASION;


@interface MIXCPU : NSObject

@property (nonatomic, readwrite) BOOL sixBitByte;		// YES - 6 bit in bye, NO - 8 bit

// set and get works in COPY mode.  
@property (nonatomic, readwrite) MIXWORD A;				// accumulator
@property (nonatomic, readwrite) MIXWORD X;				// extension register


@property (nonatomic, readwrite) MIXINDEX index1;		// helpers - to fast incex access
@property (nonatomic, readwrite) MIXINDEX index2;
@property (nonatomic, readwrite) MIXINDEX index3;
@property (nonatomic, readwrite) MIXINDEX index4;
@property (nonatomic, readwrite) MIXINDEX index5;
@property (nonatomic, readwrite) MIXINDEX index6;

@property (nonatomic, readwrite) MIXINDEX J;			// Jump address register

@property (nonatomic, readonly)		BOOL overflow;		// overflow indocator
@property (nonatomic, readonly) MIX_COMPARASION flag;	// comparasion result flag



+ (MIXCPU *) sharedInstance;


- (void) resetCPU;										// clear memory and registers




// memory cells access. Data is copied from the CPU' memory
- (void) setMemoryWord:(MIXWORD)aWord forCellIndex:(int) index;
- (MIXWORD) memoryWordForCellIndex:(int) index;

// access to index registers by their number [1..MIX_INDEX_REGISTERS]
- (void) setIndexRegister:(MIXINDEX) aValue withNumber:(int)aIndex;
- (MIXINDEX) indexRegisterValue:(int)aIndex;

@end
