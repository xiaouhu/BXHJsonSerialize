//
//  ViewController.m
//  BXHJsonSerialize
//
//  Created by 步晓虎 on 2017/9/7.
//  Copyright © 2017年 步晓虎. All rights reserved.
//

#import "ViewController.h"
#import "BXHClassInfo.h"
#import "BXHTempModel.h"

#import "BXHProModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"allArea" ofType:@"json"];
    NSString *jsonStr = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    NSArray *ary = [BXHProModel bxh_SerializeWithJsonStr:jsonStr];
    
    
    NSArray *jsonAry = [BXHProModel bxh_DeserializeToAryWithModelAry:ary];
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
