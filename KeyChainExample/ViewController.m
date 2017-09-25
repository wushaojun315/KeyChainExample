//
//  ViewController.m
//  KeyChainExample
//
//  Created by 吴少军 on 2017/9/20.
//  Copyright © 2017年 Wondersgroup. All rights reserved.
//

#import "ViewController.h"
#import "ZZZKeyChainHelper.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 一进入应用就查看是否保存有自动登录的账户信息
    // 如果有自动登录信息的话，直接用账户信息自动登录，直接跳转到主页
    // 如果没有自动登录信息的话，需要先跳转到登录信息录入页面，输入登录信息登录后进入主页
    NSDictionary *loginInfoDict = [ZZZKeyChainHelper getAutoLoginAccountInfo];
    if (loginInfoDict) {
        // 有信息的话可以获取用户名、密码进行登录请求，或者做些其他的事(比如下面就是将保存好的账户信息显示在输入框中)
        self.userNameTextField.text = loginInfoDict[kAccountIdentifierAccessKey];
        self.passwordTextField.text = loginInfoDict[kAccountPasswordAccessKey];
        
        self.userNameLabel.text = loginInfoDict[kAccountIdentifierAccessKey];
        self.passwordLabel.text = loginInfoDict[kAccountPasswordAccessKey];
    } else {
        // 如果返回了空就要跳到登录页面，进行信息录入操作了。。。
    }
    
    
    // 如果要获取到keychain中所有保存的账户信息的话用下面的代码就好了
    // 有的应用（像QQ）登录的界面上，用户名选择可以下拉选择，然后如果保存了密码的那就可以直接密码自动填写上，然后调用登录接口就好了
    // 所以，如果需要获取这一系列的账户名等等，可以如下使用
    NSArray *accountInfoArray = [ZZZKeyChainHelper getAllAccountInfosFromKeychain];
    for (NSDictionary *accountInfoDict in accountInfoArray) {
        NSLog(@"******************************************");
        NSLog(@"标号：%lu", (unsigned long)[accountInfoArray indexOfObject:accountInfoDict]);
        NSLog(@"用户名：%@", accountInfoDict[kAccountIdentifierAccessKey]);
        NSLog(@"密码：%@", accountInfoDict[kAccountPasswordAccessKey]);
        NSLog(@"******************************************");
    }
    
    
    // 如果要清空所有的keychain保存的账户信息就调用下面注释的代码
//    [ZZZKeyChainHelper clearAllAccountInfosInKeychain];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 保存用户名和密码的账户信息
 */
- (IBAction)saveInfoToKeyChain:(id)sender
{
    [ZZZKeyChainHelper addAccountInfoToKeyChainWithAccountIdentifier:self.userNameTextField.text
                                                     accountPassword:self.passwordTextField.text];
}

/**
 删除对应用户名对应的那条账户信息
 */
- (IBAction)deleteInfoFromKeyChain:(id)sender
{
    [ZZZKeyChainHelper deleteAccountInfoFromKeyChainWithAccountIdentifier:self.userNameTextField.text];
}

/**
 输入了对应的用户名之后，获取这个账户对应的密码
 每个保存在keychain中的账户可以依据用户名完全标识
 */
- (IBAction)readInfoFromKeyChain:(id)sender
{
    // 直接通过用户名拿到密码
    NSString *password = [ZZZKeyChainHelper getAccountPasswordForAccount:self.userNameTextField.text];
    
    self.passwordLabel.text = password;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

/**
 将当前输入的用户名和密码信息保存，作为自动登录的账户（以后打开app就不用到登录信息的录入页面，而是直接登录完成了）
 */
- (IBAction)saveAutoLoginInfo:(id)sender
{
    [ZZZKeyChainHelper addAutoLoginAccountToKeyChainWithAccountIdentifier:self.userNameTextField.text
                                                          accountPassword:self.passwordTextField.text];
}

/**
 删除保存的用于自动登录的信息，删除之后就不会自动登录，而是进入登录界面输入信息再登录了
 
 但是并不影响keychain保存的其他用户名密码信息，在输入用户名后，还是可以从中获取到对应的账户密码
 */
- (IBAction)deleteAutoLoginInfo:(id)sender
{
    [ZZZKeyChainHelper deleteAutoLoginAccountFromKeyChain];
}

/**
 读取保存在keychain中的，用于作为进入app直接自动登录的账户信息
 */
- (IBAction)readAutoLoginInfo:(id)sender
{
    NSDictionary *accountInfoDict = [ZZZKeyChainHelper getAutoLoginAccountInfo];
    // 通过定义在文件中的key值获取返回的用户名和字典
    NSString *userName = [accountInfoDict objectForKey:kAccountIdentifierAccessKey];
    NSString *password = [accountInfoDict objectForKey:kAccountPasswordAccessKey];
    // 显示在界面中
    self.userNameLabel.text = userName;
    self.passwordLabel.text = password;
}

@end
