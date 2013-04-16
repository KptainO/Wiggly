//
// This file is part of Wiggly project
//
// Created by JC on 03/29/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//

#import "WIRoutePattern.h"

#import "WIRoute.h"
#import "WIRoutePlaceholder.h"

NSString  *const kWIPlaceholderNameRegex = @"(:(\\w+))";
NSString  *const kWIPathSubset = @"0-9a-z-._%";
NSString  *const kWISubDelimiters = @";,*+$!)(";

#define kWIPlaceholderRegex   [kWIPathSubset stringByAppendingString:kWISubDelimiters]
#define kWISeparatorSet       [NSCharacterSet characterSetWithCharactersInString:@"/-+_"]

@interface WIRoutePattern () {
  NSMutableDictionary  *_placeholders;
}

@property(nonatomic, strong)NSDictionary  *placeholders;
@property(nonatomic, strong)NSString      *pattern;
@property(nonatomic, strong)WIRoute       *route;
@property(nonatomic, strong)NSString      *shortPath;

- (void)_build;

@end

@implementation WIRoutePattern

#pragma mark -
#pragma mark Initialization

- (id)initWithRoute:(WIRoute *)route {
  if (!(self = [super init]))
    return nil;

  self.route = route;

  return self;
}

- (id)init {
  @throw [NSException exceptionWithName:@"Invalid Ctor" reason:nil userInfo:nil];
  return nil;
}

#pragma mark -
#pragma WIRoute proxy methods

- (NSString *)path {
  return self.route.path;
}

#pragma mark -
#pragma mark Protected Methods

- (void)_build {
  NSMutableString *pattern = [NSMutableString stringWithCapacity:self.route.path.length];
  NSUInteger prevStrIdx = 0;
  NSDictionary *optSegment = nil;
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kWIPlaceholderNameRegex
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil];
  NSArray *placeholders = [regex matchesInString:self.route.path
                                         options:NSMatchingReportCompletion
                                           range:NSMakeRange(0, self.route.path.length)];


  for (NSTextCheckingResult *placeholderMatch in placeholders) {
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
    if (!placeholder.required && !optSegment)
      optSegment = @{@"regexIdx": @(pattern.length), @"pathIdx": @([placeholderMatch rangeAtIndex:1].location) };

    [pattern appendString:placeholder.pattern];

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

    // Generate short path
    self.shortPath = [self.path substringToIndex:pathOptSegIdx];

    // Update pattern
    [pattern insertString:@"(" atIndex:regexOptSegIdx];
    [pattern appendString:@")?"];
  }

  self.pattern = [NSString stringWithString:pattern];
}

- (WIRoutePlaceholder *)_addRoutePlaceholder:(NSString *)name {
  WIRoutePlaceholder  *placeholder = [[WIRoutePlaceholder alloc] init];

  if (self.route.requirements[name])
    placeholder.pattern = self.route.requirements[name];
  else
    placeholder.pattern = [NSString stringWithFormat:@"[%@]+", kWIPlaceholderRegex];

  placeholder.required = !self.route.defaults[name];

  _placeholders[name] = placeholder;

  return placeholder;
}

- (void)setRoute:(WIRoute *)route {
  if (route != _route)
  {
    _route = route;

    self.placeholders = [NSMutableDictionary dictionary];
    [self _build];
  }
}

@end
