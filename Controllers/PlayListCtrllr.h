/*
 *  PlayListCtrllr.h
 *  MPlayer OS X
 *
 *	Description:
 *		It's controller for playlist table, it's playlist table delegate and data source,
 *	it also takes care for loading files in to playlist and it's progress dialog. 
 *
 *  Created by Jan Volf
 *	<javol@seznam.cz>
 *  Copyright (c) 2003 Jan Volf. All rights reserved.
 */

#import <AppKit/AppKit.h>

#import "PreferencesController.h"

#define kDefaultTextSize		12
#define kSmallerTextSize		10

@interface PlayListCtrllr : NSObject
{
	// controllers outlets
	IBOutlet id appController;
	IBOutlet id playerController;
	IBOutlet id settingsController;

	// UI outlets
	IBOutlet id playListTable;
	IBOutlet id settingsButton;
	IBOutlet id playModeButton;
	
	// preflight panel
	IBOutlet id preflightPanel;
	IBOutlet id filenameBox;
	IBOutlet id progressBar;

	// data
	NSMutableArray *myData;
	int myPlayMode;
	
	// images
	NSImage *statusIcon;
	NSImage *playMode0Image;
	NSImage *playMode1Image;
	NSImage *playMode2Image;
	
}
// data access interface
- (NSMutableDictionary *) itemAtIndex:(int) aIndex;
- (void) selectItemAtIndex:(int) aIndex;
- (NSMutableDictionary *) selectedItem;
- (int) indexOfSelectedItem;
- (int) numberOfSelectedItems;
- (int) indexOfItem:(NSDictionary *)anItem;
- (int) itemCount;
- (void) appendItem:(NSMutableDictionary *)anItem;
- (void) insertItem:(NSMutableDictionary *)anItem atIndex:(int) aIndex;

// controller interface
- (void) updateView;
- (void) applyPrefs;
- (void) finishedPlayingItem:(NSDictionary *)playingItem;

// actions
- (IBAction)displayItemSettings:(id)sender;
- (IBAction)changePlayMode:(id)sender;
- (IBAction)cancelPreflight:(id)sender;
- (IBAction)deleteSelection:(id) sender;

// TableView data access methods
- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView
		objectValueForTableColumn:(NSTableColumn *)tableColumn
		row:(int)row;
- (NSDragOperation)tableView:(NSTableView*)tv 
		validateDrop:(id <NSDraggingInfo>)info
		proposedRow:(int)row
		proposedDropOperation:(NSTableViewDropOperation)op;
- (BOOL)tableView:(NSTableView*)tv
		acceptDrop:(id <NSDraggingInfo>)info
		row:(int)row
		dropOperation:(NSTableViewDropOperation)op;
- (BOOL)tableView:(NSTableView *)tableView
		writeRows:(NSArray*)rows
		toPasteboard:(NSPasteboard*)pasteboard;

// delegate methods
- (BOOL) validateMenuItem:(NSMenuItem *)aMenuItem;
- (IBAction)doubleClick:(id)sender;
- (BOOL)tableView:(NSTableView *)tableView
		shouldEditTableColumn:(NSTableColumn *)tableColumn 
		row:(int)row;
- (void)tableView:(NSTableView *)aTableView
		willDisplayCell:(id)aCell
		forTableColumn:(NSTableColumn *)aTableColumn
		row:(int)rowIndex;
// notification handlers
- (void) appFinishedLaunching;
- (void) appShouldTerminate;
- (void) appTerminating;
@end
