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

@interface ChoosePanel : NSWindowController {
  IBOutlet NSButton *mCancelButton;
  IBOutlet NSButton *mDOSButton;
  IBOutlet NSButton *mUNIXButton;
  IBOutlet NSButton *mMacButton;
  IBOutlet NSTextField *mMessageField;
}

// IBActions
-(IBAction)chooseCancel:(id)sender;
-(IBAction)chooseUNIX:(id)sender;
-(IBAction)chooseMac:(id)sender;
-(IBAction)chooseDOS:(id)sender;

// Methods
+(ChoosePanel*)sharedInstance;
-(int)askUserForLineBreakType:(NSString*)file;

@end
