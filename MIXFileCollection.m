//
//  MIXSeqFile.m
//  MixMac
//
//  Created by Водолазкий В.В. on 03.03.15.
//  Copyright (c) 2015 Geomatix Laboratoriy S.R.O. All rights reserved.
//


#import "MIXFileCollection.h"

#import "MIXCPU.h"
#import "DebugPrint.h"


// NSCoding protocol identifiers

NSString * const MIX_SEQ_FILE_POSITION	=	@"MIX_SEQ_FILE_POSITION";
NSString * const MIX_SEQ_FILE_SIZE		=	@"MIX_SEQ_FILE_SIZE";
NSString * const MIX_SEQ_FILE_BLOCKSIZE	=	@"MIX_SEQ_FILE_BLOCKSIZE";
NSString * const MIX_SEQ_FILE_DEVNAME	=	@"MIX_SEQ_FILE_DEVNAME";
NSString * const MIX_SEQ_FILE_BLOCK_NO	=	@"MIX_SEQ_FILE_BLOCK_NO_";
NSString * const MIX_SEQ_FILE_WORD		=	@"MSW";


@interface MIXSeqFile () {
}
@property (nonatomic, readwrite) 	MIXWORD *block;	// pointer to current block of MIXWORDs


@end


@implementation MIXSeqFile

@synthesize fileSize, filePosition, blockSize;
@synthesize deviceName;


#pragma mark - NSCopying -

- (id)copyWithZone:(NSZone *)zone
{
	MIXSeqFile *newFile = [[MIXSeqFile alloc] init];
	newFile.filePosition = self.filePosition;
	newFile.fileSize = self.fileSize;
	newFile.blockSize = self.blockSize;
	newFile.deviceName = self.deviceName;
	newFile.block = malloc(self.fileSize + 100 * self.blockSize);
	if (self.fileSize > 0) {
		memcpy(newFile.block, self.block, sizeof(MIXWORD)*self.fileSize);
	}
	return newFile;
}

- (void) closeFile
{
	free(self.block);
}
						   
#pragma mark - NSCoding -

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super init];
	self.fileSize = [decoder decodeIntegerForKey:MIX_SEQ_FILE_SIZE];
	self.filePosition = [decoder decodeIntegerForKey:MIX_SEQ_FILE_POSITION];
	self.blockSize = [decoder decodeIntegerForKey:MIX_SEQ_FILE_BLOCKSIZE];
	self.deviceName = [decoder decodeObjectForKey:MIX_SEQ_FILE_DEVNAME];
	// set up small reserve
	self.block = malloc(sizeof(MIXWORD) * (self.fileSize + 100 * self.blockSize));
	for (NSInteger i = 0; i < self.fileSize; i++) {
		NSString *bf = [NSString stringWithFormat:@"%@%ld",MIX_SEQ_FILE_WORD,(long)i];
		MIXWORD cWord = [self decodeMixWord:decoder withKey:bf];
		MIXWORD blockWord = self.block[i];
		blockWord.sign = cWord.sign;
		for (int k = 0; k < MIX_WORD_SIZE; k++) {
			blockWord.byte[i] = cWord.byte[i];
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeInteger:self.filePosition forKey:MIX_SEQ_FILE_POSITION];
	[encoder encodeInteger:self.fileSize forKey:MIX_SEQ_FILE_SIZE];
	[encoder encodeObject:self.deviceName forKey:MIX_SEQ_FILE_DEVNAME];
	[encoder encodeInteger:self.blockSize forKey:MIX_SEQ_FILE_BLOCKSIZE];
}

- (MIXWORD) decodeMixWord:(NSCoder *)aDecoder withKey:(NSString *)key
{
	MIXWORD result;
	NSString *signFormat = [NSString stringWithFormat:@"%@_sign",key];
	result.sign = [aDecoder decodeBoolForKey:signFormat];
	for (int i = 0; i < MIX_WORD_SIZE; i++) {
		NSString *byteFormat = [NSString stringWithFormat:@"%@_b_%d",key,i];
		// Strip eventual high bits to keep proper byte value
		result.byte[i] = [aDecoder decodeIntForKey:byteFormat] & 0xFF;
	}
	return result;
}

- (void) encodeMixWord:(MIXWORD) mixWord inCoder:(NSCoder *)aCoder withKey:(NSString *)key
{
	NSString *signFormat = [NSString stringWithFormat:@"%@_sign",key];
	[aCoder encodeBool:mixWord.sign forKey:signFormat];
	for (int i = 0; i < MIX_WORD_SIZE; i++) {
		NSString *byteFormat = [NSString stringWithFormat:@"%@_b_%d",key,i];
		[aCoder encodeInt:mixWord.byte[i] forKey:byteFormat];
	}
}


@end


#pragma mark -

NSString * const MIX_FILE_COLLECTION	=	@"MIX_FILE_COLLECTION";
NSString * const MIX_SEQ_FILE_ID		=	@"MIX_SEQ_FILE_ID_";
NSString * const MIX_SEQ_FILE_COUNT		=	@"MIX_SEQ_FILE_COUNT";


@interface MIXFileCollection () {
	NSMutableArray *fileCollection;		// array with sequential and direct access device files
}

- (id) initWithArray:(NSArray *)deviceArray;

@property (nonatomic, readonly) NSArray *fileCollection;

@end



@implementation MIXFileCollection

- (id) initWithArray:(NSArray *)deviceArray
{
	if (self = [super init]) {
		if (deviceArray) {
			fileCollection = [[NSMutableArray alloc] initWithArray:deviceArray copyItems:YES];
		}
	}
	return self;
}

+ (NSDictionary *) deviceParameters
{
	// Device Name : [ Starting unit number, amount of devices,  Block Size, , Direction, Symbol format, Description ]
	return @{
			 DEVICE_MT  : @[@(MT_START), @(MT_AMOUNT), @(100), @(StreamDirectonReadWrite), @NO, @"Magnetic Tape"],
			 DEVICE_MD  : @[@(MD_OFFSET), @(MD_AMOUNT), @(100),@(StreamDirectonReadWrite), @NO, @"Magnetic Disk"],
			 DEVICE_PNR : @[@(PUNCH_READER), @(1), @(16), @(StreamDirectionInput), @YES, @"Punch card reader"],
			 DEVICE_PNW : @[@(PUNCH_WRITER), @(1), @(16), @(StreamDirectionOutput), @NO, @"Punch card writer"],
			 DEVICE_LPR : @[@(PRINTER), @(1), @(24), @(StreamDirectionOutput), @YES, @"Line Printer"],
			 DEVICE_CON : @[@(CONSOLE), @(1), @(14), @(StreamDirectonReadWrite), @YES, @"Console teletype"],
			 DEVICE_RIB : @[@(PERFOLENTA), @(1), @(14), @(StreamDirectonReadWrite), @YES, @"Perforated ribbon"],
			 };
}

/**
 Returns record, which corresponds to given FileHandler
 */
+ (NSDictionary *) deviceByFileHandler:(NSInteger) fh
{
	if (fh < MT_START || fh > PERFOLENTA) {
		// Invlaid file handler
		[NSException raise:MIXExceptionInvalidFileHandler
					format:RStr(MIXExceptionInvalidFileHandler)];
		return nil;
	}
	NSString *key = DEVICE_RIB;
	if (fh < MD_OFFSET) {
		key = DEVICE_MT;
	} else if (fh < PUNCH_READER) {
		key = DEVICE_MD;
	} else if (fh < PUNCH_WRITER) {
		key = DEVICE_PNR;
	} else if (fh < PRINTER) {
		key = DEVICE_PNW;
	} else if (fh < CONSOLE) {
		key = DEVICE_LPR;
	} else if (fh < PERFOLENTA) {
		key = DEVICE_CON;
	}
	return @{
			 key : [[MIXFileCollection deviceParameters] objectForKey:key],
			 };
}


- (NSArray *) fileCollection
{
	return [NSArray arrayWithArray:fileCollection];
}

#pragma mark - NSCopying -

- (id) copyWithZone:(NSZone *)zone
{
	MIXFileCollection *copy = [[MIXFileCollection alloc] initWithArray:self.fileCollection];
	return copy;
}

#pragma mark - NSCoding -

- (void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:fileCollection forKey:MIX_FILE_COLLECTION];
}


- (id)initWithCoder:(NSCoder *)decoder
{
	NSArray *dataArray = [decoder decodeObjectForKey:MIX_FILE_COLLECTION];
	self = [self initWithArray:dataArray];
	return self;
}

@end

