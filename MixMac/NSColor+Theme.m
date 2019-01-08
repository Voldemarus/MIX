//
//  NSColor+Theme.m
//  MixMac
//
//  Created by Dmitry Likhtarov on 08/01/2019.
//  Copyright © 2018 Geomatix Laboratory S.R.O. All rights reserved.
//

#import "NSColor+Theme.h"

@implementation NSColor (Theme)

+ (NSColor *) mixLabel
{
    return [NSColor colorWithRed:1 green:0.5 blue:0 alpha:1];
}

+ (NSColor *) mixMnemonic
{
    return [NSColor colorWithRed:0 green:0.5 blue:1 alpha:1];
}

+ (NSColor *) mixOperand
{
    return [NSColor colorWithRed:0.8 green:0.3 blue:0 alpha:1];
}

+ (NSColor *) mixComment
{
    return [NSColor colorWithRed:0 green:0.5 blue:0 alpha:1];
}

+ (NSColor *) mixErrorForegraund
{
    return [NSColor colorWithRed:1 green:1 blue:0 alpha:1];
}

+ (NSColor *) mixErrorBackground
{
    return [NSColor colorWithRed:0.8 green:0.1 blue:0.1 alpha:1];
}

@end
