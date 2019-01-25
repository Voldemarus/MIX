//
//  MixSeqFileTest.m
//  MixMacTests
//
//  Created by Водолазкий В.В. on 30/12/2018.
//  Copyright © 2018 Geomatix Laboratoriy S.R.O. All rights reserved.
//


#import "MIXFileCollection.h"

#import "MIXTest.h"

@interface MixSeqFileTest : MIXTest
{
	MIXFileCollection *collection;
}

@end

@implementation MixSeqFileTest

- (void)setUp {
	collection = [MIXFileCollection sharedCollection];
	XCTAssert(collection, @"Collection singleton should be created");
	
	// Create set of MT devices
	for (NSInteger i = 0; i < MT_AMOUNT; i++) {
		MIXSeqFile *mtFile = [MIXSeqFile createMTFilewithDevice:i];
		XCTAssertTrue(mtFile.fileHandler == i, @"MT handlers should be in range 0..%ld but %ld is assigned to %@", (long)MT_AMOUNT, (long)mtFile.fileHandler, mtFile.deviceName);
		NSString *expectedName = [NSString stringWithFormat:@"MT%ld",(long)i];
		XCTAssertEqual(expectedName, mtFile.deviceName, @"Expected name is not found - %@ instead of %@", mtFile.deviceName, expectedName);
		[collection addFile:mtFile];
	}
	XCTAssertTrue(collection.fileCollection.count == MT_AMOUNT, @"Amount of devices in collection should be equal to %ld", (long)MT_AMOUNT);
	
	// Create set of MD devices
	for (NSInteger i = 0; i < MD_AMOUNT; i++) {
		MIXSeqFile *mtFile = [MIXSeqFile createMDFileWithDevice:i];
		XCTAssertTrue(mtFile.fileHandler == (MD_OFFSET+i), @"MD handlers should be in range %ld..%ld but %ld is assigned to %@",
					  (long)MD_OFFSET, (long)(MD_OFFSET+MD_AMOUNT), (long)mtFile.fileHandler, mtFile.deviceName);
		NSString *expectedName = [NSString stringWithFormat:@"MD%ld",(long)i];
		XCTAssertEqual(expectedName, mtFile.deviceName, @"Expected name is not found - %@ instead of %@", mtFile.deviceName, expectedName);
		[collection addFile:mtFile];
	}
	XCTAssertTrue(collection.fileCollection.count == (MD_AMOUNT + MT_AMOUNT), @"Amount of devices in collection should be equal to %ld", (long)MT_AMOUNT+MD_AMOUNT);
	
	MIXSeqFile *punchReader = [MIXSeqFile createPunchReader];
	XCTAssert(punchReader,@"Punch reader file should be created");
	XCTAssertTrue(punchReader.fileHandler == PUNCH_READER,@"file handler should have proper value");
	XCTAssert([punchReader.deviceName isEqualToString:DEVICE_PNR], @"Name should be equal to %@", DEVICE_PNR);
	[collection addFile:punchReader];
	
	MIXSeqFile *punchWriter = [MIXSeqFile createPunchWriter];
	XCTAssert(punchWriter,@"Punch writer file should be created");
	XCTAssertTrue(punchWriter.fileHandler == PUNCH_WRITER,@"file hanfndler should have proper value");
	XCTAssertTrue([punchWriter.deviceName isEqualToString:DEVICE_PNW], @"Name should be equal to %@", DEVICE_PNW);
	[collection addFile:punchWriter];
	
	MIXSeqFile *printer = [MIXSeqFile createLinePrinter];
	XCTAssert(printer,@"Printer file should be created");
	XCTAssertTrue(printer.fileHandler == PRINTER,@"file hanfndler should have proper value");
	XCTAssertTrue([printer.deviceName isEqualToString:DEVICE_LPR], @"Name should be equal to %@", DEVICE_LPR);
	[collection addFile:printer];
	
	MIXSeqFile *console = [MIXSeqFile createConsole];
	XCTAssert(console,@"Console file should be created");
	XCTAssertTrue(console.fileHandler == CONSOLE,@"file hanfndler should have proper value");
	XCTAssertTrue([console.deviceName isEqualToString:DEVICE_CON], @"Name should be equal to %@", DEVICE_CON);
	[collection addFile:console];
	
	MIXSeqFile *ribbon = [MIXSeqFile createPerfolenta];
	XCTAssert(ribbon,@"Perfolenta file should be created");
	XCTAssertTrue(ribbon.fileHandler == PERFOLENTA,@"file hanfndler should have proper value");
	XCTAssertTrue([ribbon.deviceName isEqualToString:DEVICE_RIB], @"Name should be equal to %@", DEVICE_RIB);
	[collection addFile:ribbon];
	
	XCTAssertTrue(collection.fileCollection.count == PERFOLENTA+1, @"All devices should be initialised");
	
}
/**
 	Ribbon R/W device test.
 */

- (void) testRibbon
{
	MIXSeqFile *ribbon = [collection fileByName:DEVICE_RIB];
	XCTAssert(ribbon, @"File should be presented in file collection");
	
	NSArray *fileParams = [[MIXFileCollection deviceParameters] objectForKey:DEVICE_RIB];
	XCTAssert(fileParams, @"File parameters should be defined");
	
	XCTAssertTrue(ribbon.blockSize == [fileParams[2] integerValue], @"Block sie should be eaual to reference value");
	XCTAssertTrue(ribbon.direction == [fileParams[3] integerValue], @"Direction should be the same as in parameters");
	XCTAssertTrue(ribbon.charIO == [fileParams[4] boolValue], @"Character mode should be the same as in parameters");
	XCTAssertTrue(ribbon.charIO == YES, @"Ribbon is char oriented device");
	
	// Test #1 Write block to the device
	XCTAssertTrue(ribbon.bof == YES, @"Empty file. BOF state should be ON");
	XCTAssertTrue(ribbon.eof == YES, @"Empty file, EOF state should be ON");
	
	MIXWORD *testBlock = calloc(ribbon.blockSize, sizeof(MIXWORD));
	
	for (int i = 0; i < ribbon.blockSize; i++) {
		testBlock[i] = [self mixWordFromInteger:i];
//		[self printMemoryCell:testBlock[i]];
	}
	[ribbon writeBlock:testBlock];
	XCTAssertTrue(ribbon.bof == NO, @"After write operation BOF should be NO");
	XCTAssertTrue(ribbon.eof == YES, @"After write operation, EOF state should be ON");
	XCTAssertTrue(ribbon.filePosition == ribbon.blockSize, @"File offset should be equal to blocksize");
	
	// rewind to the start
	[ribbon rewindToPosition:0];
	XCTAssertTrue(ribbon.bof == YES, @"After rewind to start BOF should be YES");
	XCTAssertTrue(ribbon.eof == NO, @"After write operation, EOF state should be ON");

	MIXWORD *readBack = [ribbon readBlock];
	XCTAssert(readBack, @"Block should be read from the device");
	[self compareBlock:testBlock withBlock:readBack size:ribbon.blockSize];
	
	XCTAssertTrue(ribbon.eof == YES, @"EOF status should be set");
	XCTAssertTrue(ribbon.bof == NO, @"BOF status should be off");
	XCTAssertTrue(ribbon.filePosition == ribbon.blockSize, @"Pointer should be set to 1 block offset");
	
	// write anothe block
	MIXWORD *testBlock2 = calloc(ribbon.blockSize, sizeof(MIXWORD));
	
	for (int i = 0; i < ribbon.blockSize; i++) {
		testBlock2[i] = [self mixWordFromInteger:256+i];
	}
	[ribbon writeBlock:testBlock2];
	XCTAssertTrue(ribbon.eof == YES, @"EOF status should be set");
	XCTAssertTrue(ribbon.filePosition == ribbon.blockSize*2, @"Pointer should be set to end of the second block");

	[ribbon rewindToPosition:1];
	XCTAssertTrue(ribbon.filePosition == ribbon.blockSize, @"Pointer should be set to end of the first block");
	XCTAssertTrue(ribbon.eof == NO, @"EOF status should not be set");
	XCTAssertTrue(ribbon.bof == NO, @"BOF status should not be set");
	
	// read second block back
	if (readBack) {
		free(readBack);
	}
	readBack = [ribbon readBlock];
	XCTAssert(readBack, @"Block should be read from the device");
	[self compareBlock:testBlock2 withBlock:readBack size:ribbon.blockSize];
	
	XCTAssertTrue(ribbon.eof == YES, @"EOF status should be set");
	XCTAssertTrue(ribbon.bof == NO, @"BOF status should be off");
	XCTAssertTrue(ribbon.filePosition == ribbon.blockSize*2, @"Pointer should be set to 1 block offset");
	
	if (readBack) {
		free(readBack);
	}
}




- (void)tearDown {
	
	// remove all files from collection
	[collection clearFileCollection];
	XCTAssertTrue(collection.fileCollection.count == 0, @"All files should be closed and removed");

}


#pragma mark - Utility methods

- (void) compareBlock:(MIXWORD *)blockA withBlock:(MIXWORD *)blockB size:(NSInteger)blockSize
{
	for (NSInteger i = 0; i < blockSize; i++) {
		MIXWORD a = blockA[i];
		MIXWORD b = blockB[i];
		XCTAssertTrue(a.sign == b.sign, @"Signs should be eaual");
		BOOL equal = YES;
		for (int k = 0; k < MIX_WORD_SIZE; k++) {
			if (a.byte[k] != b.byte[k] ) {
				equal = NO;
			}
		}
		XCTAssertTrue(equal, @"Bytes should be equal");

		if (!equal) {
			NSLog(@"Byte - %ld", (long)i);
			[self printMemoryCell:a withTitle:@"First cell"];
			[self printMemoryCell:b withTitle:@"Second cell"];
		}
	}
}


@end
