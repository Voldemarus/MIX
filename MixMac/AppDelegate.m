//
//  AppDelegate.m
//  MixMac
//
//  Created by Водолазкий В.В. on 14.02.15.
//  Copyright (c) 2015 Geomatix Laboratoriy S.R.O. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
    // Для открытия файлов перетаскиванием его на иконку приложения
    [NSApp.mainWindow registerForDraggedTypes:@[NSPasteboardTypeFileURL]];

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

- (IBAction)openTeacherBook:(id)sender {
    //[[NSWorkspace sharedWorkspace] openURL:[[NSBundle mainBundle] URLForResource:@"MIXAL tacherbook" withExtension:@"html"]];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://linux.yaroslavl.ru/docs/altlinux/doc-gnu/mdk/mdk_4.html"]];
}

@end
