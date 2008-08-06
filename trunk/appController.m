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

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "TextTools.h"
#import "ChoosePanel.h"
#import "appController.h"
#import "ProtectionPanel.h"
#import "Prefs.h"

#define FileManager [NSFileManager defaultManager]
#define WorkSpace [NSWorkspace sharedWorkspace]

@implementation appController

-(id)init {
  if ((self = [super init])) {
    // set up the custom cursor image now so there is no delay on the first drag
    // use a copy since we don't want to resize the original
    NSImage *appIcon = [[[NSImage imageNamed:@"NSApplicationIcon"] copy] autorelease];
    [appIcon setSize:NSMakeSize(32,32)];
    mDragDestCursor = [[NSCursor alloc] initWithImage:appIcon hotSpot:NSMakePoint(16,16)];
    
    mAppIsLaunching = YES;
    mWasLaunchedWithDocument = NO;
    mFilesToProcess = [[NSMutableArray alloc] initWithCapacity:5];
  }
  return self;
}

-(void)dealloc {
  [mFilesToProcess release];
  [mDragDestCursor release];
  [super dealloc];
}

+(void)initialize {
  NSMutableDictionary *defaultPrefs = [NSMutableDictionary dictionary];
  [defaultPrefs setObject:@"0" forKey:ConvertToKey];
  [defaultPrefs setObject:@"YES" forKey:ChooseOnDropKey];
  [defaultPrefs setObject:@"NO" forKey:HandleFoldersKey];
  [defaultPrefs setObject:@"NO" forKey:RecursiveFolderHandlingKey];
  [defaultPrefs setObject:@"NO" forKey:PreserveModDates];
  // This could be done in a plist but its unnecessary for now
  [defaultPrefs setObject:[[NSArray arrayWithObjects:@"doc", @"jpg", @"jpeg", @"png", @"bmp",
                            @"pdf", @"psd", @"gif", @"tiff", @"tif", @"exe", @"app", @"nib", @"jar", @"zip", @"sit",
                            @"class", @"xls", @"mp3", @"mpg", @"mov", @"ppt", @"m4p", @"mv4", @"wav", @"rtf", @"rtfd",
                            @"tar", @"gz", @"tgz", @"mpeg", @"dmg", @"sitx", nil] sortedArrayUsingSelector:@selector(compare:)]
                   forKey:NonTextFileExtensionsKey];
  [defaultPrefs setObject:[[NSArray arrayWithObjects:@"html", @"shtml", @"htm", @"txt", @"pl", @"cgi",
                            @"php", @"php3", @"php4", @"js", @"xml", nil] sortedArrayUsingSelector:@selector(compare:)] forKey:TextFileExtensionsKey];
  // The two options are "only" or "exclude"
  [defaultPrefs setObject:@"exclude" forKey:ExcludeOrOnlyFileExtensions];
  [defaultPrefs setObject:@"YES" forKey:ProtectionOn];
  [preferences registerDefaults:defaultPrefs];
}

-(void)awakeFromNib {
  NSWindow *mainWindow = [mTypeSelectPopup window];
  
  // Set Up Interface Elements
  [mTypeSelectPopup selectItemAtIndex:[preferences integerForKey:ConvertToKey]];
  [preferences boolForKey:ChooseOnDropKey] ? [mAskCheckBox setState:NSOnState] : [mAskCheckBox setState:NSOffState];
  [preferences boolForKey:RecursiveFolderHandlingKey] ? [mRecursiveCheckBox setState:NSOnState] : [mRecursiveCheckBox setState:NSOffState];
  
  if ([preferences boolForKey:HandleFoldersKey]) {
    [mFoldersCheckBox setState:NSOnState];
    [mRecursiveCheckBox setEnabled:YES];
  }
  else {
    [mFoldersCheckBox setState:NSOffState];
    [mRecursiveCheckBox setEnabled:NO];
  }
  if ([preferences boolForKey:ProtectionOn]) {
    [mProtectionCheckBox setState:NSOnState];
    [mSetProtectionButton setEnabled:YES];
  }
  else {
    [mProtectionCheckBox setState:NSOffState];
    [mSetProtectionButton setEnabled:NO];
  }
  if ([preferences boolForKey:PreserveModDates]) {
    [mModDatesMenuItem setState:NSOnState];
  }
  else {
    [mModDatesMenuItem setState:NSOffState];
  }
  
  // set up the main window as a drag destination
  [mainWindow registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
  
  // bring the main window forward
  [mainWindow makeKeyAndOrderFront:self];
}

-(BOOL)shouldConvert:(NSString*)file {
  int i;
  BOOL convertFlag = YES;
  NSArray *extensions;
  
  // Check HFS Type - we don't do this any more
  // but I left the code here in case you want to
  /*
   NSString *HFSFileType = NSHFSTypeOfFile(file);
   if (HFSFileType != nil) {
   if (!([HFSFileType isEqualToString:NSFileTypeForHFSTypeCode('TEXT')] || [HFSFileType isEqualToString:NSFileTypeForHFSTypeCode(nil)])) {
   return NO;
   }
   }
   */
  
  // Make sure we can write to the file
  if (![FileManager isWritableFileAtPath:file]) {
    return NO;
  }
  
  // See if protection settings block it
  if ([preferences boolForKey:ProtectionOn]) {
    if ([[preferences stringForKey:ExcludeOrOnlyFileExtensions] isEqualToString:@"exclude"]) {
      convertFlag = YES;
      extensions = [preferences arrayForKey:NonTextFileExtensionsKey];
      for (i = 0; i < [extensions count]; i++) {
        if ([[file pathExtension] caseInsensitiveCompare:[extensions objectAtIndex:i]] == NSOrderedSame) {
          convertFlag = NO;
          break;
        }
      }
    }
    else {
      convertFlag = NO;
      extensions = [preferences arrayForKey:TextFileExtensionsKey];
      for (i = 0; i < [extensions count]; i++) {
        if ([[file pathExtension] caseInsensitiveCompare:[extensions objectAtIndex:i]] == NSOrderedSame) {
          convertFlag = YES;
          break;
        }
      }
    }
  }
  
  return convertFlag;
}

// Returns whether or not the file was actually converted
-(void)convertFile:(NSString*)file toFormat:(int)type {
  // preserve modification date if the user wants to
  NSDictionary *fileAttrs = nil;
  if ([preferences boolForKey:PreserveModDates]) {
    fileAttrs = [FileManager fileAttributesAtPath:file traverseLink:YES];
  }
  if ([self shouldConvert:file]) {
    if (type == jaUnixLBFormat) {
      [TextTools convertFileToUnix:file];
    }
    else if (type == jaMacLBFormat) {
      [TextTools convertFileToMac:file];
    }
    else if (type == jaDOSLBFormat) {
      [TextTools convertFileToDOS:file];
    }
  }
  if (fileAttrs != nil) {
    // only change the NSFileModificationDate instead of all attributes
    [FileManager changeFileAttributes:[NSDictionary dictionaryWithObject:[fileAttrs objectForKey:NSFileModificationDate] forKey:NSFileModificationDate] atPath:file];
  }
}

-(NSArray*)getDirPaths:(NSString*)directory {
  int i;
  NSMutableArray *dirContents = [[[NSMutableArray alloc] init] autorelease];
  [dirContents addObjectsFromArray:[FileManager directoryContentsAtPath:directory]];
  // Don't deal with invisible files, prevents .DS_Store corruption
  for (i = 0; i < [dirContents count]; i++) {
    if ([[dirContents objectAtIndex:i] characterAtIndex:0] == '.') {
      [dirContents removeObjectAtIndex:i];
    }
  }
  for (i = 0; i < [dirContents count]; i++) {
    [dirContents replaceObjectAtIndex:i withObject:[NSString pathWithComponents:
                                                    [NSArray arrayWithObjects:directory, [dirContents objectAtIndex:i], nil]]];
  }
  return dirContents;
}

-(void)processDirRecursively:(NSString*)directory toFormat:(int)type {
  int i;
  BOOL isDir = NO;
  NSArray *dirFiles = [self getDirPaths:directory];
  for (i = 0; i < [dirFiles count]; i++) {
    if (![WorkSpace isFilePackageAtPath:[dirFiles objectAtIndex:i]]) {
      if ([FileManager fileExistsAtPath:[dirFiles objectAtIndex:i] isDirectory:&isDir] && isDir) {
        [self processDirRecursively:[dirFiles objectAtIndex:i] toFormat:type];
      }
      else {
        [self convertFile:[dirFiles objectAtIndex:i] toFormat:type];
      }
    }
  }
}

-(void)processDirNonRecursively:(NSString*)directory toFormat:(int)type {
  int i;
  NSArray *dirContents;
  BOOL isDir = NO;
  dirContents = [self getDirPaths:directory];
  for (i = 0; i < [dirContents count]; i++) {
    if (![WorkSpace isFilePackageAtPath:[dirContents objectAtIndex:i]]) {
      if (!([FileManager fileExistsAtPath:[dirContents objectAtIndex:i] isDirectory:&isDir] && isDir)) {
        [self convertFile:[dirContents objectAtIndex:i] toFormat:type];
      }
    }
  }
}

-(void)handleConversions:(NSArray*)filesToConvert toFormat:(int)type {
  int i;
  BOOL isDir = NO;
  [mProgressBar setIndeterminate:YES];
  [mProgressBar setUsesThreadedAnimation:YES];
  [mProgressBar startAnimation:self];
  for (i = 0; i < [filesToConvert count]; i++) {
    if (![WorkSpace isFilePackageAtPath:[filesToConvert objectAtIndex:i]]) {
      if ([FileManager fileExistsAtPath:[filesToConvert objectAtIndex:i] isDirectory:&isDir] && isDir) {
        if ([preferences boolForKey:HandleFoldersKey]) {
          if ([preferences boolForKey:RecursiveFolderHandlingKey]) {
            [self processDirRecursively:[filesToConvert objectAtIndex:i] toFormat:type];
          }
          else {
            [self processDirNonRecursively:[filesToConvert objectAtIndex:i] toFormat:type];
          }
        }
      }
      else {
        [self convertFile:[filesToConvert objectAtIndex:i] toFormat:type];
      }
    }
  }
  [mProgressBar stopAnimation:self];
  [mProgressBar setIndeterminate:NO];
}

// if file is not nil, tell user what its type is before conversion
-(int)chooseTypeOnDrop:(NSString*)file {
  if ([preferences boolForKey:ChooseOnDropKey]) {
    // run the choose panel
    return [[ChoosePanel sharedInstance] askUserForLineBreakType:file];
  }
  return [preferences integerForKey:ConvertToKey];
}

-(void)convertFilesOnDrop {
  int format;
  // if there is only a single file to deal with, tell the user what its type is
  if ([mFilesToProcess count] == 1) {
    format = [self chooseTypeOnDrop:[mFilesToProcess objectAtIndex:0]];
  }
  else {
    format = [self chooseTypeOnDrop:nil];
  }
  // When format is "3", the user chose the cancel button.
  // When format is "-1", there was an error opening a file.
  if (format == jaUnixLBFormat ||
      format == jaMacLBFormat ||
      format == jaDOSLBFormat) {
    [self handleConversions:mFilesToProcess toFormat:format];
  }
  [mFilesToProcess removeAllObjects];
  // quit if it was a quick drag-drop job
  if (mWasLaunchedWithDocument) {
    [NSApp terminate:self];
  }
}

/*
 DELEGATES
 */
#pragma mark -

-(void)applicationWillFinishLaunching:(NSNotification*)aNotification {
  mAppIsLaunching = YES;
}

-(BOOL)application:(NSApplication*)anApplication openFile:(NSString*)aFileName {
  // If app is launching the app was opened with a document
  mWasLaunchedWithDocument = mAppIsLaunching;
  [mFilesToProcess addObject:aFileName];
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(convertFilesOnDrop) object:nil];
  [self performSelector:@selector(convertFilesOnDrop) withObject:nil afterDelay:0.2];
  return YES;
}

-(void)applicationDidFinishLaunching:(NSNotification*)aNotification {
  mAppIsLaunching = NO;
}

-(NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
  return NSDragOperationGeneric;
}

-(unsigned int)draggingUpdated:(id <NSDraggingInfo>)sender {
  [mDragDestCursor set];
  return NSDragOperationGeneric;
}

-(BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
  return YES;
}

-(BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
  [mFilesToProcess addObjectsFromArray:[[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType]];
  [self convertFilesOnDrop];
  return YES;
}

/*
 ACTIONS
 */
#pragma mark -

// Convert document via open panel
-(IBAction)convertViaOpenPanel:(id)sender {
  NSOpenPanel *oPanel = [NSOpenPanel openPanel];
  [oPanel setCanChooseDirectories:[preferences boolForKey:HandleFoldersKey]];
  [oPanel setAllowsMultipleSelection:YES];
  [oPanel setResolvesAliases:YES];
  if ([oPanel runModalForDirectory:NSHomeDirectory() file:nil types:nil] == NSOKButton) {
    [self handleConversions:[oPanel filenames] toFormat:[preferences integerForKey:ConvertToKey]];
  }
}

// Set preferences based on what got selected.
// UNIX is 0, Mac is 1, Dos is 2
-(IBAction)setTypePrefs:(id)sender {
  [preferences setInteger:[sender indexOfSelectedItem] forKey:ConvertToKey];
}

// Change the prefs for checkbox elements
-(IBAction)setCheckboxPrefs:(id)sender {
  if (sender == mAskCheckBox) {
    [preferences setBool:[mAskCheckBox state] forKey:ChooseOnDropKey];
  }
  if (sender == mFoldersCheckBox) {
    [preferences setBool:[mFoldersCheckBox state] forKey:HandleFoldersKey];
    [mRecursiveCheckBox setEnabled:[mFoldersCheckBox state]];
  }
  if (sender == mRecursiveCheckBox) {
    [preferences setBool:[mRecursiveCheckBox state] forKey:RecursiveFolderHandlingKey];
  }
  if (sender == mProtectionCheckBox) {
    [preferences setBool:[mProtectionCheckBox state] forKey:ProtectionOn];
    [mSetProtectionButton setEnabled:[mProtectionCheckBox state]];
  }
}

// Brings up the protection panel.
-(IBAction)showProtectionPanel:(id)sender {
  [[ProtectionPanel sharedInstance] showPanel:sender];
}

// Toggle the preservation of modification dates
-(IBAction)toggleModDates:(id)sender {
  if ([sender state] == NSOffState) {
    [preferences setBool:YES forKey:PreserveModDates];
    [sender setState:NSOnState];
  }
  else {
    [preferences setBool:NO forKey:PreserveModDates];
    [sender setState:NSOffState];
  }
}

@end
