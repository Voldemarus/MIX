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
#import "MIXExceptions.h"


// NSCoding protocol identifiers

NSString * const MIX_SEQ_FILE_POSITION	=	@"MIX_SEQ_FILE_POSITION";
NSString * const MIX_SEQ_FILE_SIZE		=	@"MIX_SEQ_FILE_SIZE";
NSString * const MIX_SEQ_FILE_BLOCKSIZE	=	@"MIX_SEQ_FILE_BLOCKSIZE";
NSString * const MIX_SEQ_FILE_DEVNAME	=	@"MIX_SEQ_FILE_DEVNAME";
NSString * const MIX_SEQ_FILE_BLOCK_NO	=	@"MIX_SEQ_FILE_BLOCK_NO_";
NSString * const MIX_SEQ_FILE_WORD		=	@"MSW";
NSString * const MIX_SEQ_FILE_DEVCODE	=	@"MSDCODE";
NSString * const MIX_SEQ_FILE_DEVNUM	=	@"MSCDEVNUM";


@interface MIXSeqFile () {
	NSInteger handlerNumber;
	
}
@property (nonatomic, readwrite) 	MIXWORD *block;	// pointer to file content of MIXWORDs

/**
 Creates instance of file with parameters, defined in MixFileCollection
 */
- (instancetype) initFileWithParameters:(NSDictionary *)parameters;


@end


@implementation MIXSeqFile

@synthesize fileSize, filePosition, blockSize;
@synthesize deviceName;

/**
 Dictionary:
 		MIX_SEQ_FILE_DEVCODE	:		DEVICE_NAME_KEY
 		MIX_SEQ_FILE_DEVNUM		:		0..MAXAMOUNT for given DEVICE_NAME_KEY
 		DEVICE_NAME_KEY			:		@[Array from deviceParameters]
 
 
 */
- (instancetype) initFileWithParameters:(NSDictionary *)parameters
{
	if (self = [super init]) {
		self.filePosition = 0;
		NSString *devKey = [parameters[MIX_SEQ_FILE_DEVCODE] uppercaseString];
		NSInteger devNum = [parameters[MIX_SEQ_FILE_DEVNUM] integerValue];
		NSArray *params = parameters[devKey];
		if (!params) {
			return nil;
		}
		NSInteger startNum = [params[0] integerValue];		// Minimal fileHandler num
		NSInteger maxAmount = [params[1] integerValue];		// Total amount of devices
		self.blockSize = [params[2] integerValue];
		_direction = [params[3] integerValue];
		_charIO = [params[4] boolValue];
		if (devNum < 0 || devNum >= maxAmount) {
			// invalid device number !
			[NSException raise:MIXExceptionInvalidDeviceNumber format:RStr(MIXExceptionInvalidDeviceNumber)];
			return nil;
		}
		handlerNumber = startNum + devNum;
		if (startNum < PUNCH_READER) {
			self.deviceName = [NSString stringWithFormat:@"%@%ld", devKey,(long)devNum];
		} else {
			// Do not add device number for unique devices like CON, LPR
			self.deviceName = devKey;
		}
		self.filePosition = 0;
		self.fileSize = 0;
	}
	return self;
}


+ (MIXSeqFile *) createWithKey:(NSString *)aDevName andNum:(NSInteger) aNum
{
	NSArray *parameters = [[MIXFileCollection deviceParameters] objectForKey:aDevName];
	if (!parameters) {
		return nil;
	}
	NSDictionary *params = @{
							 MIX_SEQ_FILE_DEVCODE	:	aDevName,
							 MIX_SEQ_FILE_DEVNUM	:	@(aNum),
							 aDevName				:	parameters,
							 };
	MIXSeqFile *file = [[MIXSeqFile alloc] initFileWithParameters:params];
	return file;
}

+ (instancetype) createMTFilewithDevice:(NSInteger) mtNum
{
	return [MIXSeqFile createWithKey:DEVICE_MT andNum:mtNum];
}

+ (instancetype) createMDFileWithDevice:(NSInteger) mdNum
{
	return [MIXSeqFile createWithKey:DEVICE_MD andNum:mdNum];
}

+ (instancetype) createPunchReader
{
	return [MIXSeqFile createWithKey:DEVICE_PNR andNum:0];
}

+ (instancetype) createPunchWriter
{
	return [MIXSeqFile createWithKey:DEVICE_PNW andNum:0];
}

+ (instancetype) createLinePrinter
{
	return [MIXSeqFile createWithKey:DEVICE_LPR andNum:0];
}

+ (instancetype) createConsole
{
	return [MIXSeqFile createWithKey:DEVICE_CON andNum:0];
}

+ (instancetype) createPerfolenta
{
	return [MIXSeqFile createWithKey:DEVICE_RIB andNum:0];
}


- (NSInteger) fileHandler
{
	return handlerNumber;
}

- (void) closeFile
{
	free(self.block);
}


- (MIXWORD *) readBlock
{
	MIXWORD *blockArray = malloc(sizeof(MIXWORD)*self.blockSize);
	if (!blockArray) {
		return nil;
	}
	memset(blockArray, 0, sizeof(MIXWORD)*self.blockSize);
	NSInteger endOfBlock = self.filePosition + self.blockSize;
	if (endOfBlock >= self.fileSize) {
		endOfBlock = self.fileSize;
	}
	int destOffset = 0;
	for (NSInteger i = self.filePosition; i < endOfBlock; i++) {
		[self copyMixWord:&self.block[i] toNewMixWord:&blockArray[destOffset++]];
	}
	self.filePosition = endOfBlock;
	return blockArray;
}

/**
 	filePosition is set to MIXWORD offset, but newPosition argument points to block number
 */
- (void) rewindToPosition:(NSInteger) newPosition
{
	if (newPosition <= 0) {
		self.filePosition = 0;
	} else {
		NSInteger blockOffset = newPosition * self.blockSize;
		if (self.fileSize < blockOffset) {
			// set up to the eof position
			self.filePosition = self.fileSize;
		} else {
			self.filePosition = blockOffset;
		}
	}
}

/**
 	Due to file is sequential, when write operation is finished file size will be truncated
 	to the current position, so EOF will be set
 
 */
- (void) writeBlock:(MIXWORD *)aBlock
{
	NSInteger finalPosition = self.filePosition + self.blockSize;
	if (finalPosition > self.fileSize) {
		if (self.block) {
			// Not enough memory allocated, assign more
			self.block = realloc(self.block, (self.fileSize+self.blockSize)*sizeof(MIXWORD));
		} else {
			self.block = malloc(self.blockSize * sizeof(MIXWORD));
		}
	}
	for (NSInteger i = 0; i < self.blockSize; i++) {
		[self copyMixWord:&aBlock[i] toNewMixWord:&self.block[self.fileSize+i]];
	}
	self.fileSize += self.blockSize;
	self.filePosition = self.fileSize;
	NSLog(@"### file-size - %.ld file-position - %ld", self.fileSize, self.filePosition);
}

- (BOOL) bof
{
	return (self.filePosition == 0);
}

- (BOOL) eof
{
	return (self.filePosition >= self.fileSize);
}

#pragma mark - Import/Export

- (void) fillReadBufferWithBlockData:(MIXWORD *)blockData
{
	
}

- (BOOL) importDataFromFile:(NSString *)path
{
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:path] == NO) {
		return NO;
	}
	NSData *data = [[NSData alloc] initWithContentsOfFile:path];
	// try to convert into proper data
	NSError *error = nil;
	MIXSeqFile *loaded = [NSKeyedUnarchiver unarchivedObjectOfClass:[MIXSeqFile class]
														   fromData:data error:&error];
	if (loaded) {
		// copy data from these copy to the current file
		
	}
	return NO;
}

- (BOOL) exportDataToFile:(NSString *) path asChar:(BOOL)aschar
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error = nil;
	if ([fm fileExistsAtPath:path]) {
		[fm removeItemAtPath:path error:&error];
		if (error) {
			NSLog(@"Cannot remove old data file - %@ --> %@", path, [error localizedDescription]);
#warning TODO error processing!
			return NO;
		}
	}
	if (self.fileSize == 0) {
		// file is empty no need to save it at all
		return YES;
	}
	if (aschar) {
		// Save file as ordinary char file
		NSMutableString *resultString = [NSMutableString new];
		for (NSInteger i = 0; i < self.fileSize; i++) {
			MIXWORD m = self.block[i];
			[resultString appendString:[MIXCPU charsFromWord:m]];
		}
		[resultString writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:&error];
		return (error == nil);
	} else {
		// this is binary file, save as simple data stream, based on NSCoder protocol
		NSData *saveData = [NSKeyedArchiver archivedDataWithRootObject:self requiringSecureCoding:YES error:&error];
        if (error) {
#ifdef DEBUG
            NSLog(@"Cannot encode data for storing - %@", [error  localizedDescription]);
#endif
            return NO;
        }
		BOOL result = [saveData writeToFile:path atomically:NO];
		return result;
	}
}



#pragma mark - NSCopying -

- (id)copyWithZone:(NSZone *)zone
{
	MIXSeqFile *newFile = [[MIXSeqFile alloc] init];
	newFile.filePosition = self.filePosition;
	newFile.fileSize = self.fileSize;
	newFile.blockSize = self.blockSize;
	newFile.deviceName = self.deviceName;
	newFile.block = malloc(self.fileSize );
	if (self.fileSize > 0) {
		memcpy(newFile.block, self.block, sizeof(MIXWORD)*self.fileSize);
	}
	return newFile;
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
	self.block = malloc(sizeof(MIXWORD) * self.fileSize);
	for (NSInteger i = 0; i < self.fileSize; i++) {
		NSString *bf = [NSString stringWithFormat:@"%@%ld",MIX_SEQ_FILE_WORD,(long)i];
		MIXWORD cWord = [self decodeMixWord:decoder withKey:bf];
		[self copyMixWord:&cWord toNewMixWord:&self.block[i]];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeInteger:self.filePosition forKey:MIX_SEQ_FILE_POSITION];
	[encoder encodeInteger:self.fileSize forKey:MIX_SEQ_FILE_SIZE];
	[encoder encodeObject:self.deviceName forKey:MIX_SEQ_FILE_DEVNAME];
	[encoder encodeInteger:self.blockSize forKey:MIX_SEQ_FILE_BLOCKSIZE];
	for (NSInteger i = 0; i < self.fileSize; i++) {
		NSString *bf = [NSString stringWithFormat:@"%@%ld",MIX_SEQ_FILE_WORD,(long)i];
		[self encodeMixWord:self.block[i] inCoder:encoder withKey:bf];
	}
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

/**
 	value is malloced, don't forget to free !
 */
- (MIXWORD *) createMixWordCopy:(MIXWORD) old
{
	MIXWORD *new = malloc(sizeof(MIXWORD));
	if (new) {
		new->sign = old.sign;
		for (int i = 0; i < MIX_WORD_SIZE; i++) {
			new->byte[i] = old.byte[i];
		}
	}
	return new;
}

- (void) copyMixWord:(MIXWORD *) old toNewMixWord:(MIXWORD *)newWord
{
	newWord->sign = old->sign;
	for (int i = 0; i < MIX_WORD_SIZE; i++) {
		newWord->byte[i] = old->byte[i];
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


@end



@implementation MIXFileCollection


+ (MIXFileCollection *) sharedCollection
{
	static MIXFileCollection *__collection = nil;
	if (!__collection) {
		__collection = [[MIXFileCollection alloc] initWithArray:nil];
	}
	return __collection;
}


- (id) initWithArray:(NSArray *)deviceArray
{
	if (self = [super init]) {
		if (deviceArray) {
			fileCollection = [[NSMutableArray alloc] initWithArray:deviceArray copyItems:YES];
		} else {
			fileCollection = [NSMutableArray new];
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

- (void) addFile:(MIXSeqFile *)file
{
	MIXSeqFile *present = [self fileByName:file.deviceName];
	if (!present) {
		[fileCollection addObject:file];
	}
}
- (void) closeFile:(MIXSeqFile *) file
{
	MIXSeqFile *present = [self fileByName:file.deviceName];
	if (!present) {
		[present closeFile];
		[fileCollection removeObject:present];
	}
}

- (MIXSeqFile *) fileByName:(NSString *)fileName
{
	for (MIXSeqFile *mf in fileCollection) {
		if ([mf.deviceName isEqualToString:fileName]) {
			return mf;
		}
	}
	return nil;
}

- (MIXSeqFile *) fileByHandler:(NSInteger) fileHandler
{
	for (MIXSeqFile *mf in fileCollection) {
		if (mf.fileHandler == fileHandler) {
			return mf;
		}
	}
	return nil;
}

- (void) clearFileCollection
{
	for (MIXSeqFile *mf in fileCollection) {
		[self closeFile:mf];
	}
	[fileCollection removeAllObjects];
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

