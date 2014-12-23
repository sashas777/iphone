//
//  MAMenuItem.h
//  megapp
//
//  Created by Viktor Kalinchuk on 10/22/14.
//  Copyright (c) 2014 Viktor Kalinchuk. All rights reserved.
//

#import "MAControlsViewController.h"
#import "MABaseViewController_Protected.h"
#import "MAMenuCell.h"
#import "MAMenuItem.h"

@interface MAControlsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *selectedPath;
@property (nonatomic, readonly) NSArray *tableData;

@end

@implementation MAControlsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.contentInset = UIEdgeInsetsMake(statusBarHeight(), 0.f, 0.f, 0.f);
    self.tableView.scrollsToTop = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"MAMenuCell" bundle:nil] forCellReuseIdentifier:[MAMenuCell reuseIdentifier]];
	// Do any additional setup after loading the view.
}

- (NSArray *)tableData {
    return [self.delegate itemsForMenu];
}

- (void)reload {
    [self.tableView reloadData];
}

- (void)setItemSelected:(NSInteger)index notifyDelegate:(BOOL)shouldNotifyDelegate {
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    if (shouldNotifyDelegate) {
        [self.delegate controlsMenu:self didSelectedItemAtIndex:index];
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MAMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:[MAMenuCell reuseIdentifier] forIndexPath:indexPath];
    MAMenuItem *item = self.tableData[indexPath.row];
    cell.item = item;
    return cell;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate controlsMenu:self didSelectedItemAtIndex:indexPath.row];
}


@end
