//
// This file is part of Wiggly project
//
// Created by JC on 03/29/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//

#import "WIRouteBuilder.h"

#import "WIRoute.h"
#import "WIRouteParameter.h"
#import "WIRegexSegment.h"
#import "WIRegex.h"

#define kWISeparatorSet       [NSCharacterSet characterSetWithCharactersInString:@"/-+_"]

@interface WIRouteBuilder ()

@property(nonatomic, strong)WIRoute         *route_;

@end

@implementation WIRouteBuilder

#pragma mark -
#pragma mark Initialization

- (id)init {
  if (!(self = [super init]))
    return nil;

  self.markerDelegate = self;

  return self;
}

#pragma mark -
#pragma WIRouteBuilderMarkerDelegate methods

- (NSString *)builderMarkerRegex:(WIRouteBuilder *)builder {
  static NSString  *const marker = @":(\\w+)";

  return marker;
}

- (NSString *)builder:(WIRouteBuilder *)builder markerForPlaceholder:(WIRouteParameter *)segment {
  return [@":" stringByAppendingString:segment.name];
}

#pragma mark -
#pragma mark Protected Methods

- (WIRegex *)build:(WIRoute *)route {
  WIRegex *regex;
  
  self.route_ = route;
  regex = [self _build];
  self.route_ = nil;
  
  return regex;
}

- (WIRegex *)_build {
  WIRegex *regex = [[WIRegex alloc] initWithRoute:self.route_ format:@":%@"];
  NSMutableString *pattern = [NSMutableString stringWithCapacity:self.route_.path.length];
  NSUInteger prevStrIdx = 0;
  NSDictionary *optSegment = nil;
  NSString *segmentPattern = [NSString stringWithFormat:@"(%@)", [self.markerDelegate builderMarkerRegex:self]];
  NSRegularExpression *segmentsRegex = [NSRegularExpression regularExpressionWithPattern:segmentPattern
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil];
  NSArray *segments = [segmentsRegex matchesInString:self.route_.path
                                         options:NSMatchingReportCompletion
                                           range:NSMakeRange(0, self.route_.path.length)];


  for (NSTextCheckingResult *segmentMatch in segments)
  {
    NSRange matchRange = [segmentMatch range];
    NSRange segmentRange = [segmentMatch rangeAtIndex:2];
    NSString *variableName = [self.route_.path substringWithRange:segmentRange];
    NSString *prevStr = [self.route_.path substringWithRange:
                                      NSMakeRange(prevStrIdx, matchRange.location - prevStrIdx)];

    WIRegexSegment *segment = [self _addSegment:variableName regex:regex];

    [pattern appendString:prevStr];

    // If there is a static text before the segment whose not a separator, then
    // we reset regexOptSegIdx value
    if (prevStr.length > 1 || [prevStr rangeOfCharacterFromSet:kWISeparatorSet].location == NSNotFound)
      optSegment = nil;
    
    // Try to determine if first optional segment
    // Optional part is obviously at the current end of building patten
    // and at segment position inside path
    if (self.route_.defaults[variableName] && !optSegment)
      optSegment = @{
        @"regexIdx": @(pattern.length),
        @"pathIdx": @([segmentMatch rangeAtIndex:1].location),
        @"segmentIdx": @(regex.segments.count - 1)
      };

    [pattern appendString:[NSString stringWithFormat:@"(%@)", segment.conditions]];

    prevStrIdx = matchRange.location + matchRange.length;
  }

  // Append any missing part from path (after the last found segment)
  // which also means that there is no segment which can be optional
  if (prevStrIdx <= (self.route_.path.length - 1))
  {
    [pattern appendString:[self.route_.path substringFromIndex:prevStrIdx]];

    optSegment = nil;
  }

  /**
   * There is an optional segment this means that:
   * - some segments are in fact optional, so mark them as
   * - we can generate a shorter path
   * - regex will contain an optional matching segment
   */
  if (optSegment)
  {
    int regexOptSegIdx = [optSegment[@"regexIdx"] intValue];
    int pathOptSegIdx = [optSegment[@"pathIdx"] intValue];

    if ([pattern characterAtIndex:regexOptSegIdx - 1] == '/')
    {
      regexOptSegIdx -= 1;
      pathOptSegIdx -= 1;
    }

    // Update pattern
    [pattern insertString:@"(" atIndex:regexOptSegIdx];
    [pattern appendString:@")?"];

    // Set every segment which is in the optional segment as optional
    // and update its metadata
    for (int i = [optSegment[@"segmentIdx"] intValue]; i < regex.segments.count; ++i)
    {
      WIRegexSegment *segment = regex.segments[i];

      [segment setRequired:NO];
    }
    
    // Generate paths
    regex.atomicPath = [self.route_.path substringToIndex:pathOptSegIdx];
  }
  else
    regex.atomicPath = self.route_.path;
  
  regex.path = self.route_.path;
  regex.pattern = [NSRegularExpression regularExpressionWithPattern:pattern
                                                          options:0
                                                            error:nil];

  return regex;
}

- (WIRegexSegment *)_addSegment:(NSString *)name regex:(WIRegex *)regex {
  WIRegexSegment  *segment = [[WIRegexSegment alloc] initWithName:name];

  segment.defaults = self.route_.defaults[name];
  segment.conditions = self.route_.requirements[name];
  
  [regex.segments addObject:segment];

  return segment;
}

@end
