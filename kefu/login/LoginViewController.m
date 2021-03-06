//
//  LoginViewController.m
//
//  Copyright © 2016年 beetle. All rights reserved.

#import "LoginViewController.h"

#import "LoginViewOneCell.h"
#import "LoginViewTwoCell.h"

#import "Masonry.h"
#import "AFNetworking.h"
#import "LevelDB.h"
#import "MBProgressHUD.h"
#import "CustomerMessageListViewController.h"
#import <gobelieve/IMService.h>
#import "AppDB.h"
#import "Config.h"
#import "Token.h"
#import "IQKeyboardManager.h"

#define kFirstCellOffset    20
#define kSecondMax      60
#define kTextFieldTag  40

@interface LoginViewController (){
    
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableVIewTop;
@property (strong, nonatomic) UITextField *loginNumberTextField;
@property (strong, nonatomic) UITextField *loginPasswordTextField;

@property (strong,nonatomic) LoginViewOneCell *headCell;

@property (nonatomic) CGFloat registerOneCellHeight;



@end

@implementation LoginViewController


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
    
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self navigationController] setNavigationBarHidden:NO];

   
    [[IQKeyboardManager sharedManager] isEnabled];
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    if([[[UIDevice currentDevice] systemVersion] doubleValue] >=
       7.0){
        self.tableVIewTop.constant = -kFirstCellOffset;
    }
}



- (void)dealloc {
    NSLog(@"LoginViewControler dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    if (self.hint) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"你的账号在其它设备上登录"
                                                       delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark-- UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        static NSString *identifyCell = @"LoginViewOneCell";
        LoginViewOneCell *cell = (LoginViewOneCell *)[tableView dequeueReusableCellWithIdentifier:identifyCell];
        if (cell == nil) {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"LoginViewOneCell" owner:self options:nil];
            cell = [array objectAtIndex:0];
        }
        cell.titleLabel.numberOfLines = 0;
        cell.titleLabel.lineBreakMode = NSLineBreakByClipping;
        cell.titleLabel.text = NSLocalizedString(@"loginTiele", @"蕾丝客服");
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.headCell = cell;
        return cell;
    }
    else if (indexPath.row == 1) {
        //登录界面
        static NSString *identifyCell = @"LoginViewTwoCell";
        LoginViewTwoCell *cell = (LoginViewTwoCell *)[tableView dequeueReusableCellWithIdentifier:identifyCell];
        if (cell == nil) {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"LoginViewTwoCell" owner:self options:nil];
            cell = [array objectAtIndex:0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userNumberTextField.placeholder = NSLocalizedString(@"loginUserNum" , @"请输入客服账号");
         cell.passwordTextField.placeholder = NSLocalizedString(@"loginPassword" , @"请输入密码");
        self.loginNumberTextField = cell.userNumberTextField;
        self.loginPasswordTextField = cell.passwordTextField;
        
        [cell.loginUserButton.layer setMasksToBounds:YES];
        [cell.loginUserButton.layer setCornerRadius:5.0];
        [cell.loginUserButton setTitle:NSLocalizedString(@"loginButtonEven" , @"登录") forState:UIControlStateNormal];
        [cell.loginUserButton addTarget:self action:@selector(loginSubmitButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
        
    }
   
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.view.frame.size.height < 556) {
        // iphone4/4s 屏幕长度比较短
        CGFloat allcellHeight = 586.0f;
        if (indexPath.row == 0) {
            self.registerOneCellHeight = allcellHeight/3.0+10;
            return allcellHeight/3.0+10;
        }
        else if(indexPath.row == 1){
            return allcellHeight/3.0;
        }
        else if(indexPath.row == 2){
            return allcellHeight/3.0-10;
        }
        else{
            return allcellHeight*2/3.0-10;
        }
    }
    else{
        //iphone4/4s以上 均匀分布
        if (indexPath.row == 0) {
            self.registerOneCellHeight = self.view.frame.size.height/3.0+10;
            return self.view.frame.size.height/3.0 + 10;
        }
        else if(indexPath.row == 1){
            return self.view.frame.size.height/3.0;
        }
        return  0;
    }
}

/**
 *  拉伸顶部代码
 *
 *  @param scrollView
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint offset = scrollView.contentOffset;
    if (offset.y < 0) {
        CGRect rect = self.headCell.backgroundImageView.frame;
        rect.origin.y = offset.y + kFirstCellOffset;
        rect.size.height = self.registerOneCellHeight - rect.origin.y;
        self.headCell.backgroundImageView.frame = rect;
    }
}

#pragma mark -- 登录界面Action

- (void)loginSubmitButtonAction:(id)sender{
    if (self.loginNumberTextField.text.length == 0){
        [self.view makeToast:@"客服账号不能为空" duration:1.0 position:@"center"];
        return;
    }
    if(self.loginPasswordTextField.text.length == 0) {
        [self.view makeToast:@"密码不能为空" duration:1.0 position:@"center"];
        return;
    }
    
    //取消键盘
    [[self findFirstResponderBeneathView:self.view] resignFirstResponder];

    NSString *userName = self.loginNumberTextField.text;
    NSString *password = self.loginPasswordTextField.text;
    [self login:userName password:password];
    
}

#define  PLATFORM_IOS 1

- (void)login:(NSString*)username password:(NSString*)password {
    NSString *base = [NSString stringWithFormat:@"%@/", KEFU_API];
    NSURL *baseURL = [NSURL URLWithString:base];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    NSString *name = [[UIDevice currentDevice] name];
#if TARGET_IPHONE_SIMULATOR
    NSString *deviceID = @"7C8A8F5B-E5F4-4797-8758-05367D2A4D61";
#else
    NSString *deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
#endif
    
    NSDictionary *dict = @{@"username":username, @"password":password,
                           @"device_name":name,  @"device_id":deviceID,
                           @"platform":@PLATFORM_IOS};
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"login.doing", @"登录中...");
    
    [manager POST:@"auth/token"
       parameters:dict
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSLog(@"response:%@", responseObject);
              Token *token = [Token instance];
              token.accessToken = [responseObject objectForKey:@"access_token"];
              token.refreshToken = [responseObject objectForKey:@"refresh_token"];
              token.uid = [[responseObject objectForKey:@"uid"] longLongValue];
              token.storeID = [[responseObject objectForKey:@"store_id"] longLongValue];
              token.name = [responseObject objectForKey:@"name"];
              token.expireTimestamp = (int)time(NULL) + [[responseObject objectForKey:@"expires_in"] intValue];
              token.loginTimestamp = (int)time(NULL);
              [token save];
              
              [MBProgressHUD hideHUDForView:self.view animated:YES];
              CustomerMessageListViewController *ctrl = [[CustomerMessageListViewController alloc] init];
              UINavigationController *navigationCtrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
              [UIApplication sharedApplication].keyWindow.rootViewController = navigationCtrl;
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSHTTPURLResponse* r = (NSHTTPURLResponse*)task.response;
              NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
              if (errorData) {
                  NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                  NSLog(@"failure:%@ %@ %zd", error, [serializedData objectForKey:@"error"], r.statusCode);
                  NSString *e = [serializedData objectForKey:@"error"];
                  if (e.length > 0) {
                      hud.labelText = e;
                  } else {
                      hud.labelText = NSLocalizedString(@"login.failure", @"登录失败");
                  }
              } else {
                  hud.labelText = NSLocalizedString(@"login.failure", @"登录失败");
              }

              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                  [MBProgressHUD hideHUDForView:self.view animated:YES];
              });
          }
     ];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

@end
