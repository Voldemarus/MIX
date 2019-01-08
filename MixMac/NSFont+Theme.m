//
//  Theme+NSFont.m
//  MixMac
//
//  Created by Dmitry Likhtarov on 08/01/2019.
//  Copyright © 2018 Geomatix Laboratory S.R.O. All rights reserved.
//

#import "NSFont+Theme.h"

NSString * const Monaco = @"Monaco";

@implementation NSFont (Theme)

+ (NSFont *) mixFont
{
    //// надо думать когда(если) дойдем до новых тем
    //switch ([Preferences sharedPreferences].theme) {
    //    case ThemeDefault:
    //        return [NSFont fontWithName:Monaco size:13];
    //        break;
    //    default:
    //        break;
    //}
	return [NSFont fontWithName:Monaco size:13];
}

+ (NSFont *) mixLabel
{
    return [NSFont fontWithName:Monaco size:13];
}

+ (NSFont *) mixMnemonic
{
    return [NSFont fontWithName:Monaco size:13];
}

+ (NSFont *) mixOperand
{
    return [NSFont fontWithName:Monaco size:13];
}

+ (NSFont *) mixComment
{
    return [NSFont fontWithName:Monaco size:13];
}

+ (NSFont *) mixError
{
    return [NSFont fontWithName:Monaco size:13];
}


@end
