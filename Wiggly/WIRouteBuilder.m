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

NSString  *const kWIPathSubset = @"0-9a-z-._%";
NSString  *const kWISubDelimiters = @";,*+$!)(";

#define kWIPlaceholderRegex   [kWIPathSubset stringByAppendingString:kWISubDelimiters]
#define kWISeparatorSet       [NSCharacterSet characterSetWithCharactersInString:@"/-+_"]

@interface WIRouteBuilder ()

@property(nonatomic, strong)NSString        *regex;

@property(nonatomic, strong)WIRoute         *route;
@property(nonatomic, strong)NSString        *longPath_;
@property(nonatomic, strong)NSString        *shortPath_;
@property(nonatomic, strong)NSMutableArray  *placeholders_;

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
  allValues = [NSMutableDictionary dictionaryWithCapacity:self.placeholders.count];

  for (WIRouteParameter *placeholder in self.placeholders)
    if (!shortVersion || placeholder.required)
      allValues[placeholder.name] = values[placeholder.name]
      ? [values[placeholder.name] description]
      : [self.defaults[placeholder.name] description];

  if (self.delegate)
    allValues.dictionary = [self.delegate builder:self willUseValues:allValues];

  // replace placeholders with their associated variable value
  for (WIRouteParameter *placeholder in self.placeholders)
  {
    NSString *marker = [self.markerDelegate builder:self markerForPlaceholder:placeholder];
    NSRange markerRange = [path rangeOfString:marker options:0 range:NSMakeRange(previousMarkerIdx, path.length - previousMarkerIdx)];

    if (markerRange.location == NSNotFound)
      continue;

    // variable does not fulfill placeholder conditions
    if (![placeholder matchConditions:allValues[placeholder.name]])
      @throw [NSException exceptionWithName:@"" reason:@"" userInfo:nil];

    [path replaceOccurrencesOfString:marker
                          withString:allValues[placeholder.name]
                             options:0
                               range:markerRange];

    // Optimization: search next placeholder after the one we've just replaced
    previousMarkerIdx = markerRange.location;
  }

  return path;
}

- (NSDictionary *)match:(NSString *)pattern {
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:self.regex options:0 error:nil];
  NSTextCheckingResult *matches = [regex firstMatchInString:pattern options:0 range:NSMakeRange(0, pattern.length)];
  NSMutableDictionary *values = [NSMutableDictionary dictionary];
  NSMutableDictionary *allValues = nil;
  int i = 0;
  
  if (!matches)
    return nil;

  for (WIRouteParameter *placeholder in self.placeholders) {
    NSUInteger rangeIdx = ++i + (placeholder.required ? 0 : 1);
    NSRange valueRange = [matches rangeAtIndex:rangeIdx];
    
    if (valueRange.location != NSNotFound)
      values[placeholder.name] = [pattern substringWithRange:valueRange];
  }

  if (self.delegate)
    values.dictionary = [self.delegate builder:self didReceivedValues:values];

  allValues = [NSMutableDictionary dictionaryWithDictionary:self.defaults];
  [allValues addEntriesFromDictionary:values];
  
  return allValues;
}

#pragma mark -
#pragma WIRouteBuilderMarkerDelegate methods

- (NSString *)builderMarkerRegex:(WIRouteBuilder *)builder {
  static NSString  *const marker = @":(\\w+)";

  return marker;
}

- (NSString *)builder:(WIRouteBuilder *)builder markerForPlaceholder:(WIRouteParameter *)placeholder {
  return [@":" stringByAppendingString:placeholder.name];
}

#pragma mark -
#pragma WIRoute proxy methods

- (NSString *)path {
  return self.longPath_;
}

- (NSDictionary *)defaults {
  return self.route.defaults;
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
  NSArray *placeholders = [regex matchesInString:self.route.path
                                         options:NSMatchingReportCompletion
                                           range:NSMakeRange(0, self.route.path.length)];


  for (NSTextCheckingResult *placeholderMatch in placeholders)
  {
    NSRange matchRange = [placeholderMatch range];
    NSRange placeholderRange = [placeholderMatch rangeAtIndex:2];
    NSString *variableName = [self.route.path substringWithRange:placeholderRange];
    NSString *prevStr = [self.route.path substringWithRange:
                                      NSMakeRange(prevStrIdx, matchRange.location - prevStrIdx)];

    WIRouteParameter *placeholder = [self _addRouteParameter:variableName];

    [pattern appendString:prevStr];

    // If there is a static text before the placeholder whose not a separator, then
    // we reset regexOptSegIdx value
    if (prevStr.length > 1 || [prevStr rangeOfCharacterFromSet:kWISeparatorSet].location == NSNotFound)
      optSegment = nil;
    
    // Try to determine if first optional segment
    // Optional part is obviously at the current end of building patten
    // and at placeholder position inside path
    if (self.route.defaults[variableName] && !optSegment)
      optSegment = @{
        @"regexIdx": @(pattern.length),
        @"pathIdx": @([placeholderMatch rangeAtIndex:1].location),
        @"placeholderIdx": @(self.placeholders.count - 1)
      };

    [pattern appendString:[NSString stringWithFormat:@"(%@)", placeholder.conditions]];

    prevStrIdx = matchRange.location + matchRange.length;
  }

  // Append any missing part from path (after the last found placeholder)
  // which also means that there is no placeholder which can be optional
  if (prevStrIdx <= (self.route.path.length - 1))
  {
    [pattern appendString:[self.route.path substringFromIndex:prevStrIdx]];

    optSegment = nil;
  }

  /**
   * There is an optional segment this means that:
   * - some placeholders are in fact optional, so mark them as
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

    // Set every placeholder which is in the optional segment as optional
    // and update its metadata
    for (int i = [optSegment[@"placeholderIdx"] intValue]; i < self.placeholders.count; ++i)
    {
      WIRouteParameter *placeholder = self.placeholders[i];

      [placeholder setRequired:NO];
    }
  }

  self.regex = [NSString stringWithString:pattern];
}

- (WIRouteParameter *)_addRouteParameter:(NSString *)name {
  WIRouteParameter  *placeholder = [[WIRouteParameter alloc] initWithName:name];

  if (self.route.requirements[name])
    placeholder.conditions = self.route.requirements[name];
  else
    placeholder.conditions = [NSString stringWithFormat:@"[%@]+", kWIPlaceholderRegex];
  
  [self.placeholders_ addObject:placeholder];

  return placeholder;
}

- (BOOL)_shouldGenerateShortPathWithValues:(NSDictionary *)values {
  BOOL useShortPath = YES;

  if (!self.shortPath_)
    return NO;

  for (WIRouteParameter *placeholder in self.placeholders)
  {
    NSString *value = [values[placeholder.name] description];

    if (!placeholder.required && value && ![value isEqualToString:[self.defaults[placeholder.name] description]])
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

    self.placeholders_ = [NSMutableArray array];
    self.shortPath_ = nil;
    
    [self _build];
  }
}

- (NSArray *)placeholders {
  return self.placeholders_;
}

@end
