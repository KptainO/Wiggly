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

#define kPathSubset     @"0-9a-z-._%"
#define kSubDelimiters  @";,*+$!)("
#define kPlaceholderPattern [kPathSubset stringByAppendingString:kSubDelimiters]
#define kPlaceholderRegex   @":(\\w+)"
#define kPathDelimiters     @"/"

#define kRoutePatternOptionalPlaceholderNone -1

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
  // defaults.count is just used as an estimation of tokens array possible size
//  NSMutableArray *tokens = [NSMutableArray arrayWithCapacity:self.route.defaults.count];
  NSMutableString *pattern = [NSMutableString stringWithCapacity:self.route.path.length];
  NSUInteger prevStrIdx = 0;
  int firstOptionalPlaceholder = kRoutePatternOptionalPlaceholderNone;
  NSRegularExpression *regex = [NSRegularExpression
                                regularExpressionWithPattern:kPlaceholderRegex
                                options:NSRegularExpressionCaseInsensitive
                                error:nil];
  NSArray *placeholders = [regex matchesInString:self.route.path
                                    options:NSMatchingReportCompletion
                                      range:NSMakeRange(0, self.route.path.length)];


  for (NSTextCheckingResult *placeholderMatch in placeholders) {
    NSRange matchRange = [placeholderMatch range];
    NSRange placeholderRange = [placeholderMatch rangeAtIndex:1];
    NSString *variableName = [self.route.path substringWithRange:placeholderRange];
    NSString *beforePlaceholderStr = [self.route.path substringWithRange:
                                      NSMakeRange(prevStrIdx, matchRange.location - prevStrIdx)];

    WIRoutePlaceholder *placeholder = [self _addRoutePlaceholder:variableName];

//    [tokens addObject:beforePlaceholderStr];
//    [tokens addObject:placeholder];

    [pattern appendString:beforePlaceholderStr];
    [pattern appendString:placeholder.pattern];

    if (!placeholder.required && (firstOptionalPlaceholder == kRoutePatternOptionalPlaceholderNone || !beforePlaceholderStr.length || [beforePlaceholderStr isEqualToString:@"/"]))
    {
      if (firstOptionalPlaceholder == kRoutePatternOptionalPlaceholderNone)
        firstOptionalPlaceholder = placeholderRange.location;
    }
    else
      firstOptionalPlaceholder = kRoutePatternOptionalPlaceholderNone;

    prevStrIdx = matchRange.location + matchRange.length;
  }

  // append any missing part from path (after the last found placeholder)
  // which also means that there is no placeholder which can be optional
  if (prevStrIdx <= (self.route.path.length - 1))
  {
    [pattern appendString:[self.route.path substringFromIndex:prevStrIdx]];

    firstOptionalPlaceholder = kRoutePatternOptionalPlaceholderNone;
  }

  if (firstOptionalPlaceholder != kRoutePatternOptionalPlaceholderNone)
  {
    [pattern insertString:@"(" atIndex:firstOptionalPlaceholder];
    [pattern appendString:@")?"];
  }

  // Optionalize non required tokens sequence at the end of the pattern
//  if (![tokens lastObject].required)
//  {
//    int i = tokens.count - 1;
//
//    while (i >= 0) {
//      if ([tokens[i] isKindOfClass:[WIRoutePlaceholder class]])
//        --i;
//      else
//        break;
//    }
//
//  [tokens insertObject:@"(" atIndex:i+1];
//  [tokens addObject:@")?"];
//  }

  return pattern;
}

- (WIRoutePlaceholder *)_addRoutePlaceholder:(NSString *)name {
  WIRoutePlaceholder  *placeholder = [[WIRoutePlaceholder alloc] init];

  if (self.route.requirements[name])
    placeholder.pattern = self.route.requirements[name];
  else
    placeholder.pattern = [NSString stringWithFormat:@"[%@]+", kPlaceholderPattern];

  placeholder.required = !self.route.defaults[name];

  _placeholders[name] = placeholder;

  return placeholder;
}

@end
