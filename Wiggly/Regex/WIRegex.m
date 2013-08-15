//
//  WIRegex.m
//  Wiggly
//
//  Created by JC on 6/15/13.
//  Copyright (c) 2013 kptaino. All rights reserved.
//

#import "WIRegex.h"

#import "WIRegexSegment.h"
#import "WIRoute.h"

@implementation WIRegex

#pragma mark -
#pragma mark Initialization

- (id)init { CtorNotInherited }

- (id)initWithRoute:(WIRoute *)route format:(NSString *)segmentFormat {
  if (!(self = [super init]))
    return nil;
  
  self.route = route;
  self.segmentFormat = segmentFormat;
  self.segments = [NSMutableArray array];
  
  return self;
}

- (NSString *)generate {
  return [self generate:nil];
}

- (NSString *)generate:(NSDictionary *)values {
  NSMutableString *path = [[NSMutableString alloc] init];
  NSUInteger previousMarkerIdx = 0;
  BOOL shortVersion = [self _shouldGenerateShortPathWithValues:values];
  
  path.string = shortVersion ? self.atomicPath : self.path;
    
  // replace segments with their associated variable value
  for (WIRegexSegment *segment in self.segments)
  {
    NSString *marker = [NSString stringWithFormat:self.segmentFormat, segment.name];
    NSRange markerRange = [path rangeOfString:marker options:0 range:NSMakeRange(previousMarkerIdx, path.length - previousMarkerIdx)];
    NSString *value = [values[segment.name] description] ?: [segment.defaults description];
    
    if (markerRange.location == NSNotFound)
      continue;
    
    // Segment has no value (no default and no one passed as argument)
    if (!value)
      @throw [NSException exceptionWithName:NSInvalidArgumentException reason:nil userInfo:nil];
    
    // variable does not fulfill segment conditions
    if (![segment matchConditions:value])
      @throw [NSException exceptionWithName:NSInvalidArgumentException reason:nil userInfo:nil];
    
    [path replaceOccurrencesOfString:marker
                          withString:value
                             options:0
                               range:markerRange];
    
    // Optimization: search next segment after the one we've just replaced
    previousMarkerIdx = markerRange.location;
  }
  
  return path;
}

- (NSDictionary *)match:(NSString *)pattern {
  NSTextCheckingResult *matches = [self.pattern firstMatchInString:pattern options:0 range:NSMakeRange(0, pattern.length)];
  NSMutableDictionary *values = [NSMutableDictionary dictionary];
  int i = 0;
  
  if (!matches)
    return nil;
  
  for (WIRegexSegment *segment in self.segments) {
    NSUInteger matchingRangeIdx = ++i + (segment.required ? 0 : 1);
    NSRange valueRange = [matches rangeAtIndex:matchingRangeIdx];
    
    if (valueRange.location != NSNotFound)
      values[segment.name] = [pattern substringWithRange:valueRange];
    else
      values[segment.name] = [segment.defaults description];
  }
   
  return values;
}

- (void)setStringPattern:(NSString *)pattern {
  self.pattern = [NSRegularExpression regularExpressionWithPattern:pattern
                                                           options:0
                                                             error:nil];
}

#pragma mark -
#pragma mark Private methods

- (BOOL)_shouldGenerateShortPathWithValues:(NSDictionary *)values {
  BOOL useShortPath = YES;
  
  if (!self.atomicPath)
    return NO;
  
  for (WIRegexSegment *segment in self.segments)
  {
    NSString *value = [values[segment.name] description];
    
    if (!segment.required && value && ![value isEqualToString:[segment.defaults description]])
    {
      useShortPath = NO;
      break;
    }
  }
  
  return useShortPath;
}

@end
