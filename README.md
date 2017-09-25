# KeyChainExample
iOS 应用开发的时候，关于keychain使用的一个工具类


首先需要说明，我的KeyChain工具类中保存的账户名密码信息分了两种：
- 普通的账户名密码（用于我们通过用户名获取密码）
- 用于自动登录的账户名密码（用于进入应用后获取应用名密码直接自动登录，不通过登录页面输入信息）

两者基础的query字典是不一样的，而且用于自动登录的账户名密码在keychain中只有一个。

### 普通的账户名密码中基础的query字典是包含的键值对有：
1. kSecClass：kSecClassGenericPassword
这个表示我们保存的是普通的用户名密码。其他的什么证书什么的我们不涉及。
2. kSecAttrAccount：对应的账户名
这个就是保存对应账户的用户名了，而且这个键值对是保证在keychain所有item里面，每个item都与其他item不一样的标记（默认账户名不能相同）
3. kSecAttrService：@"com.companyName.appName"
这个是一个其他标记，对于普通类型的来说，所有的item的这个键值对都是一样的，你们可以随意更改后面的这个字符串值。

### 用于自动登录的用户名密码的基础query字典包含的键值对有：
1.  kSecClass：kSecClassGenericPassword
这个表示我们保存的是普通的用户名密码而不是保存的什么证书信息，跟上面的普通账户类型相同。
2. kSecAttrService：@"autoLoginAccountIdentifierTag"
这个是我为自动登录账户设定的一个标记，跟上面的普通类型不一样。

**通过这样两种基础query字典，我们可以保证keychain中每一项的唯一性。**

另外，工具类就是项目中的ZZZKeyChainHelper.h/ZZZKeyChainHelper.m文件。

可以直接拿去使用，代码很简单，但是可能会有我没发现的Bug，发现了可以帮我修改哦，看得上就赏赐一颗星吧，嘻嘻。

另外具体的使用可以去我的博客中看吧，写得挺繁杂的就是了，哈哈，附博客地址：[http://blog.csdn.net/G_eorge/article/details/78063486](http://blog.csdn.net/G_eorge/article/details/78063486)