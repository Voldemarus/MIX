//
//  MIXExceptions.h
//  MixMac
//
//  Created by Водолазкий В.В. on 14.02.15.
//  Copyright (c) 2015 Geomatix Laboratoriy S.R.O. All rights reserved.
//


// Invalid index for the memory cell. Should be in range [0..MIX_MEMORY_SIZE)
extern NSString * const MIXExceptionInvalidMemoryCellIndex;

// invalud number for index register. Should be in range [1..MIX_INDEX_REGISTERS]
extern NSString * const MIXExceptionInvalidIndexRegister;

// invalid operCode - not supported by current CPU
extern NSString * const MIXExceptionInvalidOperationCode;

// incorrect value fro field modifier
extern NSString * const MIXExceptionInvalidFieldModifer;

// invalid file handler. Should be in range 0..PERFOLENTA
extern NSString * const MIXExceptionInvalidFileHandler;

// invalid device number during attempt to create new file handler
extern NSString * const MIXExceptionInvalidDeviceNumber;
