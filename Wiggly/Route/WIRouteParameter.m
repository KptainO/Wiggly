//
// This file is part of Wiggly project
//
// Created by JC on 03/31/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//

#import "WIRouteParameter.h"

@interface WIRouteParameter ()
@property(nonatomic, copy)NSString  *name;
@end

@implementation WIRouteParameter

#pragma mark -
#pragma mark Initialization

- (id)initWithName:(NSString *)name {
  if (!(self = [super init]))
    return nil;

  self.name = name;

  return self;
}

- (id)init {
  @throw [NSException exceptionWithName:@"Invalid Ctor" reason:nil userInfo:nil];
  return nil;
}

#pragma mark -
#pragma mark Methods

- (BOOL)matchConditions:(NSString *)value {
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:self.conditions options:0 error:nil];

  return [regex matchesInString:value options:0 range:NSMakeRange(0, value.length)].count > 0;
}

- (NSString *)description {
  return self.conditions;
}

@end
