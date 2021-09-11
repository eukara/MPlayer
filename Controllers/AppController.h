/*
 *  AppController.h
 *  MPlayer OS X
 *
 *	Description:
 *		AppController handles application specific events and notifications, it is
 *	NSApp delegate, it provides MainBundle access
 *
 *  Created by Jan Volf
 *	<javol@seznam.cz>
 *  Copyright (c) 2003 Jan Volf. All rights reserved.
 */

#ifdef __COCOA__
#import <Cocoa/Cocoa.h>
#else
#import <AppKit/AppKit.h>
#endif

@interface AppController : NSObject
{
	// controller outlets
	IBOutlet id playerController;
	IBOutlet id playListController;

	// GUI outlets
	IBOutlet id locationPanel;
	IBOutlet id locationBox;

	IBOutlet id video_tsPanel;
	IBOutlet id video_tsBox;
	IBOutlet id video_tsbutton;

	// other outlets
	IBOutlet id theApp;
}

// app's interface
- (NSUserDefaults *) preferences;
- (BOOL) savePrefs;
- (void) quitApp;
	
// actions
- (IBAction) openFile:(id)sender;
- (IBAction) addToPlaylist:(id)sender;
- (IBAction) openLocation:(id)sender;

- (IBAction) openVIDEO_TS:(id)sender;
- (IBAction) cancelVIDEO_TSLocation:(id)sender;
- (IBAction) applyVIDEO_TSLocation:(id)sender;

- (IBAction) applyLocation:(id)sender;
- (IBAction) deleteFromPlaylist:(id)sender;
- (IBAction) cancelLocation:(id)sender;

// bundle access
- (NSArray *) typeExtensionsForName:(NSString *)typeName;
- (BOOL) isExtension:(NSString *)theExt ofType:(NSString *)theType;

// misc methods
- (NSString *) openDialogForTypes:(NSArray *)typeList;

//beta
//- (NSString *) saveDialogForTypes:(NSArray *)typeList;
- (NSString *) openDialogForFolders:(NSArray *)typeList;

// delegate methods
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename;
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender;

@end
