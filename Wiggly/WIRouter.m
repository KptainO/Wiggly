//
// This file is part of Wiggly project
//
// Created by JC on 04/06/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//

#import "WIRouting.h"

#import "WIRoute.h"
#import "WIRouteBuilder.h"

@interface WIRouting ()
@property(nonatomic, strong)WIRoute         *route_;
@property(nonatomic, strong)WIRouteBuilder  *builder_;
@property(nonatomic, assign)Class           builderClass_;
@end

@implementation WIRouting

@synthesize builder_ = builder_;

#pragma mark -
#pragma mark Initialization

- (id)initWithRoute:(WIRoute *)route {
  return [self initWithRoute:route builder:[WIRouteBuilder class]];
}

- (id)initWithRoute:(WIRoute *)route builder:(__unsafe_unretained Class)builder {
  if (!(self = [super init]))
    return nil;

  self.route_ = route;
  self.builderClass_ = builder;

  return self;
}

#pragma mark -
#pragma mark Methods

- (NSString *)route:(id)object {
  NSDictionary *values = (NSDictionary *)values;

  if (![values isKindOfClass:[NSDictionary class]])
  {
    NSString *msg = [NSString stringWithFormat:@"Route %@ can't route an object ", self.builder_.path];
    @throw [NSException exceptionWithName:@"Invalid argument" reason:msg userInfo:nil];

  }

  return [self.builder_ generate:values];
}

- (id)matches:(NSString *)route {
  return [self.builder_ match:route];
}

- (WIRouteBuilder *)builder_ {
  if (!builder_)
    self.builder_ = [[self.builderClass_ alloc] initWithRoute:self.route_];

  return builder_;
}

@end
