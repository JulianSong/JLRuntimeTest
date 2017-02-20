//
//  JLRumtimeProxyObject.m
//  JLRumtimeTest
//
//  Created by Julian Song on 17/2/16.
//  Copyright © 2017年 Julian Song. All rights reserved.
//

#import "JLRuntimeProxyObject.h"

@implementation JLRuntimeProxyObject

- (void)proxySomething
{
    NSLog(@"%@,%@",self.description,@"proxySomething");
}

- (void)proxySomething3
{
    NSLog(@"%@,%@",self.description,@"proxySomething3");
}
@end
