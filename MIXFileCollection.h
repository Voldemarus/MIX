//
//  MIXSeqFile.h
//  MixMac
//
//  Created by Водолазкий В.В. on 03.03.15.
//  Copyright (c) 2015 Geomatix Laboratoriy S.R.O. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIXCPU.h"

typedef NS_ENUM(NSInteger, StreamDirection) {
	StreamDirectionInput = 0,
	StreamDirectionOutput,
	StreamDirectonReadWrite,
};


// Sequential file (magnetic tape
@interface MIXSeqFile : NSObject  <NSCopying, NSCoding>

@property (nonatomic, readwrite) NSInteger fileSize;		// total size in MIXWORDS
@property (nonatomic, readwrite) NSInteger filePosition;	// active block number
@property (nonatomic, readwrite) NSInteger blockSize;		// size of block in MIXWORDs
@property (nonatomic, retain) NSString *deviceName;			// full device name, ex. MT1, MD3, PRN

@property (nonatomic, readonly) NSInteger fileHandler;		// file Handler
@property (nonatomic, readonly) StreamDirection direction;
@property (nonatomic, readonly) BOOL charIO;				// YES - caracters, NO - binary

@property (nonatomic, readonly) BOOL eof;					// end of file reached during read
@property (nonatomic, readonly) BOOL bof;					// writer head is set to the beginning of file


/**
 	Creates instance of file with parameters, defined in MixFileCollection
 */
- (instancetype) initFileWithParameters:(NSDictionary *)parameters;


// Designated constructors

- (instancetype) initMTFilewithDevice:(NSInteger) mtNum;
- (instancetype) initMDFileWithDevice:(NSInteger) mdNum;
- (instancetype) initPunchReader;
- (instancetype) initPunchWriter;
- (instancetype) initLinePrinter;
- (instancetype) initConsole;
- (instancetype) initPerfolenta;


/**
 	pointer to current block, pointed by file handler
 */
@property (nonatomic, readwrite)  MIXWORD *currentBlock;

/**
 	Should be called on each file at the end of processing to free allocated memory
 */
- (void) closeFile;

/**
 	Read block from the current position. Non complete block is filled with zero MIX words at the end.
 */
- (MIXWORD *) readBlock;

/**
 	Write block at the current position. Automatically increase if end of current buffer is reached.
 */
 - (void) writeBlock:(MIXWORD *)aBlock;

/**
 	Rewind file to desired position.
 */
- (void) rewindToPosition:(NSInteger) newPosition;

@end



@interface MIXFileCollection : NSObject  <NSCopying, NSCoding>

+ (NSDictionary *) deviceParameters;	// Returns list with device parameters

@end
