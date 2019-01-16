//
//  NSColor+Theme.h
//  MixMac
//
//  Created by Dmitry Likhtarov on 08/01/2019.
//  Copyright © 2018 Geomatix Laboratory S.R.O. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Theme.h"

@interface NSColor (Theme)

+ (NSColor *) mixText;
+ (NSColor *) mixLabel;
+ (NSColor *) mixMnemonic;
+ (NSColor *) mixOperand;
+ (NSColor *) mixComment;

+ (NSColor *) mixErrorForegraund;
+ (NSColor *) mixErrorBackground;


@end
