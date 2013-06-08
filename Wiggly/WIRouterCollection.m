//
// This file is part of  Wiggly project
//
// Created by JC on 06/08/13.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.
//

#import "WIRouterCollection.h"

#import "WIRouter.h"

@interface WIRouterCollection ()

@end

@implementation WIRouterCollection

#pragma mark -
#pragma mark Initialization

+ (id)collection {
    return [[[self class] alloc] init];
}

#pragma mark -
#pragma mark Collection insertion

- (void)add:(NSString *)routeName route:(WIRoute *)route {
    
}

- (void)add:(NSString *)routeName router:(WIRouter *)router {
    
}

- (void)add:(WIRouterCollection *)collection {
    
}

#pragma mark -
#pragma mark Routing

- (NSString *)route:(NSString *)routeName {
    return nil;
}

- (NSString *)route:(NSString *)routeName with:(id)object; {
    return nil;
}

- (id)match:(NSString *)path {
    return nil;
}

@end
