//
//  MIXSeqFile.h
//  MixMac
//
//  Created by Водолазкий В.В. on 03.03.15.
//  Copyright (c) 2015 Geomatix Laboratoriy S.R.O. All rights reserved.
//

#import <Foundation/Foundation.h>


// Sequential file (magnetic tape
@interface MIXSeqFile : NSObject  <NSCopying, NSCoding>


@property (nonatomic, readwrite) NSInteger fileSize;
@property (nonatomic, readwrite) NSInteger filePosition;
@property (nonatomic, readwrite) NSInteger blockSize;
@property (nonatomic, retain) NSString *deviceName;



@end



@interface MIXFileCollection : NSObject  <NSCopying, NSCoding>

- (NSArray *) deviceParameters;		// Returns list with device parameters

@end