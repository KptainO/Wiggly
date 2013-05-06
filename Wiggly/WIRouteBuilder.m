//
// This file is part of Wiggly project
//
// Created by JC on 03/29/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//

#import "WIRouteBuilder.h"

#import "WIRoute.h"
#import "WIRoutePlaceholder.h"

NSString  *const kWIPathSubset = @"0-9a-z-._%";
NSString  *const kWISubDelimiters = @";,*+$!)(";
NSString  *const kWIMetaMatchingCommaIdx = @"matchingCommaIdx";

#define kWIPlaceholderRegex   [kWIPathSubset stringByAppendingString:kWISubDelimiters]
#define kWISeparatorSet       [NSCharacterSet characterSetWithCharactersInString:@"/-+_"]

@interface WIRouteBuilder ()

@property(nonatomic, strong)NSString        *regex;

@property(nonatomic, strong)WIRoute         *route;
@property(nonatomic, strong)NSString        *longPath_;
@property(nonatomic, strong)NSString        *shortPath_;
@property(nonatomic, strong)NSMutableArray  *placeholders_;
/// Meta/additional data about placeholders that should stay private/protected
@property(nonatomic, strong)NSMutableDictionary *placeholdersMeta_;

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

}

- (NSDictionary *)match:(NSString *)pattern {
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:self.regex options:0 error:nil];
  NSTextCheckingResult *matches = [regex firstMatchInString:pattern options:0 range:NSMakeRange(0, pattern.length)];
  NSMutableDictionary *values = [NSMutableDictionary dictionary];
  NSMutableDictionary *allValues = nil;

  if (!matches)
    return nil;

  for (WIRoutePlaceholder *placeholder in self.placeholders) {
    NSUInteger rangeIdx = [self.placeholdersMeta_[placeholder.name][kWIMetaMatchingCommaIdx] intValue];
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

- (NSString *)builder:(WIRouteBuilder *)builder markerForPlaceholder:(WIRoutePlaceholder *)placeholder {
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
  // track how many capture comma we have so far inside the generated regex
  NSUInteger numberOfCommaGroups = 0;
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

    WIRoutePlaceholder *placeholder = [self _addRoutePlaceholder:variableName];

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

    self.placeholdersMeta_[placeholder.name] = [NSMutableDictionary dictionaryWithDictionary:@{
    kWIMetaMatchingCommaIdx : @(1 + numberOfCommaGroups)
    }];

    numberOfCommaGroups += 1 + [NSRegularExpression regularExpressionWithPattern:placeholder.conditions options:0 error:nil].numberOfCaptureGroups;

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
      WIRoutePlaceholder *placeholder = self.placeholders[i];

      [placeholder setRequired:NO];

      // Add 1 to matching comma index to reflect the (optional segment) comma which has been added
      self.placeholdersMeta_[placeholder.name][kWIMetaMatchingCommaIdx] = @2;//@([self.placeholdersMeta_[placeholder.name][kWIMetaMatchingCommaIdx] intValue] + 1);
    }
  }

  self.regex = [NSString stringWithString:pattern];
}

- (WIRoutePlaceholder *)_addRoutePlaceholder:(NSString *)name {
  WIRoutePlaceholder  *placeholder = [[WIRoutePlaceholder alloc] initWithName:name];

  if (self.route.requirements[name])
    placeholder.conditions = self.route.requirements[name];
  else
    placeholder.conditions = [NSString stringWithFormat:@"[%@]+", kWIPlaceholderRegex];

  [self.placeholders_ addObject:placeholder];

  return placeholder;
}

- (void)setRoute:(WIRoute *)route {
  if (route != _route)
  {
    _route = route;

    self.placeholders_ = [NSMutableArray array];
    self.placeholdersMeta_ = [NSMutableDictionary dictionary];
    self.shortPath_ = nil;
    
    [self _build];
  }
}

- (NSArray *)placeholders {
  return self.placeholders_;
}

@end
