/*
 This file is part of LineBreak.
 
 LineBreak is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 LineBreak is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with LineBreak; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 Copyright (c) 2001-2008 Josh Aas.
 */

#import <Cocoa/Cocoa.h>

@interface appController : NSObject {
  IBOutlet NSPopUpButton *mTypeSelectPopup;
  IBOutlet NSProgressIndicator *mProgressBar;
  IBOutlet NSButton *mAskCheckBox;
  IBOutlet NSButton *mFoldersCheckBox;
  IBOutlet NSButton *mRecursiveCheckBox;
  IBOutlet NSButton *mProtectionCheckBox;
  IBOutlet NSButton *mSetProtectionButton;
  IBOutlet NSMenuItem *mModDatesMenuItem;
@private
  BOOL mAppIsLaunching;
  BOOL mWasLaunchedWithDocument;
  NSMutableArray *mFilesToProcess;
  NSCursor *mDragDestCursor;
}

// Interface Actions
-(IBAction)convertViaOpenPanel:(id)sender; // responds to the "Convert..." menu item
-(IBAction)setTypePrefs:(id)sender; // responds to changes in the pulldown menu
-(IBAction)setCheckboxPrefs:(id)sender; // responds to checkbox changes
-(IBAction)showProtectionPanel:(id)sender; // responds to the "Set Protection" button
-(IBAction)toggleModDates:(id)sender; // toggles modification date preservation

@end
