//
//  MIXCPU.h
//  MixMac
//
//  Created by Водолазкий В.В. on 14.02.15.
//  Copyright (c) 2015 Geomatix Laboratoriess S.R.O. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MIXCPU : NSObject

@property (nonatomic, readwrite) BOOL sixBitByte;		// YES - 6 bit in bye, NO - 8 bit


+ (MIXCPU *) sharedInstance;



@end
