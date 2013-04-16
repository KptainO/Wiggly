//
// This file is part of Wiggly project
//
// Created by JC on 03/31/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//

#import "WIRoutePlaceholder.h"

@interface WIRoutePlaceholder ()
@property(nonatomic, copy)NSString  *name;
@end

@implementation WIRoutePlaceholder

#pragma mark -
#pragma mark Initialization

- (id)initWithName:(NSString *)name {
  if (!(self = [super init]))
    return nil;

  self.name = name;
  self.required = YES;

  return self;
}

- (id)init {
  @throw [NSException exceptionWithName:@"Invalid Ctor" reason:nil userInfo:nil];
  return nil;
}

#pragma mark -
#pragma mark Methods

- (NSString *)description {
  return self.pattern;
}

@end
