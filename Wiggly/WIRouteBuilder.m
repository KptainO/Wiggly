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

#define kWISeparatorSet       [NSCharacterSet characterSetWithCharactersInString:@"/-+_"]

@interface WIRouteBuilder ()

@property(nonatomic, strong)NSString        *regex;

@property(nonatomic, strong)WIRoute         *route;
@property(nonatomic, strong)NSString        *longPath_;
@property(nonatomic, strong)NSString        *shortPath_;
@property(nonatomic, strong)NSMutableArray  *segments_;

- (void)_build;

@end

@implementation WIRouteBuilder

#pragma mark -
#pragma mark Initialization

- (id)initWithRoute:(WIRoute *)route {
  if (!(self = [super init]))
    return nil;

  self.markerDelegate = self;

  self.route = route;

  return self;
}

- (id)init {
  @throw [NSException exceptionWithName:@"Invalid Ctor" reason:nil userInfo:nil];
  return nil;
}

- (NSString *)generate:(NSDictionary *)values {
  NSMutableString *path = [[NSMutableString alloc] init];
  NSUInteger previousMarkerIdx = 0;
  NSMutableDictionary *allValues = nil;
  BOOL shortVersion = [self _shouldGenerateShortPathWithValues:values];

  path.string = shortVersion ? self.shortPath_ : self.longPath_;

  // Merge default values with those provided by user
  allValues = [NSMutableDictionary dictionaryWithCapacity:self.segments.count];

  for (WIRegexSegment *segment in self.segments)
    if (!shortVersion || segment.required)
      allValues[segment.name] = values[segment.name]
      ? [values[segment.name] description]
      : [segment.defaults description];

  if (self.delegate)
    allValues.dictionary = [self.delegate builder:self willUseValues:allValues];

  // replace segments with their associated variable value
  for (WIRegexSegment *segment in self.segments)
  {
    NSString *marker = [self.markerDelegate builder:self markerForPlaceholder:segment];
    NSRange markerRange = [path rangeOfString:marker options:0 range:NSMakeRange(previousMarkerIdx, path.length - previousMarkerIdx)];

    if (markerRange.location == NSNotFound)
      continue;

    // variable does not fulfill segment conditions
    if (![segment matchConditions:allValues[segment.name]])
      @throw [NSException exceptionWithName:@"" reason:@"" userInfo:nil];

    [path replaceOccurrencesOfString:marker
                          withString:allValues[segment.name]
                             options:0
                               range:markerRange];

    // Optimization: search next segment after the one we've just replaced
    previousMarkerIdx = markerRange.location;
  }

  return path;
}

- (NSDictionary *)match:(NSString *)pattern {
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:self.regex options:0 error:nil];
  NSTextCheckingResult *matches = [regex firstMatchInString:pattern options:0 range:NSMakeRange(0, pattern.length)];
  NSMutableDictionary *values = [NSMutableDictionary dictionary];
  NSMutableDictionary *allValues = nil;
  
  if (!matches)
    return nil;

  for (WIRegexSegment *segment in self.segments) {
    NSUInteger matchingRangeIdx = segment.order + 1 + (segment.required ? 0 : 1);
    NSRange valueRange = [matches rangeAtIndex:matchingRangeIdx];
    
    if (valueRange.location != NSNotFound)
      values[segment.name] = [pattern substringWithRange:valueRange];
  }

  if (self.delegate)
    values.dictionary = [self.delegate builder:self didReceivedValues:values];

  allValues = [NSMutableDictionary dictionaryWithDictionary:self.route.defaults];
  [allValues addEntriesFromDictionary:values];
  
  return allValues;
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
#pragma WIRoute proxy methods

- (NSString *)path {
  return self.longPath_;
}

- (NSString *)longPath_ {
  return self.route.path;
}

#pragma mark -
#pragma mark Protected Methods

- (void)_build {
  NSMutableString *pattern = [NSMutableString stringWithCapacity:self.route.path.length];
  NSUInteger prevStrIdx = 0;
  NSDictionary *optSegment = nil;
  NSString *marker = [NSString stringWithFormat:@"(%@)", [self.markerDelegate builderMarkerRegex:self]];
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:marker
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil];
  NSArray *segments = [regex matchesInString:self.route.path
                                         options:NSMatchingReportCompletion
                                           range:NSMakeRange(0, self.route.path.length)];


  for (NSTextCheckingResult *segmentMatch in segments)
  {
    NSRange matchRange = [segmentMatch range];
    NSRange segmentRange = [segmentMatch rangeAtIndex:2];
    NSString *variableName = [self.route.path substringWithRange:segmentRange];
    NSString *prevStr = [self.route.path substringWithRange:
                                      NSMakeRange(prevStrIdx, matchRange.location - prevStrIdx)];

    WIRegexSegment *segment = [self _addSegment:variableName];

    [pattern appendString:prevStr];

    // If there is a static text before the segment whose not a separator, then
    // we reset regexOptSegIdx value
    if (prevStr.length > 1 || [prevStr rangeOfCharacterFromSet:kWISeparatorSet].location == NSNotFound)
      optSegment = nil;
    
    // Try to determine if first optional segment
    // Optional part is obviously at the current end of building patten
    // and at segment position inside path
    if (self.route.defaults[variableName] && !optSegment)
      optSegment = @{
        @"regexIdx": @(pattern.length),
        @"pathIdx": @([segmentMatch rangeAtIndex:1].location),
        @"segmentIdx": @(self.segments.count - 1)
      };

    [pattern appendString:[NSString stringWithFormat:@"(%@)", segment.conditions]];

    prevStrIdx = matchRange.location + matchRange.length;
  }

  // Append any missing part from path (after the last found segment)
  // which also means that there is no segment which can be optional
  if (prevStrIdx <= (self.route.path.length - 1))
  {
    [pattern appendString:[self.route.path substringFromIndex:prevStrIdx]];

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

    // Generate paths
    self.shortPath_ = [self.longPath_ substringToIndex:pathOptSegIdx];

    // Update pattern
    [pattern insertString:@"(" atIndex:regexOptSegIdx];
    [pattern appendString:@")?"];

    // Set every segment which is in the optional segment as optional
    // and update its metadata
    for (int i = [optSegment[@"segmentIdx"] intValue]; i < self.segments.count; ++i)
    {
      WIRegexSegment *segment = self.segments[i];

      [segment setRequired:NO];
    }
  }

  self.regex = [NSString stringWithString:pattern];
}

- (WIRegexSegment *)_addSegment:(NSString *)name {
  WIRegexSegment  *segment = [[WIRegexSegment alloc] initWithName:name];

  segment.defaults = self.route.defaults[name];
  segment.conditions = self.route.requirements[name];
  segment.order = self.segments_.count;
  
  [self.segments_ addObject:segment];

  return segment;
}

- (BOOL)_shouldGenerateShortPathWithValues:(NSDictionary *)values {
  BOOL useShortPath = YES;

  if (!self.shortPath_)
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

- (void)setRoute:(WIRoute *)route {
  if (route != _route)
  {
    _route = route;

    self.segments_ = [NSMutableArray array];
    self.shortPath_ = nil;
    
    [self _build];
  }
}

- (NSArray *)segments {
  return self.segments_;
}

@end
