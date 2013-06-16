//
// This file is part of Wiggly project
//
// Created by JC on 03/29/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//

#import "WIRoute.h"

#import "WIRouteConstraintURL.h"

@interface WIRoute ()
@property(nonatomic, strong)NSString            *path;
@property(nonatomic, strong)NSMutableDictionary *requirements;
@property(nonatomic, strong)NSMutableDictionary *defaults;
@end

@implementation WIRoute

#pragma mark -
#pragma mark Initialization

+ (id)routeWithPath:(NSString *)path {
  return [[[self class] alloc] initWithPath:path];
}

- (id)initWithPath:(NSString *)path {
  if (!(self = [super init]))
    return nil;

  self.path = path;
  self.requirements = [NSMutableDictionary dictionary];
  self.defaults = [NSMutableDictionary dictionary];

  return self;
}

- (id)init {
  @throw [NSException exceptionWithName:@"Invalid Ctor" reason:nil userInfo:nil];
  return nil;
}

- (void)merge:(id<WIRouteConstraintURL>)constraint {
  if (!constraint)
    return;
  
  if (constraint.path)
    self.path  = [constraint.path stringByAppendingPathComponent:self.path];
}

@end
