//
//  ViewController.m
//  Architecture
//
//  Created by Hu, Peng on 1/21/16.
//  Copyright © 2016 Hu, Peng. All rights reserved.
//

#import "ViewController.h"
#import "People.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Fake Demo
    [People fetchAllWithCompletionBlock:^(BOOL success, id  _Nonnull result) {
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
