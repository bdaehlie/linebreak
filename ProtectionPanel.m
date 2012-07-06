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

#import "ProtectionPanel.h"
#import "Prefs.h"

@implementation ProtectionPanel

static ProtectionPanel *sharedInstance = nil;

+(ProtectionPanel*)sharedInstance {
  return sharedInstance ? sharedInstance : [[self alloc] init];
}

-(id)init {
  if (sharedInstance) {
    [self dealloc];
  }
  else {
    sharedInstance = [super init];
  }
  return sharedInstance;
}

-(void)dealloc {
  if (mLastExtensionValue != nil) {
    [mLastExtensionValue release];
  }
  [super dealloc];
}

-(void)awakeFromNib {
  if ([self isExcludeSelected]) {
    [mOnlyOrExcludeMatrix selectCellAtRow:0 column:0];
  }
  else {
    [mOnlyOrExcludeMatrix selectCellAtRow:1 column:0];
  }
	mLastExtensionValue = nil;
}

/*
 ACTIONS
 */

-(IBAction)showPanel:(id)sender {
  if (!mSetDefaultButton) {
    NSWindow *theWindow;
    [NSBundle loadNibNamed:@"ProtectionPanel" owner:self];
    theWindow = [mSetDefaultButton window];
    [theWindow setMenu:nil];
    [theWindow center];
  }
  
  [[mSetDefaultButton window] makeKeyAndOrderFront:nil];
}

-(IBAction)addExtension:(id)sender {
  int i;
  BOOL badFlag = NO;
  NSMutableArray *currentFileExtensions;
  if ([self isExcludeSelected]) {
    currentFileExtensions = [NSMutableArray arrayWithArray:[preferences arrayForKey:NonTextFileExtensionsKey]];
  }
  else {
    currentFileExtensions = [NSMutableArray arrayWithArray:[preferences arrayForKey:TextFileExtensionsKey]];
  }
  for (i = 0; i < [currentFileExtensions count]; i++) {
    if ([[[mExtensionTextField stringValue] lowercaseString] isEqualToString:[currentFileExtensions objectAtIndex:i]]) {
      badFlag = YES;
    }
  }
  if ([[[mExtensionTextField stringValue] lowercaseString] isEqualToString:@""]) {
    badFlag = YES;
  }
  if (!badFlag) {
    [currentFileExtensions addObject:[[mExtensionTextField stringValue] lowercaseString]];
    [currentFileExtensions sortUsingSelector:@selector(compare:)];
    if ([self isExcludeSelected]) {
      [preferences setObject:[NSArray arrayWithArray:currentFileExtensions] forKey:NonTextFileExtensionsKey];
    }
    else {
      [preferences setObject:[NSArray arrayWithArray:currentFileExtensions] forKey:TextFileExtensionsKey];
    }
  }
  [mAddExtensionButton setEnabled:NO];
  [mExtensionTextField setObjectValue:nil];
  [mExtensionsTable reloadData];
  [mExtensionsTable deselectAll:self];
}

-(IBAction)removeSelection:(id)sender {
  NSMutableArray *currentFileExtensions;
  NSIndexSet *selections = [mExtensionsTable selectedRowIndexes];
  if ([self isExcludeSelected]) {
    currentFileExtensions = [NSMutableArray arrayWithArray:[preferences arrayForKey:NonTextFileExtensionsKey]];
  }
  else {
    currentFileExtensions = [NSMutableArray arrayWithArray:[preferences arrayForKey:TextFileExtensionsKey]];
  }
  NSUInteger i = [selections lastIndex];
  while (i != NSNotFound) {
    [currentFileExtensions removeObjectAtIndex:i];
    i = [selections indexLessThanIndex:i];
  }
  if ([self isExcludeSelected]) {
    [preferences setObject:[NSArray arrayWithArray:currentFileExtensions] forKey:NonTextFileExtensionsKey];
  }
  else {
    [preferences setObject:[NSArray arrayWithArray:currentFileExtensions] forKey:TextFileExtensionsKey];
  }
  [mExtensionsTable reloadData];
  [mExtensionsTable deselectAll:self];
}

-(IBAction)setDefaultExtensions:(id)sender {
  if ([self isExcludeSelected]) {
    [preferences removeObjectForKey:NonTextFileExtensionsKey];
  }
  else {
    [preferences removeObjectForKey:TextFileExtensionsKey];
  }
  [mExtensionsTable reloadData];
}

-(IBAction)changeOnlyOrExcludeState:(id)sender {
  if ([mOnlyOrExcludeMatrix selectedCell] == mOnlyRB) {
    [preferences setObject:@"only" forKey:ExcludeOrOnlyFileExtensions];
  }
  else {
    [preferences setObject:@"exclude" forKey:ExcludeOrOnlyFileExtensions];
  }
  [mExtensionsTable reloadData];
}

/*
 METHODS
 */

-(NSArray*)getCurrentFileExtensions {
  if ([self isExcludeSelected]) {
    return [preferences arrayForKey:NonTextFileExtensionsKey];
  }
  else {
    return [preferences arrayForKey:TextFileExtensionsKey];
  }
}

-(BOOL)isExcludeSelected {
  if ([[preferences stringForKey:ExcludeOrOnlyFileExtensions] isEqualToString:@"exclude"]) {
    return YES;
  }
  else {
    return NO;
  }
}

/*
 DELEGATES
 */

-(int)numberOfRowsInTableView:(NSTableView *)aTableView {
  if ([self isExcludeSelected]) {
    return [[preferences arrayForKey:NonTextFileExtensionsKey] count];
  }
  else {
    return [[preferences arrayForKey:TextFileExtensionsKey] count];
  }
}

-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex {
  if ([self isExcludeSelected]) {
    return [[preferences arrayForKey:NonTextFileExtensionsKey] objectAtIndex:rowIndex];
  }
  else {
    return [[preferences arrayForKey:TextFileExtensionsKey] objectAtIndex:rowIndex];
  }
}

// Don't allow table editing
-(BOOL)tableView:(NSTableView*)aTableView shouldEditTableColumn:(NSTableColumn*)aTableColumn row:(int)rowIndex {
  return NO;
}

-(void)controlTextDidChange:(NSNotification*)aNotification {
	if ([[mExtensionTextField stringValue] length] > 5) {
    [mExtensionTextField setStringValue:mLastExtensionValue];
		NSBeep();
	}
	if ([[mExtensionTextField stringValue] length] > 0) {
		[mAddExtensionButton setEnabled:YES];
	}
	else {
		[mAddExtensionButton setEnabled:NO];
	}
  if (mLastExtensionValue != nil) {
    [mLastExtensionValue release];
  }
	mLastExtensionValue = [[mExtensionTextField stringValue] retain];
}

-(void)tableViewSelectionDidChange:(NSNotification*)aNotification {
	if ([mExtensionsTable numberOfSelectedRows] > 0) {
		[mRemoveSelectionButton setEnabled:YES];
	}
	else {
		[mRemoveSelectionButton setEnabled:NO];
	}
}

@end
