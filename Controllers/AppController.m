/*
 *  AppController.m
 *  MPlayer OS X
 *
 *  Created by Jan Volf
 *	<javol@seznam.cz>
 *  Copyright (c) 2003 Jan Volf. All rights reserved.
 */

#import "AppController.h"

// other controllers
#import "PlayerCtrllr.h"
#import "PlayListCtrllr.h"


@implementation AppController
- (void) awakeFromNib;
{
	// create preferences and register application factory presets
	[[NSUserDefaults standardUserDefaults] registerDefaults:
	[[[NSBundle mainBundle] infoDictionary] objectForKey:@"ApplicationDefaults"]];
}

/************************************************************************************
 INTERFACE
 ************************************************************************************/
- (NSUserDefaults *) preferences
{
	return [NSUserDefaults standardUserDefaults];
}
/************************************************************************************/
- (BOOL) savePrefs
{
	return [[self preferences] synchronize];
}
/************************************************************************************/
- (void)quitApp
{
	[theApp terminate:self];
}

/************************************************************************************
 ACTIONS
 ************************************************************************************/
- (IBAction) openFile:(id)sender
{
	NSMutableArray *fileTypes;
	NSString *theFile;
	
	// take both audio and movie files in account
	fileTypes = [NSMutableArray arrayWithArray:[self typeExtensionsForName:@"Movie file"]];
	[fileTypes addObjectsFromArray:[self typeExtensionsForName:@"Audio file"]];
	
	// present open dialog
	theFile = [self openDialogForTypes:fileTypes];
	
	if (theFile) {
		// if any file, create new item and play it
		NSMutableDictionary *theItem = [NSMutableDictionary
				dictionaryWithObject:theFile forKey:@"MovieFile"];
		[playerController playItem:theItem];
	}
}
//BETA//////////////////////////////////////////////////////////////////////////////////
- (IBAction) openVIDEO_TS:(id)sender
{
    NSOpenPanel *thePanel = [NSOpenPanel openPanel];
	NSString *theDir = nil;
	NSString *defDir;
	
	if (!(defDir = [[self preferences] objectForKey:@"DefaultDirectory"]))
		defDir = NSHomeDirectory();

    [thePanel setAllowsMultipleSelection:NO];
	[thePanel setCanChooseDirectories : YES ];
	[thePanel setCanChooseFiles : NO ];
	
    if ([thePanel runModalForDirectory:defDir file:nil types:[NSArray arrayWithObject:@"VOB"]] == NSOKButton) {
        theDir = [[thePanel filenames] objectAtIndex:0];
		[[NSUserDefaults standardUserDefaults]
				setObject:[theDir stringByDeletingLastPathComponent]
				forKey:@"DefaultDirectory"];
		if ([[theDir lastPathComponent] isEqualToString:@"VIDEO_TS"]) {
			NSMutableDictionary *theItem = [NSMutableDictionary
					dictionaryWithObject:theDir forKey:@"MovieFile"];
			[playerController playItem:theItem];
		}
		else {
			NSRunAlertPanel(NSLocalizedString(@"Error",nil),
					NSLocalizedString(@"Selected folder is not valid VIDEO_TS folder.",nil),
					NSLocalizedString(@"OK",nil),nil,nil);
		}
    }
}

/************************************************************************************/
- (IBAction) addToPlaylist:(id)sender
{
	NSMutableArray *fileTypes;
	NSOpenPanel *thePanel = [NSOpenPanel openPanel];
	NSString *defDir;
	
	// take both audio and movie files in account
	fileTypes = [NSMutableArray arrayWithArray:[self typeExtensionsForName:@"Movie file"]];
	[fileTypes addObjectsFromArray:[self typeExtensionsForName:@"Audio file"]];
	
	// present open dialog
	if (!(defDir = [[self preferences] objectForKey:@"DefaultDirectory"]))
		defDir = NSHomeDirectory();
	
	// allow multiple selection
	[thePanel setAllowsMultipleSelection:YES];
	
    if ([thePanel runModalForDirectory:defDir file:nil types:fileTypes] == NSOKButton) {
        int i;
		//  take care of multiple selection
		for (i=0; i<[[thePanel filenames] count]; i++) {
			NSMutableDictionary *theItem = [NSMutableDictionary
					dictionaryWithObject:[[thePanel filenames] objectAtIndex:i]
					forKey:@"MovieFile"];
			[[self preferences]
					setObject:[[[thePanel filenames] objectAtIndex:i]
					stringByDeletingLastPathComponent]
					forKey:@"DefaultDirectory"];
			if ([playerController preflightItem:theItem])
				[playListController appendItem:theItem];

		}
    }
}
- (IBAction) deleteFromPlaylist:(id)sender
{
	NSMutableDictionary *theItem = [NSMutableDictionary
			dictionaryWithObject:[locationBox stringValue]
			forKey:@"MovieFile"];
	[playListController deleteSelection:theItem];
}
/************************************************************************************/
- (IBAction) openLocation:(id)sender
{
	if ([NSApp runModalForWindow:locationPanel] == 1) {
		NSMutableDictionary *theItem = [NSMutableDictionary
				dictionaryWithObject:[locationBox stringValue]
				forKey:@"MovieFile"];
		[playerController playItem:theItem];
	}
}

/************************************************************************************/
//BETA
- (IBAction) openVIDEO_TSLocation:(id)sender
{
	if ([NSApp runModalForWindow:video_tsPanel] == 1) {
		NSMutableDictionary *theItem = [NSMutableDictionary
				dictionaryWithObject:[video_tsBox stringValue]
				forKey:@"MovieFile"];
		[playerController playItem:theItem];
	}
}

- (IBAction) cancelVIDEO_TSLocation:(id)sender
{
	[NSApp stopModalWithCode:0];
	[video_tsPanel orderOut:nil];
}
- (IBAction) applyVIDEO_TSLocation:(id)sender
{
	NSURL *theUrl = [NSURL URLWithString:[video_tsBox stringValue]];
	if ([[theUrl scheme] caseInsensitiveCompare:@"http"] == NSOrderedSame ||
			[[theUrl scheme] caseInsensitiveCompare:@"ftp"] == NSOrderedSame ||
			[[theUrl scheme] caseInsensitiveCompare:@"rtsp"] == NSOrderedSame ||
			[[theUrl scheme] caseInsensitiveCompare:@"dvd"] == NSOrderedSame ||
			[[theUrl scheme] caseInsensitiveCompare:@"mms"] == NSOrderedSame) {
		[video_tsBox setStringValue:[[theUrl standardizedURL] absoluteString]];
		[NSApp stopModalWithCode:1];
		[video_tsPanel orderOut:nil];
	}
	else
		NSBeginAlertSheet(NSLocalizedString(@"Error",nil),
				NSLocalizedString(@"OK",nil), nil, nil, video_tsPanel, nil, nil, nil, nil,
				NSLocalizedString(@"The URL is not in correct format or cannot be handled by this application.",nil));
}
/************************************************************************************/
- (IBAction) applyLocation:(id)sender
{
	NSURL *theUrl = [NSURL URLWithString:[locationBox stringValue]];
	if ([[theUrl scheme] caseInsensitiveCompare:@"http"] == NSOrderedSame ||
			[[theUrl scheme] caseInsensitiveCompare:@"ftp"] == NSOrderedSame ||
			[[theUrl scheme] caseInsensitiveCompare:@"rtsp"] == NSOrderedSame ||
			[[theUrl scheme] caseInsensitiveCompare:@"dvd"] == NSOrderedSame ||
			[[theUrl scheme] caseInsensitiveCompare:@"mms"] == NSOrderedSame) {
		[locationBox setStringValue:[[theUrl standardizedURL] absoluteString]];
		[NSApp stopModalWithCode:1];
		[locationPanel orderOut:nil];
	}
	else
		NSBeginAlertSheet(NSLocalizedString(@"Error",nil),
				NSLocalizedString(@"OK",nil), nil, nil, locationPanel, nil, nil, nil, nil,
				NSLocalizedString(@"The URL is not in correct format or cannot be handled by this application.",nil));
}
/************************************************************************************/
- (IBAction) cancelLocation:(id)sender
{
	[NSApp stopModalWithCode:0];
	[locationPanel orderOut:nil];
}

/************************************************************************************
 BUNDLE ACCESS
 ************************************************************************************/
#ifdef __COCOA__
// return array of document extensions of specified document type name
- (NSArray *) typeExtensionsForName:(NSString *)typeName
{

	int i;
	NSArray *typeList = [[[NSBundle mainBundle] infoDictionary]
			objectForKey:@"CFBundleDocumentTypes"];
	for (i=0; i<[typeList count]; i++) {
		if ([[[typeList objectAtIndex:i] objectForKey:@"CFBundleTypeName"]
			isEqualToString:typeName])
			return [[typeList objectAtIndex:i] objectForKey:@"CFBundleTypeExtensions"];
	}
	return nil;
}
#else
- (NSArray *) typeExtensionsForName:(NSString *)typeName
{
#warning Ugly hacks
      NSLog(@"typeName %@",typeName);
  if  ( [typeName isEqualToString:@"Movie file"] )
    {
      NSLog(@"Movie File");
      return [[NSArray alloc] initWithObjects:@"avi",@"mpg",@"m4v",@"webm",
			      @"mpeg",@"wmv",@"ogm",
			      @"ogv",@"mkv",@"mp4",
			      @"asf",@"mov",@"iso",
			      @"vob",@"VOB",nil];
    }
  else if ( [typeName isEqualToString:@"Audio file"] )
    {
      return [[NSArray alloc] initWithObjects:@"mp3",@"MP3",@"ogg",@"OGG"
			      @"wav",@"WAV",@"flac",@"FLAC",@"wma",@"OGM",
			      @"asf",@"ASF",nil];
    }
  else
    return nil;
}
#endif


/************************************************************************************
 MISC METHODS
 ************************************************************************************/
// presents open dialog for certain types
- (NSString *) openDialogForTypes:(NSArray *)typeList
{
    NSOpenPanel *thePanel = [NSOpenPanel openPanel];
	NSString *theFile = nil;
	NSString *defDir;
	
	if (!(defDir = [[self preferences] objectForKey:@"DefaultDirectory"]))
		defDir = NSHomeDirectory();

    [thePanel setAllowsMultipleSelection:NO];

    if ([thePanel runModalForDirectory:defDir file:nil types:typeList] == NSOKButton) {
        theFile = [[thePanel filenames] objectAtIndex:0];
		[[NSUserDefaults standardUserDefaults]
				setObject:[theFile stringByDeletingLastPathComponent]
				forKey:@"DefaultDirectory"];
    }
	return theFile;
}
//openfor folders
- (NSString *) openDialogForFolders:(NSArray *)typeList
{
    NSOpenPanel *thePanel = [NSOpenPanel openPanel];
	NSString *theFile = nil;
	NSString *defDir;
	
	if (!(defDir = [[self preferences] objectForKey:@"DefaultDirectory"]))
		defDir = NSHomeDirectory();

    [thePanel setAllowsMultipleSelection:NO];
	[thePanel setCanChooseDirectories : YES ];
	[thePanel setCanChooseFiles : NO ];
    if ([thePanel runModalForDirectory:defDir file:nil types:typeList] == NSOKButton) {
        theFile = [[thePanel filenames] objectAtIndex:0];
		[[NSUserDefaults standardUserDefaults]
				setObject:[theFile stringByDeletingLastPathComponent]
				forKey:@"DefaultDirectory"];
    }
	return theFile;
}



//beta
/*
- (NSString *) saveDialogForTypes:(NSArray *)typeList
{
    NSSavePanel *thePanel = [NSSavePanel savePanel];
	NSString *theFile = nil;
	NSString *defDir;
	
	if (!(defDir = [[self preferences] objectForKey:@"DefaultDirectory"]))
		defDir = NSHomeDirectory();

 //   [thePanel setAllowsMultipleSelection:NO];

    if ([thePanel runModalForDirectory:defDir file:nil types:typeList] == NSOKButton) {
        theFile = [[thePanel filenames] objectAtIndex:0];
		[[NSUserDefaults standardUserDefaults]
				setObject:[theFile stringByDeletingLastPathComponent]
				forKey:@"DefaultDirectory"];
    }
	return theFile;
}
*/


/************************************************************************************
 DELEGATE METHODS
 ************************************************************************************/
// app delegate method
// executes when file is double clicked or dropped on apps icon
// immediatlely starts to play dropped file without adding it to the playlist
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	if (filename) {
		// create an item from it and play it
		NSMutableDictionary *myItem = [NSMutableDictionary
				dictionaryWithObject:filename forKey:@"MovieFile"];
		
		[playerController playItem:myItem];
		return YES;
	}
	return NO;
}
/************************************************************************************/
// posted when application wants to terminate
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	// post notification first
	[[NSNotificationCenter defaultCenter]
			postNotificationName:@"ApplicationShouldTerminateNotification"
			object:NSApp
			userInfo:nil];

	// try to save preferences
	if (![[self preferences] synchronize]) {
		// if prefs could not be saved present alert box
		if (NSRunAlertPanel(NSLocalizedString(@"Error",nil),
				NSLocalizedString(@"Preferences could not be saved.\nQuit anyway?",nil),
				NSLocalizedString(@"OK",nil),
				NSLocalizedString(@"Cancel",nil),nil) == NSAlertAlternateReturn)
			return NSTerminateCancel;
	}
	
	return NSTerminateNow;
}
@end
