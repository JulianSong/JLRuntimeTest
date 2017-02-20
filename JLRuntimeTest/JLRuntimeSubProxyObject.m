//
//  JLRuntimeSubProxyObject.m
//  JLRuntimeTest
//
//  Created by Julian Song on 17/2/20.
//  Copyright © 2017年 Julian Song. All rights reserved.
//

#import "JLRuntimeSubProxyObject.h"

@implementation JLRuntimeSubProxyObject
- (void)proxySomething
{
    NSLog(@"%@,%@",self.description,@"proxySomething");
}
@end
