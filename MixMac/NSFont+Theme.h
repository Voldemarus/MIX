//
//  Theme+NSFont.h
//  MixMac
//
//  Created by Dmitry Likhtarov on 08/01/2019.
//  Copyright © 2018 Geomatix Laboratory S.R.O. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Theme.h"

extern NSString * const MonacoFont;

@interface NSFont (Theme)

+ (NSFont *) mixFont;

+ (NSFont *) mixLabel;
+ (NSFont *) mixMnemonic;
+ (NSFont *) mixOperand;
+ (NSFont *) mixComment;

+ (NSFont *) mixError;


@end
