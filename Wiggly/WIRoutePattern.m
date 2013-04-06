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

NSString  *const kWIPlaceholderNameRegex = @":(\\w+)";
NSString  *const kWIPathSubset = @"0-9a-z-._%";
NSString  *const kWISubDelimiters = @";,*+$!)(";

#define kWIOptPlaceholderNone -1
#define kWIPlaceholderRegex   [kWIPathSubset stringByAppendingString:kWISubDelimiters]
#define kWISeparatorSet       [NSCharacterSet characterSetWithCharactersInString:@"/-+_"]

@interface WIRoutePattern () {
  NSMutableDictionary  *_placeholders;
}

@property(nonatomic, strong)NSDictionary  *placeholders;
@property(nonatomic, strong)NSString      *pattern;
@property(nonatomic, strong)WIRoute       *route;

- (NSString *)_buildPattern;

@end

@implementation WIRoutePattern

#pragma mark -
#pragma mark Initialization

- (id)initWithRoute:(WIRoute *)route {
  if (!(self = [super init]))
    return nil;

  self.placeholders = [NSMutableDictionary dictionary];
  self.route = route;
  self.pattern = [self _buildPattern];

  return self;
}

- (id)init {
  @throw [NSException exceptionWithName:@"Invalid Ctor" reason:nil userInfo:nil];
  return nil;
}

#pragma mark -
#pragma mark Methods

- (NSString *)generate:(NSDictionary *)variables {
  
}

- (NSArray *)matches:(NSString *)routePath {
  
}

#pragma mark -
#pragma mark Protected Methods

- (NSString *)_buildPattern {
  NSMutableString *pattern = [NSMutableString stringWithCapacity:self.route.path.length];
  NSUInteger prevStrIdx = 0;
  int firstOptionalPlaceholder = kWIOptPlaceholderNone;
  NSRegularExpression *regex = [NSRegularExpression
                                regularExpressionWithPattern:kWIPlaceholderNameRegex
                                options:NSRegularExpressionCaseInsensitive
                                error:nil];
  NSArray *placeholders = [regex matchesInString:self.route.path
                                    options:NSMatchingReportCompletion
                                      range:NSMakeRange(0, self.route.path.length)];


  for (NSTextCheckingResult *placeholderMatch in placeholders) {
    NSRange matchRange = [placeholderMatch range];
    NSRange placeholderRange = [placeholderMatch rangeAtIndex:1];
    NSString *variableName = [self.route.path substringWithRange:placeholderRange];
    NSString *prevStr = [self.route.path substringWithRange:
                                      NSMakeRange(prevStrIdx, matchRange.location - prevStrIdx)];

    WIRoutePlaceholder *placeholder = [self _addRoutePlaceholder:variableName];

    [pattern appendString:prevStr];

    // If there is a static text before the placeholder whose not a separator, then
    // we reset firstOptionalPlaceholder value
    if (prevStr.length > 1 ||
        [prevStr rangeOfCharacterFromSet:kWISeparatorSet].location == NSNotFound)
      firstOptionalPlaceholder = kWIOptPlaceholderNone;
    // Try to determine if first optional placeholder
    if (!placeholder.required && firstOptionalPlaceholder == kWIOptPlaceholderNone)
      firstOptionalPlaceholder = pattern.length;

    [pattern appendString:placeholder.pattern];

    prevStrIdx = matchRange.location + matchRange.length;
  }

  // Append any missing part from path (after the last found placeholder)
  // which also means that there is no placeholder which can be optional
  if (prevStrIdx <= (self.route.path.length - 1))
  {
    [pattern appendString:[self.route.path substringFromIndex:prevStrIdx]];

    firstOptionalPlaceholder = kWIOptPlaceholderNone;
  }

  // Set optional placeholder as optional inside regex by surrounding with ()?
  if (firstOptionalPlaceholder != kWIOptPlaceholderNone)
  {
    if ([pattern characterAtIndex:firstOptionalPlaceholder - 1] == '/')
      firstOptionalPlaceholder -= 1;

    [pattern insertString:@"(" atIndex:firstOptionalPlaceholder];
    [pattern appendString:@")?"];
  }

  return [NSString stringWithString:pattern];
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

@end
