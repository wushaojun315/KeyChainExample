//
//  ZZZKeyChainHelper.h
//  KeyChainExample
//
//  Created by 吴少军 on 2017/9/20.
//  Copyright © 2017年 Wondersgroup. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  从NSDictionary中获取到账户id的key
 */
extern NSString *const kAccountIdentifierAccessKey;

/**
 *  从NSDictionary中获取到账户密码的key
 */
extern NSString *const kAccountPasswordAccessKey;

@interface ZZZKeyChainHelper : NSObject

#pragma mark - 下方是关于普通账户的增删改查
/**
 增：将账户信息保存到keychain中
    当用户名输入框输入完毕之后，如果在keychain中有对应用户名的账户信息，就获取对应密码填入密码输入框中
    （实际上，app应用应该都是用户名框中有所有已经保存好的账户信息，可以直接下拉选择的，这样做更常见吧，但是下拉那个东西我懒得写了，哈哈）

 @param accountIdentifier 用于保存到keychain中账户信息的账户id（这个是登录信息的唯一标识，也作为keychain里面item的唯一标识，一般可以直接传入登录用户名，如果登录用户名也唯一的话）
 @param accountPassword 用于保存到keychain中账户信息的账户密码
 @return 新增是否成功
 */
+ (BOOL)addAccountInfoToKeyChainWithAccountIdentifier:(NSString *)accountIdentifier
                                      accountPassword:(NSString *)accountPassword;


/**
 删：根据账户id的唯一性从keychain中删除对应账户的信息

 @param accountIdentifier 唯一标识一个keychain item的项，也是一个账户的唯一标识（例如，登录用户名）
 @return 删除是否成功
 */
+ (BOOL)deleteAccountInfoFromKeyChainWithAccountIdentifier:(NSString *)accountIdentifier;


/**
 改：修改对应账户id的keychain项信息（主要修改对应账户的账户密码，一般不会直接调用）

 @param accountIdentifier 账户的唯一标识符，用于表示我们需要修改哪个账户的信息（例如，可以直接传入用户名）
 @param newPassword 账户需要更改的的新密码
 @return 修改是否成功
 */
+ (BOOL)updateAccountPasswordForAccount:(NSString *)accountIdentifier
                        withNewPassword:(NSString *)newPassword;


/**
 查：根据账户id，获取保存在keychain中对应的账户密码

 @param accountIdentifier 账户标识，表示我们需要获取哪个账户的密码
 @return 返回账户密码
 */
+ (NSString *)getAccountPasswordForAccount:(NSString *)accountIdentifier;

#pragma mark - 下方是关于自动登录账户的增删改查
/**
 增：新增一个autoLoginAccount作为标记的用户名密码信息保存到keychain中，作为进入应用之后自动登录的账户
    其他保存在keychain里面的用户名和密码不作为自动登录，而是在手动输入用户名之后，如果keychain中有对应的项，那就获取密码，自动填入密码输入框

 @param accountIdentifier 账户信息的账户id
 @param accountPassword 账户信息的账户密码
 @return 新增是否成功
 */
+ (BOOL)addAutoLoginAccountToKeyChainWithAccountIdentifier:(NSString *)accountIdentifier
                                           accountPassword:(NSString *)accountPassword;;


/**
 删：删除保存在keychain中的用于自动登录的账户信息
 
 @return 删除是否成功
 */
+ (BOOL)deleteAutoLoginAccountFromKeyChain;


/**
 改：修改保存在keychain中的用于自动登录的账户信息（一般不直接调用）

 @param newAccountIdentifier 新的用于自动登录的账户id
 @param newAccountPassword 新的用于自动登录的账户密码
 @return 是否修改成功
 */
+ (BOOL)updateAutoLoginAccountWithNewAccountIdentifier:(NSString *)newAccountIdentifier
                                    newAccountPassword:(NSString *)newAccountPassword;


/**
 查：获取保存在keyichain中用于自动登录的账户信息

 @return 账户信息，包括用户名、密码（对应的key的话，在上面定义好了）
 */
+ (NSDictionary *)getAutoLoginAccountInfo;

#pragma mark - 所有的keychain items操作

/**
 获取所有的保存在keychain中的账户信息（账户名、账户密码等）

 @return 包含所有登录账户项的数组
 */
+ (NSArray *)getAllAccountInfosFromKeychain;

/**
 清空keychain保存的所有账户信息

 @return 清空信息是否成功
 */
+ (BOOL)clearAllAccountInfosInKeychain;

@end
