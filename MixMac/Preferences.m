//
//  Preferences.m
//  MixMac
//
//  Created by Водолазкий В.В. on 14.02.15.
//  Copyright (c) 2015 Geomatix Laboratoriy S.R.O. All rights reserved.
//

#import "Preferences.h"


NSString * const VVVbyteSizeChanged		=	@"VVVbyteSizeChanged";


@interface Preferences() {
	NSUserDefaults *prefs;
}

@end

@implementation Preferences

NSString * const	VVV6Bits		=	@"VVV6Bits";
NSString * const    VVVtheme        =   @"VVVtheme";

+ (Preferences *) sharedPreferences
{
	static Preferences *_Preferences;
	if (_Preferences == nil) {
		_Preferences = [[Preferences alloc] init];
	}
	return _Preferences;
}

//
// Init set of data for case when actual preference file is not created yet
//
+ (void)initialize
{
	NSMutableDictionary  *defaultValues = [NSMutableDictionary dictionary];
	// set up default parameters
	[defaultValues setObject:@(YES) forKey:VVV6Bits];
    [defaultValues setObject:@(0) forKey:VVVtheme];

	[[NSUserDefaults standardUserDefaults] registerDefaults: defaultValues];
	
}

- (id) init
{
	if (self = [super init]) {
		prefs = [NSUserDefaults standardUserDefaults];
		
	}
	return self;
}


- (void) flush
{
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 

- (BOOL) byteHas6Bit
{
	return [prefs boolForKey:VVV6Bits];
}

- (void) setByteHas6Bit:(BOOL)byteHas6Bit
{
	if (byteHas6Bit == [self byteHas6Bit]) return;
	[prefs setBool:byteHas6Bit forKey:VVV6Bits];
	[[NSNotificationCenter defaultCenter] postNotificationName:VVVbyteSizeChanged
														object:@(byteHas6Bit)];
}

// Номер темы оформления
- (ThemeNumber) theme
{
    return [prefs integerForKey:VVVtheme];
}
- (void) setTheme:(ThemeNumber)theme
{
    [prefs setInteger:theme forKey:VVVtheme];
}

@end
