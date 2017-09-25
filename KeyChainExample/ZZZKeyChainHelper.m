//
//  ZZZKeyChainHelper.m
//  KeyChainExample
//
//  Created by 吴少军 on 2017/9/20.
//  Copyright © 2017年 Wondersgroup. All rights reserved.
//

#import "ZZZKeyChainHelper.h"

NSString *const kAccountIdentifierAccessKey = @"zzzGetAccountIdentifierFromKeyChainKey";
NSString *const kAccountPasswordAccessKey = @"zzzGetAccountPasswordFromKeyChainKey";

@implementation ZZZKeyChainHelper
#pragma mark - 所有账户信息的增删改查
/**
 一般账户信息通用的keychain的组成字典
 */
+ (NSMutableDictionary *)basicKeyChainDictWithAccountIdentifier:(NSString *)specificAccountIdentifier
{
    // 如果没有信息的话，并不用建立查询字典了
    if (!specificAccountIdentifier || [specificAccountIdentifier isEqualToString:@""]) {
        return nil;
    }
    
    NSMutableDictionary *keychainDictionary = [[NSMutableDictionary alloc] init];
    
    // 表示我们保存的keychain类型是GenericPassword
    [keychainDictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    
    // 这些保存的所有key-value项，要能够保证一个keychain item的独立性唯一性，所以一定需要有区别于其他的唯一标识来区分每一条keychain item，这里我们使用每个账户的唯一标识accountIdentifier + kSecAttrService值来区分
    //（我这里是实在在官方文档还有这些博客上，没有看到关于如何唯一标识keychain项的靠谱说法，反正是肯定要保证唯一性的，否则怎么唯一获取、唯一更新）
    [keychainDictionary setObject:specificAccountIdentifier forKey:(id)kSecAttrAccount];
    [keychainDictionary setObject:@"com.companyName.appName" forKey:(id)kSecAttrService];
    
    return keychainDictionary;
}

/**
 增：新增一条账户记录
 */
+ (BOOL)addAccountInfoToKeyChainWithAccountIdentifier:(NSString *)accountIdentifier
                                      accountPassword:(NSString *)accountPassword
{
    // 如果没有信息的话，并不用新增了
    if (!accountIdentifier || !accountPassword || [accountIdentifier isEqualToString:@""] || [accountPassword isEqualToString:@""]) {
        return NO;
    }
    
    NSMutableDictionary *keychainDict = [self basicKeyChainDictWithAccountIdentifier:accountIdentifier];
    
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)keychainDict, NULL);
    
    if (status == errSecSuccess) {
        // 如果已经保存过的话，那就更新就好了
        return [self updateAccountPasswordForAccount:accountIdentifier withNewPassword:accountPassword];
    } else if (status == errSecItemNotFound) {
        // 没有找到对应项，那就新增吧
        NSData *passwordData = [accountPassword dataUsingEncoding:NSUTF8StringEncoding];
        [keychainDict setObject:passwordData forKey:(id)kSecValueData];
        
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)keychainDict, NULL);
        return status == errSecSuccess;
    }
    return NO;
}

/**
 删：删除一条账户记录
 */
+ (BOOL)deleteAccountInfoFromKeyChainWithAccountIdentifier:(NSString *)accountIdentifier
{
    // 如果没有信息的话，并不用删除了
    if (!accountIdentifier || [accountIdentifier isEqualToString:@""]) {
        return NO;
    }
    
    NSMutableDictionary *queryDict = [self basicKeyChainDictWithAccountIdentifier:accountIdentifier];
    
    OSStatus status = errSecSuccess;
    // 找到了就删除，没找到就直接删除成功吧，否则情况判断比较麻烦
    if (SecItemCopyMatching((__bridge CFDictionaryRef)queryDict, NULL) == errSecSuccess) {
        status = SecItemDelete((__bridge CFDictionaryRef)queryDict);
    }
    
    return status == errSecSuccess;
}

/**
 改：修改一个账户对应的密码（这个好像一般不会主动调用到，在新增的方法中，如果查询到已经有了就会自动更新）
 */
+ (BOOL)updateAccountPasswordForAccount:(NSString *)accountIdentifier
                        withNewPassword:(NSString *)newPassword
{
    // 如果没有信息的话，并不用更新了
    if (!accountIdentifier || !newPassword || [accountIdentifier isEqualToString:@""] || [newPassword isEqualToString:@""]) {
        return NO;
    }
    
    NSMutableDictionary *keychainDict = [[NSMutableDictionary alloc] init];
    
    NSData *passwordData = [newPassword dataUsingEncoding:NSUTF8StringEncoding];
    [keychainDict setObject:passwordData forKey:(id)kSecValueData];
    
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)[self basicKeyChainDictWithAccountIdentifier:accountIdentifier], (__bridge CFDictionaryRef)keychainDict);
    
    return status == errSecSuccess;
}

/**
 查：查询一个账户id对应的密码
 */
+ (NSString *)getAccountPasswordForAccount:(NSString *)accountIdentifier
{
    // 如果没有信息的话，并不用查询了
    if (!accountIdentifier || [accountIdentifier isEqualToString:@""]) {
        return nil;
    }
    
    NSMutableDictionary *queryDict = [[NSMutableDictionary alloc] init];
    
    // 表示我们保存的keychain类型是GenericPassword
    [queryDict setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    [queryDict setObject:accountIdentifier forKey:(id)kSecAttrAccount];
    
    // 设置kSecReturnData属性key为kCFBooleanTrue，表示我需要返回的结果只是 CFDataRef类型的密码
    [queryDict setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)queryDict, &result);
    
    if (status == errSecSuccess) {
        // 查询成功得到密码数据
        NSData *resultData = (__bridge_transfer NSData *)result;
        NSString *passwordString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
        return passwordString;
    } else {
        return nil;
    }
}

#pragma mark - 自动登录账户信息的增删改查
/**
 自动登录账户信息的keychain字典
 */
+ (NSMutableDictionary *)basicKeyChainDictForAutoLoginAccount
{
    NSMutableDictionary *keychainDict = [[NSMutableDictionary alloc] init];
    // 表示我们保存的keychain类型是GenericPassword
    [keychainDict setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    
    // 设置kSecAttrService值，标识这个账户信息是我们用来自动登录的
    // 所以我们在搜索的时候加上这一条就能与上面的普通登录信息区分开来（因为普通的这条不一样呀）
    [keychainDict setObject:@"autoLoginAccountIdentifierTag" forKey:(id)kSecAttrService];
    
    return keychainDict;
}

/**
 判断当前的keychain中是否已经保存有用于自动登录的账户信息（以autoLoginAccountIdentifierTag标记的唯一性为查询依据）
 */
+ (BOOL)isAutoLoginAccountExistInKeyChain
{
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)[self basicKeyChainDictForAutoLoginAccount], NULL);
    
    return status == errSecSuccess;
}

/**
 增：新增自动登录账户信息
 */
+ (BOOL)addAutoLoginAccountToKeyChainWithAccountIdentifier:(NSString *)accountIdentifier
                                           accountPassword:(NSString *)accountPassword
{
    // 如果没有信息的话，并不用新增了
    if (!accountIdentifier || !accountPassword || [accountIdentifier isEqualToString:@""] || [accountPassword isEqualToString:@""]) {
        return NO;
    }
    
    
    // 如果普通类型中已经保存有这项信息的话，就先把普通类型中的这个item删掉
    // 这是为了解决一个账户信息会被在两种类型中各自保存一份的问题
    [self deleteAccountInfoFromKeyChainWithAccountIdentifier:accountIdentifier];
    
    
    
    if ([self isAutoLoginAccountExistInKeyChain]) {
        // 自动登录信息如果已经保存过的话，那就更新就好了
        return [self updateAutoLoginAccountWithNewAccountIdentifier:accountIdentifier newAccountPassword:accountPassword];
    } else {
        // 没有找到对应项，那就新增吧
        NSMutableDictionary *keychainDict = [self basicKeyChainDictForAutoLoginAccount];
        // 在基础的字典项中添加上用户名和密码
        [keychainDict setObject:accountIdentifier forKey:(id)kSecAttrAccount];
        NSData *passwordData = [accountPassword dataUsingEncoding:NSUTF8StringEncoding];
        [keychainDict setObject:passwordData forKey:(id)kSecValueData];
        
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)keychainDict, NULL);
        return status == errSecSuccess;
    }
}

/**
 删：删除自动登录账户信息
 */
+ (BOOL)deleteAutoLoginAccountFromKeyChain
{
    OSStatus status = errSecSuccess;
    // 找到了就删除，没找到就直接删除成功吧，否则情况判断比较麻烦
    if ([self isAutoLoginAccountExistInKeyChain]) {
        status = SecItemDelete((__bridge CFDictionaryRef)[self basicKeyChainDictForAutoLoginAccount]);
    }
    
    return status == errSecSuccess;
}

/**
 改：修改自动登录账户信息
 */
+ (BOOL)updateAutoLoginAccountWithNewAccountIdentifier:(NSString *)newAccountIdentifier
                                    newAccountPassword:(NSString *)newAccountPassword
{
    // 如果没有信息的话，并不用修改了
    if (!newAccountIdentifier || !newAccountPassword || [newAccountIdentifier isEqualToString:@""] || [newAccountPassword isEqualToString:@""]) {
        return NO;
    }
    NSMutableDictionary *queryDict = [self basicKeyChainDictForAutoLoginAccount];
    
    // 新的信息，修改了用户名、密码（autoLoginAccount的标识不变）
    NSMutableDictionary *newKeychainDict = [[NSMutableDictionary alloc] init];
    [newKeychainDict setObject:newAccountIdentifier forKey:(id)kSecAttrAccount];
    NSData *passwordData = [newAccountPassword dataUsingEncoding:NSUTF8StringEncoding];
    [newKeychainDict setObject:passwordData forKey:(id)kSecValueData];
    
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)queryDict, (__bridge CFDictionaryRef)newKeychainDict);
    
    return status = errSecSuccess;
}

/**
 查：获取保存在keychain中的自动登录账户信息
 */
+ (NSDictionary *)getAutoLoginAccountInfo
{
    if ([self isAutoLoginAccountExistInKeyChain]) {
        NSMutableDictionary *queryDict = [self basicKeyChainDictForAutoLoginAccount];
        // 我们需要返回一个字典（因为用户名我们需要从这个字典中获取）所以设置设置kSecReturnAttributes为kCFBooleanTrue
        [queryDict setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
        CFTypeRef keychainDictRef = NULL;
        SecItemCopyMatching((__bridge CFDictionaryRef)queryDict, &keychainDictRef);
        NSDictionary *keychainDict = (__bridge_transfer NSDictionary *)keychainDictRef;
        // 但是上面的字典中并没有密码在其中，所以为了获取密码，我们设置kSecReturnData为kCFBooleanTrue，并删除kSecReturnAttributes
        [queryDict removeObjectForKey:(id)kSecReturnAttributes];
        [queryDict setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
        CFTypeRef passwordDataRef = NULL;
        SecItemCopyMatching((__bridge CFDictionaryRef)queryDict, &passwordDataRef);
        NSData *passwordData = (__bridge_transfer NSData *)passwordDataRef;
        NSString *passwordString = [[NSString alloc] initWithData:passwordData encoding:NSUTF8StringEncoding];
        // 拿到用户名和密码之后，返回字典，用我们定义好的key
        return @{kAccountIdentifierAccessKey: [keychainDict objectForKey:(id)kSecAttrAccount],
                 kAccountPasswordAccessKey  : passwordString};
    }
    return nil;
}

#pragma mark - 所有的keychain items操作

/**
 获取所有的保存在keychain中的账户信息（账户名、账户密码等）（如果保存有自动登录账户的话，这个账户数据可能会有两条，因为普通保存状态还有一条）
 */
+ (NSArray *)getAllAccountInfosFromKeychain
{
    // 定义用于匹配所有keychain项的字典
    NSMutableDictionary *queryDict = [[NSMutableDictionary alloc] init];
    [queryDict setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    // 我们需要获取所有所以需要设置以下key和value
    [queryDict setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
    [queryDict setObject:(__bridge id)kSecMatchLimitAll forKey:(__bridge id)kSecMatchLimit];
    // 获取所有keychain item的数组
    CFTypeRef resultDictArrayRef = NULL;
    SecItemCopyMatching((__bridge CFDictionaryRef)queryDict, &resultDictArrayRef);
    NSArray *resultDictArray = (__bridge_transfer NSArray *)resultDictArrayRef;
    
    // 从keychain item数组中获取每个账户的账户id，然后通过账户id获取账户密码，然后组成字典存入到账户信息的数组中
    NSMutableArray *accountInfoArray = [NSMutableArray array];
    for (NSDictionary *resultDict in resultDictArray) {
        NSString *accountIdentifier = resultDict[(id)kSecAttrAccount];
        NSString *accountPassword = [self getAccountPasswordForAccount:accountIdentifier];
        [accountInfoArray addObject:@{kAccountIdentifierAccessKey: accountIdentifier,
                                      kAccountPasswordAccessKey  : accountPassword}];
    }
    return accountInfoArray;
}

/**
 清空keychain保存的所有账户信息
 */
+ (BOOL)clearAllAccountInfosInKeychain
{
    // 直接最大条件删除就可以了,删除所有的kSecClassGenericPassword项的项
    NSDictionary *queryDict = @{(id)kSecClass: (id)kSecClassGenericPassword};
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)queryDict);
    return status == errSecSuccess;
}

@end
