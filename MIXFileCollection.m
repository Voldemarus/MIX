//
//  MIXSeqFile.m
//  MixMac
//
//  Created by Водолазкий В.В. on 03.03.15.
//  Copyright (c) 2015 Geomatix Laboratoriy S.R.O. All rights reserved.
//


#import "MIXFileCollection.h"

#import "MIXCPU.h"

// NSCoding protocol identifiers

NSString * const MIX_SEQ_FILE_POSITION	=	@"MIX_SEQ_FILE_POSITION";
NSString * const MIX_SEQ_FILE_SIZE		=	@"MIX_SEQ_FILE_SIZE";
NSString * const MIX_SEQ_FILE_BLOCKSIZE	=	@"MIX_SEQ_FILE_BLOCKSIZE";
NSString * const MIX_SEQ_FILE_DEVNAME	=	@"MIX_SEQ_FILE_DEVNAME";

@interface MIXSeqFile () {
	MIXWORD *block;				// pointer to current block of MIXWORDs
}

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
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeInteger:self.filePosition forKey:MIX_SEQ_FILE_POSITION];
	[encoder encodeInteger:self.fileSize forKey:MIX_SEQ_FILE_SIZE];
	[encoder encodeObject:self.deviceName forKey:MIX_SEQ_FILE_DEVNAME];
	[encoder encodeInteger:self.blockSize forKey:MIX_SEQ_FILE_BLOCKSIZE];
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


- (NSArray *) deviceParameters
{
	// Device Name, Starting unit number, amount of devices,  Block Size, Description
	return @[
			 @[@"MT", @(MT_START), @(MT_AMOUNT), @(100), @"Magnetic Tape"],
			 @[@"MD", @(MD_OFFSET), @(MD_AMOUNT), @(100), @"Magnetic Disk"],
			 @[@"PNR", @(PUNCH_READER), @(1), @(16), @"Punch card reader"],
			 @[@"PNW", @(PUNCH_WRITER), @(1), @(16), @"Punch card writer"],
			 @[@"LPR", @(PRINTER), @(1), @(24), @"Line Printer"],
			 @[@"CON", @(CONSOLE), @(1), @(14), @"Console teletype"],
			 @[@"RIB", @(PERFOLENTA), @(1), @(14), @"Perforated ribbon"],
			 ];
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

