//
//  MixSeqFileTest.m
//  MixMacTests
//
//  Created by Водолазкий В.В. on 30/12/2018.
//  Copyright © 2018 Geomatix Laboratoriy S.R.O. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MIXFileCollection.h"

@interface MixSeqFileTest : XCTestCase
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
	
	
	
	
}



- (void)tearDown {
	
	// remove all files from collection
	[collection clearFileCollection];
	XCTAssertTrue(collection.fileCollection.count == 0, @"All files should be closed and removed");

}



@end
