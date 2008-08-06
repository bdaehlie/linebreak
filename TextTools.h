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

// indicative of a file's format (what type of line breaks it has)
enum {
  jaUnixLBFormat = 0,
  jaMacLBFormat = 1,
  jaDOSLBFormat = 2
};

@interface TextTools : NSObject {
  
}

// these convert the passed file to the respective line break type
+(void)convertFileToUnix:(NSString*)passedFile;
+(void)convertFileToMac:(NSString*)passedFile;
+(void)convertFileToDOS:(NSString*)passedFile;

// this detects a file's line break format
+(int)detectLBFormat:(NSString*)passedFile;

@end
