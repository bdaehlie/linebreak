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
#import "TextTools.h"
#import "stdio.h"

@implementation TextTools

+(void)reportConvertFailureForFile:(NSString*)filePath {
  NSLog(@"LineBreak failed to convert file at path: %@", filePath);
}

+(void)convertFileToUnix:(NSString*)passedFile {
  FILE *handle = fopen([passedFile cString], "r");
  if (!handle) {
    [self reportConvertFailureForFile:passedFile];
    return;
  }
  FILE *tmpHandle = tmpfile();
  if (!tmpHandle) {
    fclose(handle);
    [self reportConvertFailureForFile:passedFile];
    return;
  }

  int curChar;
  while ((curChar = fgetc(handle)) != EOF) {
    if (curChar == '\r') {
      curChar = fgetc(handle);
      if (curChar != '\n') {
        ungetc(curChar, handle);
      }
      fputc('\n', tmpHandle);
    }
    else {
      fputc(curChar, tmpHandle);
    }
  }
  fclose(handle);

  handle = fopen([passedFile cString], "w");
  if (!handle) {
    fclose(tmpHandle);
    [self reportConvertFailureForFile:passedFile];
    return;
  }

  rewind(tmpHandle);
  while ((curChar = fgetc(tmpHandle)) != EOF) {
    fputc(curChar, handle);
  }

  fclose(handle);
  fclose(tmpHandle);
}

+(void)convertFileToMac:(NSString*)passedFile {
  FILE *handle = fopen([passedFile cString], "r");
  if (!handle) {
    [self reportConvertFailureForFile:passedFile];
    return;
  }
  FILE *tmpHandle = tmpfile();
  if (!tmpHandle) {
    fclose(handle);
    [self reportConvertFailureForFile:passedFile];
    return;
  }

  int curChar;
  while ((curChar = fgetc(handle)) != EOF) {
    if (curChar == '\r') {
      curChar = fgetc(handle);
      if (curChar != '\n') {
        ungetc(curChar, handle);
      }
      fputc('\r', tmpHandle);
    }
    else if (curChar == '\n') {
      fputc('\r', tmpHandle);
    }
    else {
      fputc(curChar, tmpHandle);
    }
  }
  fclose(handle);

  handle = fopen([passedFile cString], "w");
  if (!handle) {
    fclose(tmpHandle);
    [self reportConvertFailureForFile:passedFile];
    return;
  }

  rewind(tmpHandle);
  while ((curChar = fgetc(tmpHandle)) != EOF) {
    fputc(curChar, handle);
  }

  fclose(handle);
  fclose(tmpHandle);
}

+(void)convertFileToDOS:(NSString*)passedFile {
  FILE *handle = fopen([passedFile cString], "r");
  if (!handle) {
    [self reportConvertFailureForFile:passedFile];
    return;
  }
  FILE *tmpHandle = tmpfile();
  if (!tmpHandle) {
    fclose(handle);
    [self reportConvertFailureForFile:passedFile];
    return;
  }

  int curChar;
  while ((curChar = fgetc(handle)) != EOF) {
    if (curChar == '\n') {
      fputc('\r', tmpHandle);
      fputc('\n', tmpHandle);
    }
    else if (curChar == '\r') {
      curChar = fgetc(handle);
      if (curChar != '\n') {
        ungetc(curChar, handle);
      }
      fputc('\r', tmpHandle);
      fputc('\n', tmpHandle);
    }
    else {
      fputc(curChar, tmpHandle);
    }
  }
  fclose(handle);

  handle = fopen([passedFile cString], "w");
  if (!handle) {
    fclose(tmpHandle);
    [self reportConvertFailureForFile:passedFile];
    return;
  }

  rewind(tmpHandle);
  while ((curChar = fgetc(tmpHandle)) != EOF) {
    fputc(curChar, handle);
  }

  fclose(handle);
  fclose(tmpHandle);
}

+(int)detectLBFormat:(NSString*)passedFile {
  FILE *handle = fopen([passedFile cString], "r");
  if (!handle) {
    NSLog(@"Failed to detect line break format, can't open file at path: %@",
          passedFile);
    return -1;
  }

  // default is UNIX
  int returnValue = jaUnixLBFormat;
  int curChar;
  while ((curChar = fgetc(handle)) != EOF) {
    if (curChar == '\r') {
      // see if the next character is '\n'
      if ((curChar = fgetc(handle)) != EOF) {
        if (curChar == '\n') {
          returnValue = jaDOSLBFormat;
          break;
        }
      }
      // if the next char isn't '\n' then this is a Mac file
      returnValue = jaMacLBFormat;
      break;
    }
    if (curChar == '\n') {
      // its UNIX, and thats the default so just break
      break;
    }
  }
  fclose(handle);
  return returnValue;
}

@end
