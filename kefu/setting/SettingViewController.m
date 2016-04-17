//
//  SettingViewController.m
//  kefu
//
//  Created by 杨朋亮 on 17/4/16.
//  Copyright © 2016年 beetle. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingInforTableViewCell.h"
#import "QuitTableViewCell.h"
#import "AppDB.h"
#import "LoginViewController.h"
#import <gobelieve/IMService.h>

@interface SettingViewController () <UITableViewDelegate,UITableViewDataSource>
@property(nonatomic) int64_t number;
@property(nonatomic, copy) NSString *name;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    
    
    LevelDB *ldb = [AppDB instance].db;
    
    id object = [ldb objectForKey:@"user_auth"];
    int64_t uid = [[object objectForKey:@"uid"] longLongValue];
    NSString *token = [object objectForKey:@"access_token"];
    int64_t storeID = [[object objectForKey:@"store_id"] longLongValue];
    NSString *name = [object objectForKey:@"name"];
    
    self.number = uid;
    self.name = name;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0f;
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section==0) {
        return 2;
    }else if (section == 1) {
        return 1;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        static NSString *reusableCellWithIdentifier = @"SettingInforTableViewCell";
        SettingInforTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
        
        if (cell == nil) {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SettingInforTableViewCell" owner:self options:nil];
            cell = [array objectAtIndex:0];
        }
        if (indexPath.row == 0) {
            [cell.nameLabel setText:@"客服工号"];
            NSString *number = [NSString stringWithFormat:@"%lld", self.number];
            [cell.valueLabel setText:number];
        }else if(indexPath.row == 1){
            [cell.nameLabel setText:@"客服姓名"];
            if (self.name.length > 0) {
                [cell.valueLabel setText:self.name];
            } else {
                [cell.valueLabel setText:@""];
            }
        }
        
        [cell.line setHidden:NO];
        if (indexPath.row==1) {
            [cell.line setHidden:YES];
        }
        
        return cell;
        
    }else if (indexPath.section==1) {
        static NSString *reusableCellWithIdentifier = @"QuitTableViewCell";
        QuitTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
        
        if (cell == nil) {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"QuitTableViewCell" owner:self options:nil];
            cell = [array objectAtIndex:0];
            [cell.quitButton addTarget:self action:@selector(quitAction) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //取消选中项
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

- (void)logout {
    NSLog(@"quit...");
    LevelDB *ldb = [AppDB instance].db;
    [ldb setObject:@{} forKey:@"user_auth"];

    [[IMService instance] stop];
    
    LoginViewController *vtr = [[LoginViewController alloc] init];
    [UIApplication sharedApplication].keyWindow.rootViewController = vtr;
}
- (void)quitAction{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否退出当前账户" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"退出",nil];
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex==1) {

            [self logout];
        }
    }];
}

@end
