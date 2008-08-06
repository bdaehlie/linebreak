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

@interface ProtectionPanel : NSObject {
  IBOutlet NSButton *mSetDefaultButton;
  IBOutlet NSTableView *mExtensionsTable;
  IBOutlet NSMatrix *mOnlyOrExcludeMatrix;
  IBOutlet NSButton *mAddExtensionButton;
  IBOutlet NSButton *mRemoveSelectionButton;
  IBOutlet NSButtonCell *mOnlyRB;
  IBOutlet NSButtonCell *mExcludeRB;
  IBOutlet NSTextField *mExtensionTextField;
@private
  NSString *mLastExtensionValue;
}

// IBActions
-(IBAction)showPanel:(id)sender;
-(IBAction)addExtension:(id)sender;
-(IBAction)setDefaultExtensions:(id)sender;
-(IBAction)removeSelection:(id)sender;
-(IBAction)changeOnlyOrExcludeState:(id)sender;

// Methods
+(ProtectionPanel*)sharedInstance;
-(NSArray*)getCurrentFileExtensions;
-(BOOL)isExcludeSelected;

// Delegates
-(void)controlTextDidChange:(NSNotification*)aNotification;
-(void)tableViewSelectionDidChange:(NSNotification*)aNotification;
-(int)numberOfRowsInTableView:(NSTableView *)aTableView;
-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
-(BOOL)tableView:(NSTableView*)aTableView shouldEditTableColumn:(NSTableColumn*)aTableColumn row:(int)rowIndex;

@end
