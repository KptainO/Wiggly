//
// This file is part of Wiggly project
//
// Created by JC on 04/06/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//

#import "WIRouter.h"

#import "WIRoute.h"
#import "WIRouteBuilder.h"
#import "WIRegex.h"

@interface WIRouter ()
@property(nonatomic, weak)WIRegex *regex_;
@end

@implementation WIRouter

@synthesize regex_ = _regex;

#pragma mark -
#pragma mark Initialization

- (id)init {
  CtorNotInherited
}

- (id)initWithRoute:(WIRoute *)route {
  if (!(self = [super init]))
    return nil;

  self.route = route;

  return self;
}

#pragma mark -
#pragma mark Methods

- (NSString *)route:(id)object {
  NSDictionary *values = (NSDictionary *)object;

  if (values && ![values isKindOfClass:[NSDictionary class]])
  {
    NSString *msg = [NSString stringWithFormat:@"Route can't route an object "];
    @throw [NSException exceptionWithName:@"Invalid argument" reason:msg userInfo:nil];

  }
  
  return [self.regex_ generate:values];
}

- (id)match:(NSString *)route {
  return [self.regex_ match:route];
}

- (WIRegex *)regex_ {
  if (!_regex)
    _regex = [self.builder build:self.route];
  
  return _regex;
}

- (WIRouteBuilder *)builder {
  if (!_builder)
    _builder = [[WIRouteBuilder alloc] init];
  
  return _builder;
}

@end
