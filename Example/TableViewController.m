//
//  TableViewController.m
//  DWLoadingShimmer
//
//  Created by Dwyane on 2018/12/3.
//  Copyright © 2018年 Dwyane_Coding. All rights reserved.
//

#import "TableViewController.h"
#import "DWLoadingShimmer.h"

@interface TableViewController ()
@property (nonatomic, assign) NSInteger numberOfSections;
@property (nonatomic, assign) NSInteger numberOfRows;
@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //默认为 0
    self.numberOfSections = 0;
    self.numberOfRows = 0;
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.numberOfRows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150.0f;
}

- (IBAction)startLoading:(id)sender {
    [DWLoadingShimmer startCovering:self.tableView];
}

- (IBAction)stopLoading:(id)sender {
    self.numberOfSections = 1;
    self.numberOfRows = 10;
    [self.tableView reloadData];
    [DWLoadingShimmer stopCovering:self.tableView];
}


@end
