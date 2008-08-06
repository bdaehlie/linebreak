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

#import "ChoosePanel.h"
#import "TextTools.h"

@implementation ChoosePanel

static id sharedInstance = nil;

+(ChoosePanel*)sharedInstance {
  if (sharedInstance == nil) {
    sharedInstance = [[ChoosePanel alloc] init];
  }
  return sharedInstance;
}

-(id)init {
  [super initWithWindowNibName:@"ChooseType" owner:self];
  return self;
}

// if file is not nil then present its type to the user
-(int)askUserForLineBreakType:(NSString*)file {
  // set up the right message
  [self window]; // ignore the return value because we just want to make the IBOutlet connections
  if (file == nil) {
    [mMessageField setStringValue:@"Convert file(s) to:"];
  }
  else {
    int lbFormat = [TextTools detectLBFormat:file];
    NSString *fileTypeString;
    if (lbFormat == jaDOSLBFormat) {
      fileTypeString = @"DOS";
    }
    else if (lbFormat == jaMacLBFormat) {
      fileTypeString = @"Mac";
    }
    else if (lbFormat == jaUnixLBFormat) {
      fileTypeString = @"UNIX";
    }
    else {
      return -1;
    }
    [mMessageField setStringValue:[NSString stringWithFormat:@"This is a %@ file. Convert it to:", fileTypeString]];
  }
  return [NSApp runModalForWindow:[self window]];
}

-(IBAction)chooseCancel:(id)sender {
  [NSApp stopModalWithCode:3];
  [[self window] close];
}

-(IBAction)chooseUNIX:(id)sender {
  [NSApp stopModalWithCode:0];
  [[self window] close];
}

-(IBAction)chooseMac:(id)sender {
  [NSApp stopModalWithCode:1];
  [[self window] close];
}

-(IBAction)chooseDOS:(id)sender {
  [NSApp stopModalWithCode:2];
  [[self window] close];
}

@end
