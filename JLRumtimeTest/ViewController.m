//
//  ViewController.m
//  JLRumtimeTest
//
//  Created by Julian Song on 17/2/15.
//  Copyright © 2017年 Julian Song. All rights reserved.
//

#import "ViewController.h"
#import <objc/objc-runtime.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self sendMsg];
    }
    if (indexPath.row == 1) {
        [self getMethodAndCall];
    }
}

- (void)sendMsg
{
    SEL doSh = @selector(doSomething);
    objc_msgSend(self,doSh);
    
    SEL doShWithArg = @selector(doSomethingWithArg:);
    NSString *returnVal = objc_msgSend(self,doShWithArg,@"oh");
    NSLog(@"Return:%@",returnVal);
}

- (void)getMethodAndCall
{
    void (*doSh)(id,SEL)= (void (*)(id,SEL))[self methodForSelector:@selector(doSomething)];
    doSh(self,@selector(doSomething));
    
    NSString *(*doShWithArg)(id,SEL,NSString *) = (NSString *(*)(id,SEL,NSString *))[self methodForSelector:@selector(doSomethingWithArg:)];
    NSString *returnVal = doShWithArg(self,@selector(doSomethingWithArg:),@"wow!");
    NSLog(@"Return:%@",returnVal);
}

- (void)doSomething
{
    NSLog(@"do something");
}

- (NSString *)doSomethingWithArg:(NSString *)arg
{
    NSLog(@"do something with arg:%@",arg);
    return [NSString stringWithFormat:@"Done with:%@",arg];
}
@end
