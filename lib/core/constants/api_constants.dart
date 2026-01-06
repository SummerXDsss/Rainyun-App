class ApiConstants {
  static const String baseUrl = 'https://api.v2.rainyun.com';
  static const String apiVersion = '';
  
  // ========== Product API ==========
  static const String productSummary = '/product/';
  static const String productIds = '/product/ids';
  static const String productRenew = '/product/renew';
  static const String productAppList = '/product/app_list';
  static const String productTaskLog = '/product/task_log';
  static const String productZones = '/product/zones';
  
  // Product - Panel
  static const String productPanelConfig = '/product/panel/config';
  static const String productPanelEdit = '/product/panel/edit';
  static const String productPanelUser = '/product/panel/user';
  static const String productPanelUsers = '/product/panel/users';
  static const String productPanelUserProducts = '/product/panel/user/products';
  static const String productPanelUserCreate = '/product/panel/user/create';
  static const String productPanelUserEdit = '/product/panel/user/edit';
  static const String productPanelUserDelete = '/product/panel/user/delete';
  
  // Product - Buy Group
  static const String productBuyGroupCreate = '/product/buy_group/create';
  static const String productBuyGroupList = '/product/buy_group/list';
  static const String productBuyGroupConfirm = '/product/buy_group/confirm';
  static const String productBuyGroupJoin = '/product/buy_group/join';
  static const String productBuyGroupMy = '/product/buy_group/my';
  
  // ========== Domain API ==========
  static const String domainList = '/product/domain/';
  static const String domainDetail = '/product/domain/detail';
  static const String domainCert = '/product/domain/cert';
  static const String domainDnsList = '/product/domain/dns';
  static const String domainDnsAdd = '/product/domain/dns/add';
  static const String domainDnsEdit = '/product/domain/dns/edit';
  static const String domainDnsDelete = '/product/domain/dns/delete';
  static const String domainDnssec = '/product/domain/dnssec';
  static const String domainDnssecAdd = '/product/domain/dnssec/add';
  static const String domainDnssecDelete = '/product/domain/dnssec/delete';
  static const String domainDnssecSync = '/product/domain/dnssec/sync';
  static const String domainLockDisable = '/product/domain/lock/disable';
  static const String domainLockEnable = '/product/domain/lock/enable';
  static const String domainNsEdit = '/product/domain/ns/edit';
  static const String domainNsReset = '/product/domain/ns/reset';
  static const String domainRenew = '/product/domain/renew';
  static const String domainRenewPrice = '/product/domain/renew_price';
  static const String domainTransfer = '/product/domain/transfer';
  static const String domainVerified = '/product/domain/verified';
  static const String domainVerifyAdd = '/product/domain/verify/add';
  static const String domainVerifyDelete = '/product/domain/verify/delete';
  static const String domainVerifyCheck = '/product/domain/verify/check';
  static const String domainCheckAvailable = '/product/domain/check';
  static const String domainFreeSuffixes = '/product/domain/free/suffixes';
  static const String domainFreeCreate = '/product/domain/free/create';
  static const String domainFreeDelete = '/product/domain/free/delete';
  static const String domainFreeCdn = '/product/domain/free/cdn';
  static const String domainAvailableSuffixes = '/product/domain/available_suffixes';
  static const String domainRegister = '/product/domain/register';
  static const String domainTemplates = '/product/domain/templates';
  static const String domainTemplateDelete = '/product/domain/template/delete';
  static const String domainTemplateDetail = '/product/domain/template/detail';
  static const String domainWhitelist = '/product/domain/whitelist';
  static const String domainWhitelistAdd = '/product/domain/whitelist/add';
  static const String domainPassword = '/product/domain/password';
  static const String domainPasswordUpdate = '/product/domain/password/update';
  static const String domainTemplateEdit = '/product/domain/template/edit';
  static const String domainWhois = '/product/domain/whois';
  
  // ========== User API ==========
  static const String userInfo = '/user/';
  static const String userEdit = '/user/edit';
  static const String userCsrf = '/user/csrf';
  static const String userLogin = '/user/login';
  static const String userLogout = '/user/logout';
  static const String userLogs = '/user/logs';
  static const String user2faRequest = '/user/2fa/request';
  static const String user2faVerify = '/user/2fa/verify';
  static const String userMessages = '/user/messages';
  static const String userMessageRead = '/user/message/read';
  static const String userPasswordReset = '/user/password/reset';
  static const String userPasswordVerify = '/user/password/verify';
  static const String userRegister = '/user/register';
  
  // User - Certify
  static const String userCertify = '/user/certify/';
  static const String userCertifyStart = '/user/certify/start';
  static const String userCertifyToCompany = '/user/certify/to_company';
  static const String userCertifyUpload = '/user/certify/upload';
  static const String userCertifyVerify = '/user/certify/verify';
  
  // User - VIP
  static const String userVipConfig = '/user/vip/config';
  static const String userVipAgentCert = '/user/vip/agent_cert';
  static const String userVipSetPrice = '/user/vip/set_price';
  static const String userVipCouponGive = '/user/vip/coupon/give';
  static const String userVipCouponPublish = '/user/vip/coupon/publish';
  static const String userVipPublished = '/user/vip/published';
  static const String userVipCodeSet = '/user/vip/code/set';
  static const String userVipConfigs = '/user/vip/configs';
  static const String userVipMessages = '/user/vip/messages';
  static const String userVipMessagePublish = '/user/vip/message/publish';
  static const String userVipSalesReport = '/user/vip/sales_report';
  static const String userVipSubLogs = '/user/vip/sub_logs';
  static const String userVipSubConsume = '/user/vip/sub_consume';
  static const String userVipRanking = '/user/vip/ranking';
  
  // User - Coupons
  static const String userCoupons = '/user/coupons/';
  static const String userCouponQuery = '/user/coupon/query';
  static const String userCouponActivate = '/user/coupon/activate';
  
  // User - Reward
  static const String userRewardExchange = '/user/reward/exchange';
  static const String userRewardProducts = '/user/reward/products';
  static const String userRewardProductExchange = '/user/reward/product/exchange';
  static const String userRewardList = '/user/reward/list';
  static const String userRewardComplete = '/user/reward/complete';
  static const String userRewardWithdrawList = '/user/reward/withdraw/list';
  static const String userRewardWithdraw = '/user/reward/withdraw';
  
  // ========== RCS - 云服务器 API ==========
  static const String rcsList = '/product/rcs/';
  static const String rcsCreate = '/product/rcs/create';
  static const String rcsDetail = '/product/rcs/detail';
  static const String rcsBackupCreate = '/product/rcs/backup/create';
  static const String rcsBackupDelete = '/product/rcs/backup/delete';
  static const String rcsBackupCancel = '/product/rcs/backup/cancel';
  static const String rcsBackupRestore = '/product/rcs/backup/restore';
  static const String rcsBackupOptions = '/product/rcs/backup/options';
  static const String rcsBridgeNetwork = '/product/rcs/bridge/network';
  static const String rcsReinstall = '/product/rcs/reinstall';
  static const String rcsDisk = '/product/rcs/disk';
  static const String rcsIpCreate = '/product/rcs/ip/create';
  static const String rcsIpChange = '/product/rcs/ip/change';
  static const String rcsIpDesc = '/product/rcs/ip/desc';
  static const String rcsIpRelease = '/product/rcs/ip/release';
  static const String rcsAppInstall = '/product/rcs/app/install';
  static const String rcsFirewallList = '/product/rcs/firewall/list';
  static const String rcsFirewallSet = '/product/rcs/firewall/set';
  static const String rcsFirewallDelete = '/product/rcs/firewall/delete';
  static const String rcsFirewallMove = '/product/rcs/firewall/move';
  static const String rcsRelease = '/product/rcs/release';
  static const String rcsMonitor = '/product/rcs/monitor';
  static const String rcsNatAdd = '/product/rcs/nat/add';
  static const String rcsNatDelete = '/product/rcs/nat/delete';
  static const String rcsRestart = '/product/rcs/restart';
  static const String rcsRenewPrice = '/product/rcs/renew_price';
  static const String rcsRenew = '/product/rcs/renew';
  static const String rcsAutoRenew = '/product/rcs/auto_renew';
  static const String rcsResetPassword = '/product/rcs/reset_password';
  static const String rcsStart = '/product/rcs/start';
  static const String rcsStop = '/product/rcs/stop';
  static const String rcsSetTag = '/product/rcs/set_tag';
  static const String rcsToBridge = '/product/rcs/to_bridge';
  static const String rcsTrafficCharge = '/product/rcs/traffic/charge';
  static const String rcsTrafficLimit = '/product/rcs/traffic/limit';
  static const String rcsUpgrade = '/product/rcs/upgrade';
  static const String rcsUsage = '/product/rcs/usage';
  static const String rcsVnc = '/product/rcs/vnc';
  static const String rcsSubnetCreate = '/product/rcs/subnet/create';
  static const String rcsSubnetRename = '/product/rcs/subnet/rename';
  static const String rcsDiscount = '/product/rcs/discount';
  static const String rcsOsList = '/product/rcs/os_list';
  static const String rcsPackages = '/product/rcs/packages';
  static const String rcsPrice = '/product/rcs/price';
  static const String rcsUsageList = '/product/rcs/usage_list';
  
  // ========== RGS - 游戏云 API ==========
  static const String rgsList = '/product/rgs/';
  static const String rgsMpCreate = '/product/rgs/mp/create';
  static const String rgsMpRenew = '/product/rgs/mp/renew';
  static const String rgsCreate = '/product/rgs/create';
  static const String rgsDetail = '/product/rgs/detail';
  static const String rgsBackupCreate = '/product/rgs/backup/create';
  static const String rgsBackupDelete = '/product/rgs/backup/delete';
  static const String rgsBackupCancel = '/product/rgs/backup/cancel';
  static const String rgsBackupRestore = '/product/rgs/backup/restore';
  static const String rgsBackupOptions = '/product/rgs/backup/options';
  static const String rgsBridgeNetwork = '/product/rgs/bridge/network';
  static const String rgsReinstall = '/product/rgs/reinstall';
  static const String rgsCpuCharge = '/product/rgs/cpu/charge';
  static const String rgsLimitMode = '/product/rgs/limit_mode';
  static const String rgsDailyMode = '/product/rgs/daily_mode';
  static const String rgsIpCreate = '/product/rgs/ip/create';
  static const String rgsIpChange = '/product/rgs/ip/change';
  static const String rgsIpDesc = '/product/rgs/ip/desc';
  static const String rgsIpRelease = '/product/rgs/ip/release';
  static const String rgsAppInstall = '/product/rgs/app/install';
  static const String rgsRelease = '/product/rgs/release';
  static const String rgsMonitor = '/product/rgs/monitor';
  static const String rgsNatAdd = '/product/rgs/nat/add';
  static const String rgsNatDelete = '/product/rgs/nat/delete';
  static const String rgsRestart = '/product/rgs/restart';
  static const String rgsRenew = '/product/rgs/renew';
  static const String rgsAutoRenew = '/product/rgs/auto_renew';
  static const String rgsResetPassword = '/product/rgs/reset_password';
  static const String rgsUpgrade = '/product/rgs/upgrade';
  static const String rgsStart = '/product/rgs/start';
  static const String rgsStop = '/product/rgs/stop';
  static const String rgsSetTag = '/product/rgs/set_tag';
  static const String rgsToBridge = '/product/rgs/to_bridge';
  static const String rgsUsage = '/product/rgs/usage';
  static const String rgsVnc = '/product/rgs/vnc';
  static const String rgsSubnetCreate = '/product/rgs/subnet/create';
  static const String rgsSubnetRename = '/product/rgs/subnet/rename';
  static const String rgsEggSwitch = '/product/rgs/egg/switch';
  static const String rgsDiscount = '/product/rgs/discount';
  static const String rgsEggList = '/product/rgs/egg/list';
  static const String rgsEggTypes = '/product/rgs/egg/types';
  static const String rgsPalConfig = '/product/rgs/pal/config';
  static const String rgsPalClose = '/product/rgs/pal/close';
  static const String rgsPanelUsers = '/product/rgs/panel/users';
  static const String rgsPanelUserCreate = '/product/rgs/panel/user/create';
  static const String rgsPanelUserEdit = '/product/rgs/panel/user/edit';
  static const String rgsPanelUserDelete = '/product/rgs/panel/user/delete';
  static const String rgsSftpInit = '/product/rgs/sftp/init';
  static const String rgsServerStart = '/product/rgs/server/start';
  static const String rgsServerInfo = '/product/rgs/server/info';
  static const String rgsOsList = '/product/rgs/os_list';
  static const String rgsPackages = '/product/rgs/packages';
  static const String rgsPrice = '/product/rgs/price';
  static const String rgsPterodactylUsers = '/product/rgs/pterodactyl/users';
  static const String rgsPterodactylUserCreate = '/product/rgs/pterodactyl/user/create';
  static const String rgsEggReinstall = '/product/rgs/egg/reinstall';
  static const String rgsPterodactylUserEdit = '/product/rgs/pterodactyl/user/edit';
  static const String rgsPterodactylUserDelete = '/product/rgs/pterodactyl/user/delete';
  static const String rgsPanelUserSwitch = '/product/rgs/panel/user/switch';
  static const String rgsUsageList = '/product/rgs/usage_list';
  
  // ========== RBM - 裸金属服务器 API ==========
  static const String rbmList = '/product/rbm/';
  static const String rbmCreate = '/product/rbm/create';
  static const String rbmBiosFlash = '/product/rbm/bios/flash';
  static const String rbmReinstall = '/product/rbm/reinstall';
  static const String rbmInventory = '/product/rbm/inventory';
  static const String rbmIpCreate = '/product/rbm/ip/create';
  static const String rbmIpChange = '/product/rbm/ip/change';
  static const String rbmIpDesc = '/product/rbm/ip/desc';
  static const String rbmIpRelease = '/product/rbm/ip/release';
  static const String rbmRelease = '/product/rbm/release';
  static const String rbmKvmStart = '/product/rbm/kvm/start';
  static const String rbmKvmRestart = '/product/rbm/kvm/restart';
  static const String rbmMonitor = '/product/rbm/monitor';
  static const String rbmStop = '/product/rbm/stop';
  static const String rbmStart = '/product/rbm/start';
  static const String rbmIpmiReset = '/product/rbm/ipmi/reset';
  static const String rbmTrafficCharge = '/product/rbm/traffic/charge';
  static const String rbmTrafficLimit = '/product/rbm/traffic/limit';
  static const String rbmTrafficSwitch = '/product/rbm/traffic/switch';
  static const String rbmPrice = '/product/rbm/price';
  static const String rbmUsageList = '/product/rbm/usage_list';
  
  // ========== RVH - 虚拟主机 API ==========
  static const String rvhList = '/product/rvh/';
  static const String rvhCreate = '/product/rvh/create';
  static const String rvhDetail = '/product/rvh/detail';
  static const String rvhBackupCreate = '/product/rvh/backup/create';
  static const String rvhBackupDelete = '/product/rvh/backup/delete';
  static const String rvhBackupRestore = '/product/rvh/backup/restore';
  static const String rvhBackupOptions = '/product/rvh/backup/options';
  static const String rvhIpAttach = '/product/rvh/ip/attach';
  static const String rvhBtFix = '/product/rvh/bt/fix';
  static const String rvhBtRestart = '/product/rvh/bt/restart';
  static const String rvhDomainBind = '/product/rvh/domain/bind';
  static const String rvhDomainUnbind = '/product/rvh/domain/unbind';
  static const String rvhResetPassword = '/product/rvh/reset_password';
  static const String rvhFirewallOptions = '/product/rvh/firewall/options';
  static const String rvhFirewallRules = '/product/rvh/firewall/rules';
  static const String rvhRelease = '/product/rvh/release';
  static const String rvhMaintenance = '/product/rvh/maintenance';
  static const String rvhReinstall = '/product/rvh/reinstall';
  static const String rvhDiscount = '/product/rvh/discount';
  static const String rvhRenew = '/product/rvh/renew';
  static const String rvhAutoRenew = '/product/rvh/auto_renew';
  static const String rvhUpgrade = '/product/rvh/upgrade';
  static const String rvhPackages = '/product/rvh/packages';
  static const String rvhPrice = '/product/rvh/price';
  static const String rvhSetTag = '/product/rvh/set_tag';
  
  // ========== ROS - 对象存储 API ==========
  static const String rosBuckets = '/product/ros/buckets';
  static const String rosBucketCreate = '/product/ros/bucket/create';
  static const String rosBucketDetail = '/product/ros/bucket/detail';
  static const String rosBucketDelete = '/product/ros/bucket/delete';
  static const String rosBucketMonitor = '/product/ros/bucket/monitor';
  static const String rosBucketProxy = '/product/ros/bucket/proxy';
  static const String rosBucketRegenKey = '/product/ros/bucket/regen_key';
  static const String rosBucketAnonymous = '/product/ros/bucket/anonymous';
  static const String rosDiscount = '/product/ros/discount';
  static const String rosList = '/product/ros/';
  static const String rosCreate = '/product/ros/create';
  static const String rosDetail = '/product/ros/detail';
  static const String rosRegenKey = '/product/ros/regen_key';
  static const String rosRenew = '/product/ros/renew';
  static const String rosAutoRenew = '/product/ros/auto_renew';
  static const String rosResize = '/product/ros/resize';
  static const String rosSetTag = '/product/ros/set_tag';
  static const String rosElastic = '/product/ros/elastic';
  static const String rosAnonymous = '/product/ros/anonymous';
  static const String rosPackages = '/product/ros/packages';
  static const String rosPrice = '/product/ros/price';
  
  // ========== RCDN - CDN 加速 API ==========
  static const String rcdnMonitor = '/product/rcdn/monitor';
  static const String rcdnDiscount = '/product/rcdn/discount';
  static const String rcdnDomains = '/product/rcdn/domains';
  static const String rcdnDomainCreate = '/product/rcdn/domain/create';
  static const String rcdnDomainDetail = '/product/rcdn/domain/detail';
  static const String rcdnDomainDelete = '/product/rcdn/domain/delete';
  static const String rcdnDefense = '/product/rcdn/defense';
  static const String rcdnDomainUsage = '/product/rcdn/domain/usage';
  static const String rcdnList = '/product/rcdn/';
  static const String rcdnCreate = '/product/rcdn/create';
  static const String rcdnDetail = '/product/rcdn/detail';
  static const String rcdnPurge = '/product/rcdn/purge';
  static const String rcdnRenew = '/product/rcdn/renew';
  static const String rcdnAutoRenew = '/product/rcdn/auto_renew';
  static const String rcdnResize = '/product/rcdn/resize';
  static const String rcdnSettings = '/product/rcdn/settings';
  static const String rcdnSslBind = '/product/rcdn/ssl/bind';
  static const String rcdnSetTag = '/product/rcdn/set_tag';
  static const String rcdnElastic = '/product/rcdn/elastic';
  static const String rcdnUsage = '/product/rcdn/usage';
  static const String rcdnPackages = '/product/rcdn/packages';
  static const String rcdnPrice = '/product/rcdn/price';
  
  // ========== RCA - 云应用 API ==========
  // RCA - App
  static const String rcaAppList = '/product/rca/app/';
  static const String rcaAppInstall = '/product/rca/app/install';
  static const String rcaAppDetail = '/product/rca/app/detail';
  static const String rcaAppUninstall = '/product/rca/app/uninstall';
  static const String rcaAppSettings = '/product/rca/app/settings';
  static const String rcaAppConfig = '/product/rca/app/config';
  static const String rcaAppMetrics = '/product/rca/app/metrics';
  static const String rcaAppMysql = '/product/rca/app/mysql';
  static const String rcaAppPhp = '/product/rca/app/php';
  static const String rcaAppRedis = '/product/rca/app/redis';
  static const String rcaAppServices = '/product/rca/app/services';
  static const String rcaAppRestart = '/product/rca/app/restart';
  static const String rcaAppStart = '/product/rca/app/start';
  static const String rcaAppStop = '/product/rca/app/stop';
  static const String rcaAppUpgrade = '/product/rca/app/upgrade';
  
  // RCA - Service
  static const String rcaServiceCreate = '/product/rca/service/create';
  static const String rcaServiceDelete = '/product/rca/service/delete';
  static const String rcaServiceUpdate = '/product/rca/service/update';
  
  // RCA - AppStore
  static const String rcaAppstoreList = '/product/rca/appstore/';
  static const String rcaAppstoreCreate = '/product/rca/appstore/create';
  static const String rcaAppstoreDetail = '/product/rca/appstore/detail';
  static const String rcaAppstoreDelete = '/product/rca/appstore/delete';
  static const String rcaAppstoreUpdate = '/product/rca/appstore/update';
  static const String rcaAppstoreVersion = '/product/rca/appstore/version';
  static const String rcaAppstoreVersionCreate = '/product/rca/appstore/version/create';
  static const String rcaAppstoreVersionDelete = '/product/rca/appstore/version/delete';
  static const String rcaAppstoreVersionUpdate = '/product/rca/appstore/version/update';
  static const String rcaAppstoreVersionClone = '/product/rca/appstore/version/clone';
  static const String rcaAppstoreVersionPublic = '/product/rca/appstore/version/public';
  static const String rcaAppstoreSubmit = '/product/rca/appstore/submit';
  static const String rcaAppstoreSubmitCancel = '/product/rca/appstore/submit/cancel';
  
  // RCA - Project
  static const String rcaProjectList = '/product/rca/project/';
  static const String rcaProjectCreate = '/product/rca/project/create';
  static const String rcaProjectDestroy = '/product/rca/project/destroy';
  static const String rcaProjectMetrics = '/product/rca/project/metrics';
  static const String rcaProjectDetail = '/product/rca/project/detail';
  static const String rcaProjectBackup = '/product/rca/project/backup';
  static const String rcaProjectDiskResize = '/product/rca/project/disk/resize';
  static const String rcaProjectIpAdd = '/product/rca/project/ip/add';
  static const String rcaProjectIpRemove = '/product/rca/project/ip/remove';
  static const String rcaProjectSftp = '/product/rca/project/sftp';
  static const String rcaProjectIps = '/product/rca/project/ips';
  
  // RCA - Website
  static const String rcaWebsiteCreate = '/product/rca/website/create';
  static const String rcaWebsiteDelete = '/product/rca/website/delete';
  static const String rcaWebsiteNginx = '/product/rca/website/nginx';
  static const String rcaWebsiteList = '/product/rca/website/';
  static const String rcaWebsiteDetail = '/product/rca/website/detail';
  static const String rcaWebsitePhp = '/product/rca/website/php';
  static const String rcaWebsiteAccess = '/product/rca/website/access';
  static const String rcaWebsiteRewrite = '/product/rca/website/rewrite';
  
  // RCA - Root
  static const String rcaEnabled = '/product/rca/enabled';
  static const String rcaBalance = '/product/rca/balance';
  static const String rcaEnable = '/product/rca/enable';
  static const String rcaBuy = '/product/rca/buy';
  static const String rcaHistory = '/product/rca/history';
  static const String rcaPackages = '/product/rca/packages';
  static const String rcaUsage = '/product/rca/usage';
  static const String rcaRegions = '/product/rca/regions';
  
  // ========== SSL API ==========
  static const String sslList = '/product/ssl/';
  static const String sslUpload = '/product/ssl/upload';
  static const String sslView = '/product/ssl/view';
  static const String sslReplace = '/product/ssl/replace';
  static const String sslDelete = '/product/ssl/delete';
  static const String sslRequestCreate = '/product/ssl/request/create';
  static const String sslRequestVerify = '/product/ssl/request/verify';
  static const String sslRequestList = '/product/ssl/request/list';
  static const String sslOrderList = '/product/ssl/order/list';
  static const String sslOrderCreate = '/product/ssl/order/create';
  static const String sslOrderInfo = '/product/ssl/order/info';
  static const String sslOrderAdd = '/product/ssl/order/add';
  static const String sslOrderGet = '/product/ssl/order/get';
  static const String sslOrderVerify = '/product/ssl/order/verify';
  static const String sslProducts = '/product/ssl/products';
  static const String sslOrderUpdateDesc = '/product/ssl/order/update_desc';
  
  // ========== WorkOrder API ==========
  static const String workorderList = '/product/workorder/';
  static const String workorderCreate = '/product/workorder/create';
  static const String workorderDetail = '/product/workorder/detail';
  static const String workorderAuth = '/product/workorder/auth';
  static const String workorderReply = '/product/workorder/reply';
  static const String workorderReplyEdit = '/product/workorder/reply/edit';
  static const String workorderRate = '/product/workorder/rate';
  static const String workorderRateEdit = '/product/workorder/rate/edit';
  static const String workorderRateGet = '/product/workorder/rate/get';
  static const String workorderStatus = '/product/workorder/status';
  static const String workorderStatusSet = '/product/workorder/status/set';
  static const String workorderPrompts = '/product/workorder/prompts';
  static const String workorderSummary = '/product/workorder/summary';
  static const String workorderUpload = '/product/workorder/upload';
  static const String workorderAuthCreate = '/product/workorder/auth/create';
  static const String workorderAuthDelete = '/product/workorder/auth/delete';
  static const String workorderTransfer = '/product/workorder/transfer';
  
  // ========== Expense API ==========
  static const String expenseTransfer = '/product/expense/transfer';
  static const String expenseRefund = '/product/expense/refund';
  
  // Expense - Order
  static const String expenseOrderList = '/product/expense/order/';
  static const String expenseOrderPay = '/product/expense/order/pay';
  
  // Expense - Invoice
  static const String expenseInvoiceList = '/product/expense/invoice/';
  static const String expenseInvoiceApply = '/product/expense/invoice/apply';
  static const String expenseInvoiceReplace = '/product/expense/invoice/replace';
  static const String expenseInvoiceDownload = '/product/expense/invoice/download';
  static const String expenseInvoiceTitles = '/product/expense/invoice/titles';
  static const String expenseInvoiceTitleCreate = '/product/expense/invoice/title/create';
  static const String expenseInvoiceTitleDelete = '/product/expense/invoice/title/delete';
  
  // ========== Public API ==========
  static const String publicPage = '/public/page';
  static const String publicForum = '/public/forum';
  static const String publicAnnouncement = '/public/announcement';
  static const String publicShortQuery = '/public/short/query';
  static const String publicShortCreate = '/public/short/create';
  static const String publicNodeStatus = '/public/node_status';
  
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
