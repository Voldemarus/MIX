//
//  Preferences.h
//  MixMac
//
//  Created by Водолазкий В.В. on 14.02.15.
//  Copyright (c) 2015 Geomatix Laboratoriess S.R.O. All rights reserved.
//

#import <Foundation/Foundation.h>

//
// Notifiactions sent when some preferences values are changed
//
extern NSString * const VVVbyteSizeChanged;			// Size of byte is changed

@interface Preferences : NSObject

+ (Preferences *) sharedPreferences;

- (void) flush;		// use to aboid lost of preferences on application crash


@property (nonatomic, readwrite) BOOL byteHas6Bit;		// YES - byte contains 6 bits, 8 otherwise


@end
