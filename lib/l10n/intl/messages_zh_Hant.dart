// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_Hant locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh_Hant';

  static String m0(count) => "已選 ${count}";

  static String m1(name) => "已將 ${name} 添加到本地代理";

  static String m2(name) => "本地代理中已有 ${name}";

  static String m3(count, skipped) => "將添加 ${count} 項，跳過 ${skipped} 項已存在";

  static String m4(detail) => "清除數據失敗：${detail}";

  static String m5(code) =>
      "Windows 拒絕運行 FlClashCore.exe（錯誤 ${code}）。智能應用控制、AppLocker 等應用控制策略會攔截未簽名程序，請在該策略中放行 FlClash 或關閉策略後重試。";

  static String m6(name) =>
      "應用連續兩次未能完成啓動。爲打斷崩潰循環，已取消選中配置 ${name}，並跳過本次自動配置，你可以隨時重新選中它。";

  static String m7(url) => "是否要通過 ${url} 創建配置？";

  static String m8(count, label) =>
      "${Intl.plural(count, other: '自定義配置不支持子規則，已丟棄 ${label} 條 SUB-RULE 規則')}";

  static String m9(message) => "內核無法解析該代理：${message}";

  static String m10(proxy, target) =>
      "${proxy} 經 ${target} 撥號，而 ${target} 又會回到 ${proxy}，形成環路";

  static String m11(name) => "名稱 ${name} 已被其他代理或策略組使用";

  static String m12(path) => "策略組之間存在循環引用：${path}";

  static String m13(name) => "空組兜底只能是代理，${name} 不存在或是策略組";

  static String m14(name, message) => "${name}不是有效的正則：${message}";

  static String m15(name) => "撥號代理 ${name} 不存在";

  static String m16(names) => "以下代理集不存在：${names}";

  static String m17(names) => "以下代理或策略不存在：${names}";

  static String m18(name) => "${name} 是內置策略名，不能在此使用";

  static String m19(count) => "${count} 項存在問題，應用配置可能失敗";

  static String m20(count) => "${count} 天前";

  static String m21(count) => "${count} 天前";

  static String m22(label) => "確定刪除選中的${label}嗎？";

  static String m23(label) => "確定刪除當前${label}嗎？";

  static String m24(label) => "${label}詳情";

  static String m25(name) => "經 ${name} 撥號會繞回使用它的代理，連接已中止";

  static String m26(label) => "${label}不能爲空";

  static String m27(label) => "${label}當前已存在";

  static String m28(count) => "${count} 項失敗";

  static String m29(label, message) => "${label}：${message}";

  static String m30(name) => "${name} 已是最新版本";

  static String m31(name) => "${name} 已更新";

  static String m32(count) => "${count} 個";

  static String m33(count) => "${count} 超時";

  static String m34(action) => "已被“${action}”使用，保存後將移到這裏";

  static String m35(modifiers) => "至少包含 ${modifiers} 中的一個";

  static String m36(count) => "${count} 小時前";

  static String m37(count) => "${count} 小時前";

  static String m38(target) => "${target} 是一個無效的策略";

  static String m39(proxyName) => "${proxyName} 是一個無效的代理";

  static String m40(providerName) => "${providerName} 是一個無效的代理集";

  static String m41(ruleSet) => "${ruleSet} 不是有效的規則集";

  static String m42(subRule) => "${subRule} 是一個無效的SUB_RULE";

  static String m43(count) => "${count} 項";

  static String m44(line, message) => "第 ${line} 行：${message}";

  static String m45(appName) =>
      "1. 打開 系統設置 > 隱私與安全性\n2. 選擇 定位服務\n3. 在右側列表中找到並勾選 ${appName}\n\n完成設置後，返回應用即可正常使用。感謝您的配合。";

  static String m46(label, max) => "${label}最多${max}個字符";

  static String m47(size) => "已釋放 ${size}";

  static String m48(count) => "${count} 分鐘前";

  static String m49(count) => "${count} 分鐘前";

  static String m50(count) => "${count} 個月前";

  static String m51(count) => "${count} 個月前";

  static String m52(code) => "服務器拒絕訪問（HTTP ${code}），鏈接可能已過期或憑據有誤";

  static String m53(code) => "服務器拒絕了請求（HTTP ${code}）";

  static String m54(code) => "該地址下沒有內容（HTTP ${code}），請確認鏈接是否正確";

  static String m55(detail) => "網絡請求失敗：${detail}";

  static String m56(code) => "服務器出現問題（HTTP ${code}），請稍後再試";

  static String m57(label) => "暫無${label}";

  static String m58(label, min, max) => "${label}必須在 ${min} 到 ${max} 之間";

  static String m59(label) => "${label}必須爲數字";

  static String m60(label) => "${label} 必須在 1024 到 49151 之間";

  static String m61(port) => "端口 ${port}";

  static String m62(days) => "剩餘 ${days} 天";

  static String m63(date, days) => "${date} 到期，剩餘 ${days} 天";

  static String m64(time) => "更新於 ${time}";

  static String m65(label, profiles) =>
      "${label} 仍被 ${profiles} 使用，刪除後這些配置會異常。確定刪除嗎？";

  static String m66(count, label) =>
      "${Intl.plural(count, other: '${label} 個代理')}";

  static String m67(name, count) => "${name} 等 ${count} 個代理";

  static String m68(removed) =>
      "以下代理將被刪除：${removed}。改了名字的行按新代理處理，自定義配置中對被刪除代理的引用會標爲缺失。確定應用嗎？";

  static String m69(removed, added) =>
      "以下代理將被刪除：${removed}。以下代理將新增：${added}。改了名字的行按新代理處理，自定義配置中對被刪除代理的引用會標爲缺失。確定應用嗎？";

  static String m70(label) =>
      "${label} 仍被當前配置的規則、策略組、撥號代理、DNS 或 NTP 引用，刪除後這些引用會失效。確定刪除嗎？";

  static String m71(count, label) =>
      "${Intl.plural(count, other: '${label} 個策略組')}";

  static String m72(count, label) =>
      "${Intl.plural(count, other: '${label} 條規則')}";

  static String m73(appName) => "${appName}（安全模式）";

  static String m74(count) => "${count} 秒";

  static String m75(count) => "${count} 項生效";

  static String m76(count) => "${count} 項異常";

  static String m77(count) => "${count} 項設置";

  static String m78(link) => "無法從 ${link} 中讀取代理";

  static String m79(label) => "${label}只能是一項";

  static String m80(value) => "峯值 ${value}";

  static String m81(value) => "累計 ${value}";

  static String m82(transport) => "${transport} 請求頭";

  static String m83(label) => "${label}必須爲URL";

  static String m84(count) => "${count} 年前";

  static String m85(count) => "${count} 年前";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("關於"),
    "accessControl": MessageLookupByLibrary.simpleMessage("訪問控制"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "只允許選中應用進入VPN",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "訪問控制決定哪些應用使用代理。",
    ),
    "accessControlDisabledDesc": MessageLookupByLibrary.simpleMessage(
      "應用訪問控制已關閉",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "選中應用將會被排除在VPN之外",
    ),
    "accessControlSelectedCount": m0,
    "account": MessageLookupByLibrary.simpleMessage("賬號"),
    "action": MessageLookupByLibrary.simpleMessage("操作"),
    "actionDelayTest": MessageLookupByLibrary.simpleMessage("測試全部延遲"),
    "actionDirectMode": MessageLookupByLibrary.simpleMessage("直連模式"),
    "actionGlobalMode": MessageLookupByLibrary.simpleMessage("全局模式"),
    "actionMode": MessageLookupByLibrary.simpleMessage("切換模式"),
    "actionProxy": MessageLookupByLibrary.simpleMessage("系統代理"),
    "actionRuleMode": MessageLookupByLibrary.simpleMessage("規則模式"),
    "actionStart": MessageLookupByLibrary.simpleMessage("啓動/停止"),
    "actionTun": MessageLookupByLibrary.simpleMessage("虛擬網卡"),
    "actionUpdateProfiles": MessageLookupByLibrary.simpleMessage("更新全部配置"),
    "actionView": MessageLookupByLibrary.simpleMessage("顯示/隱藏"),
    "add": MessageLookupByLibrary.simpleMessage("添加"),
    "addCustomProxy": MessageLookupByLibrary.simpleMessage("添加代理"),
    "addFilters": MessageLookupByLibrary.simpleMessage("添加篩選"),
    "addNodes": MessageLookupByLibrary.simpleMessage("添加節點"),
    "addOverrideEntry": MessageLookupByLibrary.simpleMessage("添加覆寫項"),
    "addProfile": MessageLookupByLibrary.simpleMessage("添加配置"),
    "addProxyGroup": MessageLookupByLibrary.simpleMessage("添加策略組"),
    "addRule": MessageLookupByLibrary.simpleMessage("添加規則"),
    "addSettingEntry": MessageLookupByLibrary.simpleMessage("添加設置項"),
    "addSsid": MessageLookupByLibrary.simpleMessage("添加SSID"),
    "addToLocalProxies": MessageLookupByLibrary.simpleMessage("添加到本地代理"),
    "addedRules": MessageLookupByLibrary.simpleMessage("附加規則"),
    "addedToLocalProxies": m1,
    "additionalParameters": MessageLookupByLibrary.simpleMessage("附加參數"),
    "additionalPrefix": MessageLookupByLibrary.simpleMessage("名稱前綴"),
    "additionalSuffix": MessageLookupByLibrary.simpleMessage("名稱後綴"),
    "address": MessageLookupByLibrary.simpleMessage("地址"),
    "addressHelp": MessageLookupByLibrary.simpleMessage("WebDAV服務器地址"),
    "addressTip": MessageLookupByLibrary.simpleMessage("請輸入有效的WebDAV地址"),
    "advancedConfig": MessageLookupByLibrary.simpleMessage("進階配置"),
    "advancedConfigDesc": MessageLookupByLibrary.simpleMessage(
      "進階配置包含網絡、DNS、附加規則與腳本。",
    ),
    "ageEncryptedProfile": MessageLookupByLibrary.simpleMessage("配置已加密"),
    "ageSecretKey": MessageLookupByLibrary.simpleMessage("age 私鑰"),
    "ageSecretKeyRequiredTip": MessageLookupByLibrary.simpleMessage(
      "該配置已用 age 加密，需要 age 私鑰才能解密",
    ),
    "agree": MessageLookupByLibrary.simpleMessage("同意"),
    "allReferencedProxies": MessageLookupByLibrary.simpleMessage("全部被引用的代理"),
    "allReferencedProxyProviders": MessageLookupByLibrary.simpleMessage(
      "全部被引用的代理集",
    ),
    "customFont": MessageLookupByLibrary.simpleMessage("自定義字體"),
    "nodeCount": MessageLookupByLibrary.simpleMessage("節點數"),
    "ruleCount": MessageLookupByLibrary.simpleMessage("規則項"),
    "providerCount": MessageLookupByLibrary.simpleMessage("提供者"),
    "emojiStyle": MessageLookupByLibrary.simpleMessage("Emoji字體"),
    "allowBypass": MessageLookupByLibrary.simpleMessage("允許應用繞過VPN"),
    "allowLan": MessageLookupByLibrary.simpleMessage("局域網代理"),
    "allowedIps": MessageLookupByLibrary.simpleMessage("允許的 IP"),
    "alreadyInLocalProxies": m2,
    "answers": MessageLookupByLibrary.simpleMessage("應答"),
    "app": MessageLookupByLibrary.simpleMessage("應用"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage("應用訪問控制"),
    "appIconDesign": MessageLookupByLibrary.simpleMessage("應用圖標設計"),
    "appProxiesEmpty": MessageLookupByLibrary.simpleMessage("暫無本地代理"),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage("追加系統DNS"),
    "applied": MessageLookupByLibrary.simpleMessage("已應用"),
    "applyNow": MessageLookupByLibrary.simpleMessage("立即應用"),
    "authentication": MessageLookupByLibrary.simpleMessage("認證"),
    "authenticationDesc": MessageLookupByLibrary.simpleMessage(
      "認證開啓後，使用本地代理端口需要賬號密碼。",
    ),
    "authenticationSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "認證啓用時，系統代理不生效。",
    ),
    "authorize": MessageLookupByLibrary.simpleMessage("授權"),
    "authorized": MessageLookupByLibrary.simpleMessage("已授權"),
    "auto": MessageLookupByLibrary.simpleMessage("自動"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage("自動檢查更新"),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage("自動關閉連接"),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "自動關閉連接會在切換代理後斷開已有連接。",
    ),
    "autoInclude": MessageLookupByLibrary.simpleMessage("自動包含"),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("自啓動"),
    "autoRun": MessageLookupByLibrary.simpleMessage("自動運行"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage("自動運行會在打開應用時啓動代理。"),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage("自動設置系統DNS"),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("自動更新"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage("自動更新間隔"),
    "back": MessageLookupByLibrary.simpleMessage("返回"),
    "backgroundBlur": MessageLookupByLibrary.simpleMessage("背景模糊"),
    "backup": MessageLookupByLibrary.simpleMessage("備份"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage("備份與恢復"),
    "backupFromNewerVersion": MessageLookupByLibrary.simpleMessage(
      "該備份來自更高版本的應用，請先更新應用再恢復",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("備份成功"),
    "basicInfo": MessageLookupByLibrary.simpleMessage("基礎信息"),
    "basicStrategy": MessageLookupByLibrary.simpleMessage("基礎策略"),
    "batchAdd": MessageLookupByLibrary.simpleMessage("批量添加"),
    "batchImport": MessageLookupByLibrary.simpleMessage("批量導入"),
    "batchLinkInputTip": MessageLookupByLibrary.simpleMessage("每行一個鏈接"),
    "batchListInputTip": MessageLookupByLibrary.simpleMessage("每行一項，也可用逗號分隔"),
    "batchMapInputTip": MessageLookupByLibrary.simpleMessage("每行一條，鍵和值之間用空格分隔"),
    "batchPreviewTip": m3,
    "batchUrlInputTip": MessageLookupByLibrary.simpleMessage("每行一個URL"),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "忽略電池優化可保證應用在後臺運行。",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("綁定"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("黑名單模式"),
    "blockConnection": MessageLookupByLibrary.simpleMessage("阻止連接"),
    "brightness": MessageLookupByLibrary.simpleMessage("亮度"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("排除域名"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "排除域名僅在系統代理啓用時生效。",
    ),
    "bypassPrivateRoute": MessageLookupByLibrary.simpleMessage("繞過私有路由地址"),
    "bypassPrivateRouteDesc": MessageLookupByLibrary.simpleMessage(
      "開啓繞過私有路由地址後，局域網、迴環和組播地址不經過虛擬網卡。",
    ),
    "cache": MessageLookupByLibrary.simpleMessage("緩存"),
    "cacheAlgorithm": MessageLookupByLibrary.simpleMessage("緩存算法"),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage("緩存已損壞，是否清空？"),
    "cacheMaxSize": MessageLookupByLibrary.simpleMessage("緩存大小"),
    "cameraPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "請在系統設置中允許訪問相機以掃描二維碼，或從相冊選擇二維碼圖片。",
    ),
    "cameraPermissionRequired": MessageLookupByLibrary.simpleMessage("需要相機權限"),
    "cameraUnavailable": MessageLookupByLibrary.simpleMessage("相機不可用"),
    "cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage("取消全選"),
    "cannotSave": MessageLookupByLibrary.simpleMessage("無法保存"),
    "changeProxyFailedTip": MessageLookupByLibrary.simpleMessage(
      "切換代理失敗，已恢復上一次的選擇",
    ),
    "changelogBreaking": MessageLookupByLibrary.simpleMessage("重大變更"),
    "changelogFeatures": MessageLookupByLibrary.simpleMessage("新功能"),
    "changelogFixes": MessageLookupByLibrary.simpleMessage("問題修復"),
    "changelogPerformance": MessageLookupByLibrary.simpleMessage("性能優化"),
    "changelogReverts": MessageLookupByLibrary.simpleMessage("已回滾"),
    "checkCertificate": MessageLookupByLibrary.simpleMessage("校驗 TLS 證書"),
    "checkCertificateDesc": MessageLookupByLibrary.simpleMessage(
      "關閉證書校驗後，訂閱和備份可能遭中間人攻擊。",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("檢查更新"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage("當前應用已經是最新版了"),
    "cipher": MessageLookupByLibrary.simpleMessage("加密方式"),
    "clearData": MessageLookupByLibrary.simpleMessage("清除數據"),
    "clearDataAndExitTip": MessageLookupByLibrary.simpleMessage(
      "將刪除所有配置、設置和本地數據，隨後關閉應用。重新打開即可從頭開始。",
    ),
    "clearDataFailed": m4,
    "clearDnsCache": MessageLookupByLibrary.simpleMessage("清除DNS緩存"),
    "clearDnsCacheFailed": MessageLookupByLibrary.simpleMessage("清除DNS緩存失敗"),
    "clearSearch": MessageLookupByLibrary.simpleMessage("清除搜索"),
    "clientFingerprint": MessageLookupByLibrary.simpleMessage("客戶端指紋"),
    "clipboardExport": MessageLookupByLibrary.simpleMessage("導出剪貼板"),
    "clipboardImport": MessageLookupByLibrary.simpleMessage("剪貼板導入"),
    "clipboardWriteFailed": MessageLookupByLibrary.simpleMessage(
      "無法複製到剪貼板，所選內容可能過大",
    ),
    "close": MessageLookupByLibrary.simpleMessage("關閉"),
    "closeConnections": MessageLookupByLibrary.simpleMessage("關閉連接"),
    "color": MessageLookupByLibrary.simpleMessage("顏色"),
    "colorStyle": MessageLookupByLibrary.simpleMessage("配色風格"),
    "columns": MessageLookupByLibrary.simpleMessage("列數"),
    "compact": MessageLookupByLibrary.simpleMessage("緊湊"),
    "compatible": MessageLookupByLibrary.simpleMessage("兼容模式"),
    "confirm": MessageLookupByLibrary.simpleMessage("確定"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage("確定要清除所有數據？"),
    "confirmDeleteProxyGroup": MessageLookupByLibrary.simpleMessage(
      "確定要刪除當前策略組嗎？",
    ),
    "confirmExitWindow": MessageLookupByLibrary.simpleMessage("確定要退出當前窗口嗎？"),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage("確定要強制崩潰核心？"),
    "congestionControl": MessageLookupByLibrary.simpleMessage("擁塞控制"),
    "congestionController": MessageLookupByLibrary.simpleMessage("TCP 擁塞控制"),
    "congestionControllerDesc": MessageLookupByLibrary.simpleMessage(
      "TCP 擁塞控制僅在 mips 棧生效。",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("已連接"),
    "connecting": MessageLookupByLibrary.simpleMessage("連接中…"),
    "connection": MessageLookupByLibrary.simpleMessage("連接"),
    "connectionStats": MessageLookupByLibrary.simpleMessage("連接統計"),
    "connectionStatsDesc": MessageLookupByLibrary.simpleMessage(
      "實時連接、最近請求、DNS查詢",
    ),
    "connections": MessageLookupByLibrary.simpleMessage("連接"),
    "connectivity": MessageLookupByLibrary.simpleMessage("連通性："),
    "content": MessageLookupByLibrary.simpleMessage("內容"),
    "contentNotEmpty": MessageLookupByLibrary.simpleMessage("內容不能爲空"),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage("控制全局附加規則"),
    "copy": MessageLookupByLibrary.simpleMessage("複製"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage("複製環境變量"),
    "copyLink": MessageLookupByLibrary.simpleMessage("複製鏈接"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("複製成功"),
    "core": MessageLookupByLibrary.simpleMessage("內核"),
    "coreBlockedByPolicyTip": m5,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "Windows 智能應用控制攔截了未簽名的 FlClashCore.exe。請打開 Windows 安全中心 → 應用和瀏覽器控制 → 智能應用控制設置，選擇「關閉」後重新啓動 FlClash。智能應用控制關閉後無法再開啓，除非重裝 Windows。",
    ),
    "coreStatus": MessageLookupByLibrary.simpleMessage("核心狀態"),
    "country": MessageLookupByLibrary.simpleMessage("區域"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("檢測到崩潰"),
    "crashDetectedTip": m6,
    "crashTest": MessageLookupByLibrary.simpleMessage("崩潰測試"),
    "create": MessageLookupByLibrary.simpleMessage("創建"),
    "createProfileFromUrlTip": m7,
    "creationTime": MessageLookupByLibrary.simpleMessage("創建時間"),
    "currentOutboundDesc": MessageLookupByLibrary.simpleMessage("含啓動鍵，不可移除"),
    "custom": MessageLookupByLibrary.simpleMessage("自定義"),
    "customColor": MessageLookupByLibrary.simpleMessage("自定義顏色"),
    "customImportDroppedSubRules": m8,
    "customIssueCoreRejected": m9,
    "customIssueDialerLoop": m10,
    "customIssueDuplicateName": m11,
    "customIssueEmptyName": MessageLookupByLibrary.simpleMessage("名稱爲空"),
    "customIssueGroupLoop": m12,
    "customIssueInvalidEmptyFallback": m13,
    "customIssueInvalidFilter": m14,
    "customIssueMissingDialer": m15,
    "customIssueMissingProviders": m16,
    "customIssueMissingProxies": m17,
    "customIssueNoProxySource": MessageLookupByLibrary.simpleMessage(
      "未選擇任何代理或代理集，內核會拒絕該策略組",
    ),
    "customIssueReservedName": m18,
    "customIssuesSummary": m19,
    "customProfile": MessageLookupByLibrary.simpleMessage("自定義"),
    "customProfileResources": MessageLookupByLibrary.simpleMessage("自定義配置資源"),
    "customProfileResourcesDesc": MessageLookupByLibrary.simpleMessage(
      "自定義配置資源是你自行添加的代理、規則集、篩選與圖標集，供自定義配置引用。",
    ),
    "cut": MessageLookupByLibrary.simpleMessage("剪切"),
    "dark": MessageLookupByLibrary.simpleMessage("深色"),
    "dashboard": MessageLookupByLibrary.simpleMessage("儀表盤"),
    "dashboardAddableSection": MessageLookupByLibrary.simpleMessage("可添加"),
    "databaseWriteFailedTip": MessageLookupByLibrary.simpleMessage(
      "保存更改失敗，已回滾",
    ),
    "daysAgo": m20,
    "daysAgoShort": m21,
    "defaultSelected": MessageLookupByLibrary.simpleMessage("默認選中"),
    "defaultText": MessageLookupByLibrary.simpleMessage("默認"),
    "definitionNotMap": MessageLookupByLibrary.simpleMessage(
      "配置必須是包含 name 和 type 的 YAML 映射",
    ),
    "delay": MessageLookupByLibrary.simpleMessage("延遲"),
    "delayFailed": MessageLookupByLibrary.simpleMessage("失敗"),
    "delayTest": MessageLookupByLibrary.simpleMessage("延遲測試"),
    "delayTestTimeout": MessageLookupByLibrary.simpleMessage("延遲測試超時"),
    "delete": MessageLookupByLibrary.simpleMessage("刪除"),
    "deleteMultipTip": m22,
    "deleteTip": m23,
    "desc": MessageLookupByLibrary.simpleMessage(
      "基於ClashMeta的多平臺代理客戶端，簡單易用，開源無廣告。",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("目標地址"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage("目標地理定位"),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage("目標IP ASN"),
    "details": m24,
    "detectionTip": MessageLookupByLibrary.simpleMessage("依賴第三方api，僅供參考"),
    "developerMode": MessageLookupByLibrary.simpleMessage("開發者模式"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage("開發者模式已啓用。"),
    "dialerProxy": MessageLookupByLibrary.simpleMessage("撥號代理"),
    "dialerProxyDesc": MessageLookupByLibrary.simpleMessage(
      "撥號代理爲連接 NTP 服務器使用的出站。",
    ),
    "dialerProxyLoopStopped": m25,
    "direct": MessageLookupByLibrary.simpleMessage("直連"),
    "disableIcmpForwarding": MessageLookupByLibrary.simpleMessage("禁用ICMP轉發"),
    "disableIcmpForwardingDesc": MessageLookupByLibrary.simpleMessage(
      "禁用 ICMP 轉發後由虛擬網卡直接應答 ping，ping 將不再顯示真實延遲。",
    ),
    "disableKeepAlive": MessageLookupByLibrary.simpleMessage("禁用 TCP 保持活動"),
    "disableUDP": MessageLookupByLibrary.simpleMessage("禁用UDP"),
    "disabled": MessageLookupByLibrary.simpleMessage("已關閉"),
    "discardChanges": MessageLookupByLibrary.simpleMessage("是否放棄更改？"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("免責聲明"),
    "disclaimerAcceptContent": MessageLookupByLibrary.simpleMessage(
      "一旦你安裝、複製或使用本軟件，即視爲你已閱讀並同意本聲明的全部內容。如你不同意本聲明的任何條款，請立即停止使用並卸載本軟件。",
    ),
    "disclaimerAcceptTitle": MessageLookupByLibrary.simpleMessage("接受聲明"),
    "disclaimerAcknowledgeLabel": MessageLookupByLibrary.simpleMessage(
      "我已閱讀並理解此聲明",
    ),
    "disclaimerAcknowledgeTip": MessageLookupByLibrary.simpleMessage(
      "爲確認你已知悉，請閱讀以下聲明並勾選下方選項：",
    ),
    "disclaimerAcknowledgeTitle": MessageLookupByLibrary.simpleMessage("確認聲明"),
    "disclaimerChangesContent": MessageLookupByLibrary.simpleMessage(
      "開發者有權隨版本更新修改本聲明，修改後的內容隨新版本發佈即生效。你在更新後繼續使用本軟件，即視爲接受修改後的聲明。",
    ),
    "disclaimerChangesTitle": MessageLookupByLibrary.simpleMessage("聲明變更"),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "在使用 FlClash（以下簡稱“本軟件”）前，請仔細閱讀並充分理解本聲明的全部內容。點擊“同意”即表示你已閱讀、理解並接受以下全部條款；如不同意，請點擊“退出”並停止使用本軟件。",
    ),
    "disclaimerLiabilityContent": MessageLookupByLibrary.simpleMessage(
      "在適用法律允許的最大範圍內，開發者及所有貢獻者均不對因使用或無法使用本軟件而產生的任何直接、間接、偶然、特殊、懲罰性或後果性損害承擔責任，包括但不限於數據丟失、設備損壞、網絡異常、業務中斷、利潤損失或因此引起的任何法律糾紛，即使已被告知發生此類損害的可能性。",
    ),
    "disclaimerLiabilityTitle": MessageLookupByLibrary.simpleMessage("責任限制"),
    "disclaimerLicenseContent": MessageLookupByLibrary.simpleMessage(
      "本軟件以 GPL-3.0 協議開源。你可以在遵守該協議的前提下自由使用、修改和分發本軟件，但須同樣以 GPL-3.0 協議開源並保留原作者的版權聲明。\n\n本軟件包含的第三方組件（包括 Clash.Meta 內核）分別遵循其各自的開源協議。基於本軟件修改或分發的版本所產生的任何問題，與原作者無關。",
    ),
    "disclaimerLicenseTitle": MessageLookupByLibrary.simpleMessage("開源協議"),
    "disclaimerNoServiceStatement": MessageLookupByLibrary.simpleMessage(
      "本軟件自身不提供任何代理服務器、節點、訂閱、機場或網絡接入服務，也不與任何此類服務的提供者存在合作、代理或擔保關係。",
    ),
    "disclaimerPrivacyContent": MessageLookupByLibrary.simpleMessage(
      "本軟件不會收集或上傳你的訂閱地址、節點信息、配置內容、訪問的網站、連接記錄、流量內容和日誌，這些數據僅保存在你的設備本地，開發者無法獲取。\n\n本軟件只會在你使用相應功能時訪問外部網絡，例如更新訂閱時訪問你提供的訂閱地址、檢查更新時訪問 GitHub。\n\n本軟件在所有平臺上均未集成任何數據統計或崩潰上報服務。",
    ),
    "disclaimerPrivacyTitle": MessageLookupByLibrary.simpleMessage("數據收集與隱私"),
    "disclaimerResponsibilityContent": MessageLookupByLibrary.simpleMessage(
      "你應自行確認使用本軟件在你所在國家或地區是合法的，並對使用本軟件的全部行爲及其後果獨立承擔法律責任。\n\n你導入的訂閱、節點與配置由你自行選擇和判斷，其來源是否合法、內容是否安全、服務是否穩定，均由你與相關提供者自行負責。",
    ),
    "disclaimerResponsibilityTitle": MessageLookupByLibrary.simpleMessage(
      "用戶責任",
    ),
    "disclaimerRestateHint": MessageLookupByLibrary.simpleMessage("在此輸入上述聲明"),
    "disclaimerRestateMismatch": MessageLookupByLibrary.simpleMessage(
      "與聲明內容不一致",
    ),
    "disclaimerRestateTip": MessageLookupByLibrary.simpleMessage(
      "爲確認你已知悉，請在下方輸入框中完整複述以下聲明：",
    ),
    "disclaimerRestateTitle": MessageLookupByLibrary.simpleMessage("複述聲明"),
    "disclaimerSoftwareContent": MessageLookupByLibrary.simpleMessage(
      "本軟件是基於 Clash.Meta（mihomo）內核的開源網絡代理客戶端，僅提供配置管理、規則分流與流量轉發等本地工具功能。",
    ),
    "disclaimerSoftwareTitle": MessageLookupByLibrary.simpleMessage("軟件性質"),
    "disclaimerThirdPartyContent": MessageLookupByLibrary.simpleMessage(
      "訂閱鏈接、配置文件、規則集、腳本、外部資源及外部鏈接均由第三方提供，開發者無法也不會對其合法性、準確性、安全性和可用性進行審查或擔保。\n\n因使用第三方內容導致的數據泄露、財產損失、賬號封禁或其他任何損失，由你與第三方自行解決，開發者不承擔任何責任。",
    ),
    "disclaimerThirdPartyTitle": MessageLookupByLibrary.simpleMessage("第三方內容"),
    "disclaimerUsageContent": MessageLookupByLibrary.simpleMessage(
      "本軟件僅供學習交流、技術研究等非商業用途。嚴禁將本軟件用於任何商業目的，包括但不限於付費分發、捆綁銷售、作爲商業服務的組成部分或以本軟件名義開展經營活動；任何商業行爲均與本軟件及其開發者無關。\n\n嚴禁將本軟件用於違反你所在國家或地區法律法規的活動，包括但不限於繞過依法設置的網絡訪問限制、傳播違法信息、實施網絡攻擊或侵犯他人合法權益。",
    ),
    "disclaimerUsageTitle": MessageLookupByLibrary.simpleMessage("使用限制"),
    "disclaimerWarrantyContent": MessageLookupByLibrary.simpleMessage(
      "本軟件按“現狀”和“可用”的原則提供，不附帶任何明示或默示的擔保，包括但不限於適銷性、特定用途適用性、不侵權以及持續可用、無錯誤、無安全漏洞的擔保。\n\n開發者不保證本軟件能滿足你的需求，也不保證本軟件的運行不會中斷或不會出現錯誤。",
    ),
    "disclaimerWarrantyTitle": MessageLookupByLibrary.simpleMessage("無擔保聲明"),
    "disconnected": MessageLookupByLibrary.simpleMessage("已斷開"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage("發現新版本"),
    "dnsCacheCleared": MessageLookupByLibrary.simpleMessage("DNS緩存已清除"),
    "dnsHijackDesc": MessageLookupByLibrary.simpleMessage(
      "未添加時劫持所有發往 53 端口的 DNS 請求（any:53）。",
    ),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("DNS劫持"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNS模式"),
    "dnsOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "添加的項會覆寫所有 URL 和文件配置的 DNS，未添加的項沿用配置自身的設置。自定義配置的 DNS 在其內容中設置。",
    ),
    "dnsQueries": MessageLookupByLibrary.simpleMessage("DNS查詢"),
    "docked": MessageLookupByLibrary.simpleMessage("固定"),
    "domain": MessageLookupByLibrary.simpleMessage("域名"),
    "done": MessageLookupByLibrary.simpleMessage("完成"),
    "download": MessageLookupByLibrary.simpleMessage("下載"),
    "downloadBandwidth": MessageLookupByLibrary.simpleMessage("下行帶寬"),
    "duration": MessageLookupByLibrary.simpleMessage("時長"),
    "edit": MessageLookupByLibrary.simpleMessage("編輯"),
    "editDashboard": MessageLookupByLibrary.simpleMessage("編輯儀表盤"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage("編輯全局規則"),
    "editProxy": MessageLookupByLibrary.simpleMessage("編輯代理"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage("編輯策略組"),
    "editRule": MessageLookupByLibrary.simpleMessage("編輯規則"),
    "editSsid": MessageLookupByLibrary.simpleMessage("編輯SSID"),
    "editorUnavailable": MessageLookupByLibrary.simpleMessage("編輯器不可用"),
    "elapsed": MessageLookupByLibrary.simpleMessage("耗時"),
    "emptyFallback": MessageLookupByLibrary.simpleMessage("空組兜底"),
    "emptyTip": m26,
    "en": MessageLookupByLibrary.simpleMessage("英語"),
    "enabled": MessageLookupByLibrary.simpleMessage("已開啓"),
    "entries": MessageLookupByLibrary.simpleMessage("個條目"),
    "error": MessageLookupByLibrary.simpleMessage("錯誤"),
    "errorDetails": MessageLookupByLibrary.simpleMessage("錯誤詳情"),
    "es": MessageLookupByLibrary.simpleMessage("西班牙語"),
    "exclude": MessageLookupByLibrary.simpleMessage("從最近任務中隱藏"),
    "excludeDstPort": MessageLookupByLibrary.simpleMessage("排除目標端口"),
    "excludeDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "發往這些目標端口的流量不經過虛擬網卡。",
    ),
    "excludeFilter": MessageLookupByLibrary.simpleMessage("排除篩選"),
    "excludeInterface": MessageLookupByLibrary.simpleMessage("排除網卡"),
    "excludeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "從這些網卡（如 docker0）進入的流量不經過虛擬網卡。",
    ),
    "excludeSrcPort": MessageLookupByLibrary.simpleMessage("排除源端口"),
    "excludeSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "源端口爲這些端口的流量不經過虛擬網卡。",
    ),
    "excludeSsids": MessageLookupByLibrary.simpleMessage("排除SSIDs"),
    "excludeSsidsDesc": MessageLookupByLibrary.simpleMessage(
      "連接到被排除 SSID 的 Wi-Fi 時，將會自動切換應用運行狀態。",
    ),
    "excludeUid": MessageLookupByLibrary.simpleMessage("排除用戶 ID"),
    "excludeUidDesc": MessageLookupByLibrary.simpleMessage(
      "這些用戶 ID 的進程產生的流量不經過虛擬網卡。",
    ),
    "existsTip": m27,
    "exit": MessageLookupByLibrary.simpleMessage("退出"),
    "exitFullScreen": MessageLookupByLibrary.simpleMessage("退出全屏"),
    "exitNodes": MessageLookupByLibrary.simpleMessage("出口節點"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("預期狀態"),
    "expireTime": MessageLookupByLibrary.simpleMessage("到期時間"),
    "exportFile": MessageLookupByLibrary.simpleMessage("導出文件"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("導出日誌"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("導出成功"),
    "extend": MessageLookupByLibrary.simpleMessage("擴展"),
    "extendMode": MessageLookupByLibrary.simpleMessage("擴展模式"),
    "extendScript": MessageLookupByLibrary.simpleMessage("擴展腳本"),
    "externalController": MessageLookupByLibrary.simpleMessage("外部控制器"),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "外部控制器開啓後，可通過 9090 端口控制內核。",
    ),
    "externalControllerSecret": MessageLookupByLibrary.simpleMessage("外部控制器密鑰"),
    "externalLink": MessageLookupByLibrary.simpleMessage("外部鏈接"),
    "extraLarge": MessageLookupByLibrary.simpleMessage("超大"),
    "fade": MessageLookupByLibrary.simpleMessage("淡入"),
    "failedCount": m28,
    "failedItem": m29,
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Fake-IP過濾"),
    "fakeipFilterMode": MessageLookupByLibrary.simpleMessage("Fake-IP過濾模式"),
    "fakeipFilterModeDesc": MessageLookupByLibrary.simpleMessage(
      "Fake-IP 過濾模式中，blacklist 排除匹配項，whitelist 僅用於匹配項，rule 按規則匹配。",
    ),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Fake-IP範圍"),
    "fakeipRange6": MessageLookupByLibrary.simpleMessage("Fake-IP範圍（IPv6）"),
    "fakeipTtl": MessageLookupByLibrary.simpleMessage("Fake-IP TTL"),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("Fallback過濾"),
    "file": MessageLookupByLibrary.simpleMessage("文件"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage("文件有修改，是否保存修改"),
    "filter": MessageLookupByLibrary.simpleMessage("篩選"),
    "filters": MessageLookupByLibrary.simpleMessage("篩選"),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("查找進程"),
    "floating": MessageLookupByLibrary.simpleMessage("懸浮"),
    "followProfile": MessageLookupByLibrary.simpleMessage("跟隨配置"),
    "followSystem": MessageLookupByLibrary.simpleMessage("跟隨系統"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("字體"),
    "fontSize": MessageLookupByLibrary.simpleMessage("大小"),
    "forceDnsMapping": MessageLookupByLibrary.simpleMessage("強制DNS映射"),
    "forceDnsMappingDesc": MessageLookupByLibrary.simpleMessage(
      "強制 DNS 映射對通過 DNS 映射得到域名的連接也進行嗅探。",
    ),
    "forceDomain": MessageLookupByLibrary.simpleMessage("強制嗅探域名"),
    "forceDomainDesc": MessageLookupByLibrary.simpleMessage(
      "強制嗅探域名中的域名同樣會被嗅探，其餘已有域名的連接不嗅探。",
    ),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage("您確定要強制重啓核心嗎？"),
    "fr": MessageLookupByLibrary.simpleMessage("法語"),
    "general": MessageLookupByLibrary.simpleMessage("常規"),
    "generalOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "添加的項會覆寫所有配置的對應設置，未添加的項沿用配置自身的設置，配置未設置時使用內核默認值。",
    ),
    "geoResources": MessageLookupByLibrary.simpleMessage("Geo"),
    "geoSkipped": m30,
    "geoUpdated": m31,
    "geodataLoader": MessageLookupByLibrary.simpleMessage("Geo低內存模式"),
    "global": MessageLookupByLibrary.simpleMessage("全局"),
    "go": MessageLookupByLibrary.simpleMessage("前往"),
    "goDownload": MessageLookupByLibrary.simpleMessage("前往下載"),
    "goToConfigureAddedRules": MessageLookupByLibrary.simpleMessage("前往配置附加規則"),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage("前往配置腳本"),
    "grid": MessageLookupByLibrary.simpleMessage("網格"),
    "groupCount": m32,
    "groupCountUnit": MessageLookupByLibrary.simpleMessage("個"),
    "groupTimeoutCount": m33,
    "hasCacheChange": MessageLookupByLibrary.simpleMessage("是否緩存修改"),
    "hashByInUser": MessageLookupByLibrary.simpleMessage("按入站用戶哈希"),
    "healthCheck": MessageLookupByLibrary.simpleMessage("健康檢查"),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "Helper 服務不可用，無法啓用 TUN 模式，請重新安裝 FlClash。",
    ),
    "hex": MessageLookupByLibrary.simpleMessage("十六進制"),
    "hideFromList": MessageLookupByLibrary.simpleMessage("從列表中隱藏"),
    "hideIp": MessageLookupByLibrary.simpleMessage("隱藏 IP"),
    "hidePassword": MessageLookupByLibrary.simpleMessage("隱藏密碼"),
    "hideTimeoutProxies": MessageLookupByLibrary.simpleMessage("隱藏超時代理"),
    "hopInterval": MessageLookupByLibrary.simpleMessage("跳躍間隔"),
    "host": MessageLookupByLibrary.simpleMessage("主機"),
    "hostname": MessageLookupByLibrary.simpleMessage("主機名"),
    "hotkeyConflictWith": m34,
    "hotkeyDesc": MessageLookupByLibrary.simpleMessage(
      "全局快捷鍵在窗口隱藏時依然生效，點擊操作即可錄製組合鍵。",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage("快捷鍵管理"),
    "hotkeyNeedsModifier": m35,
    "hotkeyNotSet": MessageLookupByLibrary.simpleMessage("未設置"),
    "hotkeyUnavailable": MessageLookupByLibrary.simpleMessage(
      "未能註冊，可能已被其他應用佔用",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("小時"),
    "hoursAgo": m36,
    "hoursAgoShort": m37,
    "hue": MessageLookupByLibrary.simpleMessage("色相"),
    "icon": MessageLookupByLibrary.simpleMessage("圖標"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("圖標記錄"),
    "iconSets": MessageLookupByLibrary.simpleMessage("圖標集"),
    "iconSetsEmptyTip": MessageLookupByLibrary.simpleMessage(
      "暫無圖標集，可在「自定義配置資源 → 圖標集」中添加",
    ),
    "iconStyle": MessageLookupByLibrary.simpleMessage("圖標樣式"),
    "iconStyleFilled": MessageLookupByLibrary.simpleMessage("色塊"),
    "iconStyleHidden": MessageLookupByLibrary.simpleMessage("隱藏"),
    "iconStylePlain": MessageLookupByLibrary.simpleMessage("純圖標"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("圖標鏈接"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage("忽略電池優化"),
    "import": MessageLookupByLibrary.simpleMessage("導入"),
    "importConfigInvalid": MessageLookupByLibrary.simpleMessage("此文件不是可導入的配置"),
    "importConfigReplaceTip": MessageLookupByLibrary.simpleMessage(
      "導入會替換此配置現有的策略組、規則和設置",
    ),
    "importFile": MessageLookupByLibrary.simpleMessage("通過文件導入"),
    "importFromLink": MessageLookupByLibrary.simpleMessage("從鏈接導入"),
    "importUrl": MessageLookupByLibrary.simpleMessage("通過URL導入"),
    "inbound": MessageLookupByLibrary.simpleMessage("入站"),
    "includeInterface": MessageLookupByLibrary.simpleMessage("包含網卡"),
    "includeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "只有從包含網卡進入的流量經過虛擬網卡，設置後排除網卡不再生效。",
    ),
    "includeUid": MessageLookupByLibrary.simpleMessage("包含用戶 ID"),
    "includeUidDesc": MessageLookupByLibrary.simpleMessage(
      "只有這些用戶 ID 的進程產生的流量經過虛擬網卡。",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("長期有效"),
    "init": MessageLookupByLibrary.simpleMessage("初始化"),
    "initFailed": MessageLookupByLibrary.simpleMessage("啓動失敗"),
    "initFailedTip": MessageLookupByLibrary.simpleMessage(
      "FlClash 啓動時出錯，無法繼續運行。可以複製錯誤詳情用於反饋；如果問題反覆出現，清除數據後通常可以重新啓動。",
    ),
    "initiator": MessageLookupByLibrary.simpleMessage("發起方"),
    "initiatorShort": MessageLookupByLibrary.simpleMessage("發起"),
    "inputProxyGroupName": MessageLookupByLibrary.simpleMessage("輸入策略組名稱"),
    "inputRuleContent": MessageLookupByLibrary.simpleMessage("輸入規則內容"),
    "installedAppsPermissionDeniedMessage":
        MessageLookupByLibrary.simpleMessage(
          "讀取應用列表權限已被拒絕，無法獲取已安裝的應用。請前往系統設置手動開啓。",
        ),
    "installedAppsPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "當前系統在授權前不會提供已安裝的應用列表，授權後即可配置分應用代理。",
    ),
    "installedAppsPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "需要讀取應用列表權限",
    ),
    "installedFonts": MessageLookupByLibrary.simpleMessage("已安裝字體"),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage("智能選擇"),
    "interfaceName": MessageLookupByLibrary.simpleMessage("網卡名稱"),
    "interfaceNameDesc": MessageLookupByLibrary.simpleMessage(
      "網卡名稱爲出站連接使用的網卡。",
    ),
    "interfaceNameMode": MessageLookupByLibrary.simpleMessage("出站網卡"),
    "interfaceNameModeClear": MessageLookupByLibrary.simpleMessage("清空"),
    "interfaceNameModeCustom": MessageLookupByLibrary.simpleMessage("自定義"),
    "interfaceNameModeFollow": MessageLookupByLibrary.simpleMessage("跟隨配置"),
    "internet": MessageLookupByLibrary.simpleMessage("互聯網"),
    "interval": MessageLookupByLibrary.simpleMessage("間隔"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("內網 IP"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage("無效備份文件"),
    "invalidCidrContent": MessageLookupByLibrary.simpleMessage(
      "請輸入 CIDR 格式的 IP 段，如 192.168.0.0/16",
    ),
    "invalidDscpContent": MessageLookupByLibrary.simpleMessage(
      "DSCP 標記不能超過 63",
    ),
    "invalidHostContent": MessageLookupByLibrary.simpleMessage("請輸入域名或 IP 地址"),
    "invalidIconSet": MessageLookupByLibrary.simpleMessage("不是有效的圖標集"),
    "invalidLinkTip": MessageLookupByLibrary.simpleMessage("不是有效的訂閱鏈接或代理分享鏈接"),
    "invalidListenContent": MessageLookupByLibrary.simpleMessage(
      "請輸入地址和端口，如 0.0.0.0:1053",
    ),
    "invalidNetworkContent": MessageLookupByLibrary.simpleMessage(
      "僅支持 tcp 或 udp",
    ),
    "invalidPolicy": m38,
    "invalidPortRangeContent": MessageLookupByLibrary.simpleMessage(
      "請輸入端口或範圍，如 443 或 8000-9000",
    ),
    "invalidProfileQrcode": MessageLookupByLibrary.simpleMessage(
      "該二維碼不包含配置文件鏈接",
    ),
    "invalidProxy": m39,
    "invalidProxyProvider": m40,
    "invalidRangeContent": MessageLookupByLibrary.simpleMessage(
      "請輸入數字或範圍，如 80 或 8000-9000，多個用 / 分隔",
    ),
    "invalidRuleSet": m41,
    "invalidSubRule": m42,
    "ipAddress": MessageLookupByLibrary.simpleMessage("IP 地址"),
    "ipAsn": MessageLookupByLibrary.simpleMessage("ASN"),
    "ipFlagAbuser": MessageLookupByLibrary.simpleMessage("濫用記錄"),
    "ipFlagProxy": MessageLookupByLibrary.simpleMessage("代理"),
    "ipFlagTor": MessageLookupByLibrary.simpleMessage("Tor"),
    "ipFlagVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "ipFlags": MessageLookupByLibrary.simpleMessage("命中標記"),
    "ipOrganization": MessageLookupByLibrary.simpleMessage("組織"),
    "proxyNode": MessageLookupByLibrary.simpleMessage("代理節點"),
    "ipQualityFailed": MessageLookupByLibrary.simpleMessage("類型查詢失敗"),
    "ipQualityGood": MessageLookupByLibrary.simpleMessage("優"),
    "ipQualityLevel": MessageLookupByLibrary.simpleMessage("等級"),
    "ipQualityNormal": MessageLookupByLibrary.simpleMessage("普通"),
    "ipQualityRetry": MessageLookupByLibrary.simpleMessage("重新查詢"),
    "ipQualityRisky": MessageLookupByLibrary.simpleMessage("風險"),
    "ipQualityShort": MessageLookupByLibrary.simpleMessage("質量"),
    "ipQualitySource": MessageLookupByLibrary.simpleMessage("採用來源"),
    "ipQualitySources": MessageLookupByLibrary.simpleMessage("各來源"),
    "ipSourceIpMismatch": MessageLookupByLibrary.simpleMessage("出站 IP 不一致"),
    "ipSourceNoType": MessageLookupByLibrary.simpleMessage("無法判定類型"),
    "ipSourceRateLimited": MessageLookupByLibrary.simpleMessage("限流"),
    "ipType": MessageLookupByLibrary.simpleMessage("類型"),
    "ipTypeBusiness": MessageLookupByLibrary.simpleMessage("商業"),
    "ipTypeHosting": MessageLookupByLibrary.simpleMessage("機房"),
    "ipTypeMobile": MessageLookupByLibrary.simpleMessage("移動網絡"),
    "ipTypeResidential": MessageLookupByLibrary.simpleMessage("住宅"),
    "ipTypeUnknown": MessageLookupByLibrary.simpleMessage("類型未知"),
    "ipVersion": MessageLookupByLibrary.simpleMessage("IP 版本"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage("開啓 IPv6 後纔會接收 IPv6 流量。"),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "開啓 IPv6 後，VPN 允許 IPv6 入站。",
    ),
    "ipv6Timeout": MessageLookupByLibrary.simpleMessage("IPv6超時（毫秒）"),
    "itemsCount": m43,
    "ja": MessageLookupByLibrary.simpleMessage("日語"),
    "justNow": MessageLookupByLibrary.simpleMessage("剛剛"),
    "keepAliveIdle": MessageLookupByLibrary.simpleMessage("TCP 保持活動空閒時間"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage("TCP保持活動間隔"),
    "key": MessageLookupByLibrary.simpleMessage("鍵"),
    "ko": MessageLookupByLibrary.simpleMessage("韓語"),
    "label": MessageLookupByLibrary.simpleMessage("標籤"),
    "language": MessageLookupByLibrary.simpleMessage("語言"),
    "large": MessageLookupByLibrary.simpleMessage("大"),
    "lastUpdated": MessageLookupByLibrary.simpleMessage("上次更新"),
    "launchInterrupted": MessageLookupByLibrary.simpleMessage("啓動未完成"),
    "launchInterruptedTip": MessageLookupByLibrary.simpleMessage(
      "應用上次在啓動過程中意外退出。已跳過本次自動配置，你可以手動啓動重試。",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("佈局"),
    "light": MessageLookupByLibrary.simpleMessage("淺色"),
    "lineIssueTip": m44,
    "lineWrap": MessageLookupByLibrary.simpleMessage("自動換行"),
    "link": MessageLookupByLibrary.simpleMessage("鏈接"),
    "liquidGlass": MessageLookupByLibrary.simpleMessage("液態玻璃"),
    "list": MessageLookupByLibrary.simpleMessage("列表"),
    "listen": MessageLookupByLibrary.simpleMessage("監聽"),
    "listenRoutingMark": MessageLookupByLibrary.simpleMessage("監聽路由標記"),
    "listenRoutingMarkDesc": MessageLookupByLibrary.simpleMessage(
      "監聽路由標記僅在 Linux 生效。",
    ),
    "liveConnections": MessageLookupByLibrary.simpleMessage("實時連接"),
    "loading": MessageLookupByLibrary.simpleMessage("加載中…"),
    "local": MessageLookupByLibrary.simpleMessage("本地"),
    "localImage": MessageLookupByLibrary.simpleMessage("本地圖片"),
    "localNetworkDeniedTip": MessageLookupByLibrary.simpleMessage(
      "本地網絡權限被拒絕：已改用 gvisor 棧，局域網無法訪問。",
    ),
    "localProxies": MessageLookupByLibrary.simpleMessage("本地代理"),
    "locationPermission": MessageLookupByLibrary.simpleMessage("位置權限"),
    "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "位置權限已被拒絕，無法獲取當前 Wi-Fi 名稱。請前往系統設置手動開啓位置權限。",
    ),
    "locationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "根據系統要求，獲取Wi-Fi名稱需要您授予位置權限。Android 上請選擇“始終允許”，否則應用在後臺時無法獲取 Wi-Fi 名稱。",
    ),
    "locationPermissionGuide": m45,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "需要位置權限",
    ),
    "log": MessageLookupByLibrary.simpleMessage("日誌"),
    "logLevel": MessageLookupByLibrary.simpleMessage("日誌等級"),
    "logcat": MessageLookupByLibrary.simpleMessage("日誌捕獲"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage("關閉日誌捕獲會隱藏日誌入口。"),
    "logs": MessageLookupByLibrary.simpleMessage("日誌"),
    "logsAndDiagnostics": MessageLookupByLibrary.simpleMessage("日誌與診斷"),
    "logsTest": MessageLookupByLibrary.simpleMessage("日誌測試"),
    "loopback": MessageLookupByLibrary.simpleMessage("UWP 迴環解鎖"),
    "loose": MessageLookupByLibrary.simpleMessage("寬鬆"),
    "matchCase": MessageLookupByLibrary.simpleMessage("區分大小寫"),
    "matchSourceIp": MessageLookupByLibrary.simpleMessage("匹配來源IP"),
    "matchTarget": MessageLookupByLibrary.simpleMessage("MATCH-TARGET"),
    "maxFailedTimes": MessageLookupByLibrary.simpleMessage("最大失敗次數"),
    "maxLengthTip": m46,
    "maximize": MessageLookupByLibrary.simpleMessage("最大化"),
    "memoryAppResident": MessageLookupByLibrary.simpleMessage("常駐內存"),
    "memoryAppShared": MessageLookupByLibrary.simpleMessage("應用及共享"),
    "memoryCoreHeapIdle": MessageLookupByLibrary.simpleMessage("堆內存空閒"),
    "memoryCoreHeapInuse": MessageLookupByLibrary.simpleMessage("堆內存使用中"),
    "memoryCoreNotRunning": MessageLookupByLibrary.simpleMessage("內核未運行"),
    "memoryCoreRuntime": MessageLookupByLibrary.simpleMessage("運行時開銷"),
    "memoryCoreStack": MessageLookupByLibrary.simpleMessage("協程棧"),
    "memoryEstimateDesc": MessageLookupByLibrary.simpleMessage(
      "基於進程常駐內存估算，可能與系統顯示的數值不同。",
    ),
    "memoryEstimateSharedDesc": MessageLookupByLibrary.simpleMessage(
      "內核與應用運行在同一進程，內核部分按運行時統計估算，其餘計入應用及共享內存。",
    ),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("內存信息"),
    "memoryInfoDesc": MessageLookupByLibrary.simpleMessage("應用與內核佔用的內存"),
    "memoryReleased": MessageLookupByLibrary.simpleMessage("內存已釋放"),
    "memoryReleasedSize": m47,
    "messageTest": MessageLookupByLibrary.simpleMessage("消息測試"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage("這是一條消息。"),
    "minimize": MessageLookupByLibrary.simpleMessage("最小化"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("退出時最小化"),
    "minutes": MessageLookupByLibrary.simpleMessage("分鐘"),
    "minutesAgo": m48,
    "minutesAgoShort": m49,
    "mixedPort": MessageLookupByLibrary.simpleMessage("混合端口"),
    "mode": MessageLookupByLibrary.simpleMessage("模式"),
    "monochromeIcon": MessageLookupByLibrary.simpleMessage("單色圖標"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("單色"),
    "monthsAgo": m50,
    "monthsAgoShort": m51,
    "more": MessageLookupByLibrary.simpleMessage("更多"),
    "name": MessageLookupByLibrary.simpleMessage("名稱"),
    "navigationBarStyle": MessageLookupByLibrary.simpleMessage("底欄"),
    "network": MessageLookupByLibrary.simpleMessage("網絡"),
    "networkAccessDeniedError": m52,
    "networkBadResponseError": m53,
    "networkCancelledError": MessageLookupByLibrary.simpleMessage("請求已取消"),
    "networkConnectionError": MessageLookupByLibrary.simpleMessage(
      "無法連接到服務器，請檢查網絡連接或代理設置",
    ),
    "networkHostLookupError": MessageLookupByLibrary.simpleMessage(
      "無法解析服務器地址，請確認鏈接正確且 DNS 可用",
    ),
    "networkName": MessageLookupByLibrary.simpleMessage("網絡名稱"),
    "networkNotFoundError": m54,
    "networkRateLimitedError": MessageLookupByLibrary.simpleMessage(
      "請求過於頻繁（HTTP 429），請稍後再試",
    ),
    "networkRequestFailed": m55,
    "networkSecret": MessageLookupByLibrary.simpleMessage("網絡密碼"),
    "networkServerError": m56,
    "networkSpeed": MessageLookupByLibrary.simpleMessage("網絡速度"),
    "networkTakeover": MessageLookupByLibrary.simpleMessage("網絡接管"),
    "networkTimeoutError": MessageLookupByLibrary.simpleMessage(
      "請求超時，請檢查網絡或代理後重試",
    ),
    "networkTlsError": MessageLookupByLibrary.simpleMessage(
      "安全連接失敗，服務器證書可能無效，或連接被攔截",
    ),
    "networkType": MessageLookupByLibrary.simpleMessage("網絡類型"),
    "nextMatch": MessageLookupByLibrary.simpleMessage("下一個匹配"),
    "no": MessageLookupByLibrary.simpleMessage("否"),
    "noData": MessageLookupByLibrary.simpleMessage("暫無數據"),
    "noInfo": MessageLookupByLibrary.simpleMessage("暫無信息"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage("不再提示"),
    "noNetwork": MessageLookupByLibrary.simpleMessage("無網絡"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("無網絡應用"),
    "noResolve": MessageLookupByLibrary.simpleMessage("不解析IP"),
    "noResolveHostname": MessageLookupByLibrary.simpleMessage("不解析主機名"),
    "noSearchResults": MessageLookupByLibrary.simpleMessage("沒有匹配的結果"),
    "nodes": MessageLookupByLibrary.simpleMessage("節點"),
    "nonTextProviderFile": MessageLookupByLibrary.simpleMessage("該外部資源不是文本文件"),
    "none": MessageLookupByLibrary.simpleMessage("無"),
    "notRunning": MessageLookupByLibrary.simpleMessage("未運行"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage("當前代理組無法選中"),
    "ntpInterval": MessageLookupByLibrary.simpleMessage("同步間隔（分鐘）"),
    "ntpStatusDesc": MessageLookupByLibrary.simpleMessage(
      "開啓 NTP 後從 NTP 服務器獲取時間，而非系統時鐘。",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage("添加一個配置文件後即可開始使用"),
    "nullTip": m57,
    "numberRangeTip": m58,
    "numberTip": m59,
    "obfs": MessageLookupByLibrary.simpleMessage("混淆"),
    "obfsHost": MessageLookupByLibrary.simpleMessage("混淆主機"),
    "obfsMode": MessageLookupByLibrary.simpleMessage("混淆模式"),
    "obfsParam": MessageLookupByLibrary.simpleMessage("混淆參數"),
    "obfsPassword": MessageLookupByLibrary.simpleMessage("混淆密碼"),
    "onDemand": MessageLookupByLibrary.simpleMessage("按需運行"),
    "onDemandDesc": MessageLookupByLibrary.simpleMessage(
      "按需運行會在連上排除的 Wi-Fi 時暫停代理。",
    ),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage("僅統計代理流量"),
    "optional": MessageLookupByLibrary.simpleMessage("可選"),
    "options": MessageLookupByLibrary.simpleMessage("選項"),
    "other": MessageLookupByLibrary.simpleMessage("其他"),
    "otherContributors": MessageLookupByLibrary.simpleMessage("其他貢獻者"),
    "outbound": MessageLookupByLibrary.simpleMessage("出站"),
    "outboundExit": MessageLookupByLibrary.simpleMessage("出口"),
    "outboundIp": MessageLookupByLibrary.simpleMessage("出站 IP"),
    "outboundMode": MessageLookupByLibrary.simpleMessage("出站模式"),
    "overrideDestination": MessageLookupByLibrary.simpleMessage("覆蓋目標地址"),
    "overrideDestinationDesc": MessageLookupByLibrary.simpleMessage(
      "覆蓋目標地址使用嗅探到的域名替換原目標地址發起連接。",
    ),
    "overrideEntries": MessageLookupByLibrary.simpleMessage("覆寫項"),
    "parsePureIp": MessageLookupByLibrary.simpleMessage("解析純IP"),
    "parsePureIpDesc": MessageLookupByLibrary.simpleMessage(
      "解析純 IP 會嗅探只有 IP 地址的連接。",
    ),
    "password": MessageLookupByLibrary.simpleMessage("密碼"),
    "paste": MessageLookupByLibrary.simpleMessage("粘貼"),
    "peers": MessageLookupByLibrary.simpleMessage("初始節點"),
    "pickFromAlbum": MessageLookupByLibrary.simpleMessage("從相冊選擇"),
    "pinWindow": MessageLookupByLibrary.simpleMessage("窗口置頂"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage("請綁定WebDAV"),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage("請輸入腳本名稱"),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "請上傳有效的二維碼",
    ),
    "plugin": MessageLookupByLibrary.simpleMessage("插件"),
    "pluginCipher": MessageLookupByLibrary.simpleMessage("插件加密方式"),
    "pluginHost": MessageLookupByLibrary.simpleMessage("插件主機"),
    "pluginMode": MessageLookupByLibrary.simpleMessage("插件模式"),
    "pluginPassword": MessageLookupByLibrary.simpleMessage("插件密碼"),
    "pluginPath": MessageLookupByLibrary.simpleMessage("插件路徑"),
    "pluginUsername": MessageLookupByLibrary.simpleMessage("插件用戶名"),
    "port": MessageLookupByLibrary.simpleMessage("端口"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage("請輸入不同的端口"),
    "portHopping": MessageLookupByLibrary.simpleMessage("端口跳躍"),
    "portTip": m60,
    "portValue": m61,
    "ports": MessageLookupByLibrary.simpleMessage("端口"),
    "preSharedKey": MessageLookupByLibrary.simpleMessage("預共享密鑰"),
    "preferred": MessageLookupByLibrary.simpleMessage("首選"),
    "prerequisites": MessageLookupByLibrary.simpleMessage("前置條件"),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage("請按下組合鍵"),
    "preview": MessageLookupByLibrary.simpleMessage("預覽"),
    "previousMatch": MessageLookupByLibrary.simpleMessage("上一個匹配"),
    "privateKey": MessageLookupByLibrary.simpleMessage("私鑰"),
    "privateKeyPassphrase": MessageLookupByLibrary.simpleMessage("私鑰密碼"),
    "process": MessageLookupByLibrary.simpleMessage("進程"),
    "currentProfile": MessageLookupByLibrary.simpleMessage("當前配置"),
        "profile": MessageLookupByLibrary.simpleMessage("配置"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("請輸入有效間隔時間格式"),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage("請輸入自動更新間隔時間"),
    "profileDaysLeft": m62,
    "profileExpiresIn": m63,
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "配置文件已經修改，是否關閉自動更新？",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "請輸入配置名稱",
    ),
    "profileSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "僅作用於當前配置，未添加的項使用默認值。",
    ),
    "profileTunSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "僅作用於當前配置，並優先於網絡設置中的虛擬網卡覆寫項。",
    ),
    "profileUpdatedAt": m64,
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "請輸入有效配置URL",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "請輸入配置URL",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("配置"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("配置排序"),
    "project": MessageLookupByLibrary.simpleMessage("項目"),
    "protocol": MessageLookupByLibrary.simpleMessage("協議"),
    "protocolParam": MessageLookupByLibrary.simpleMessage("協議參數"),
    "protocolVersion": MessageLookupByLibrary.simpleMessage("協議版本"),
    "providerInUse": m65,
    "providerUrlTip": MessageLookupByLibrary.simpleMessage("僅支持遠程資源"),
    "providers": MessageLookupByLibrary.simpleMessage("外部資源"),
    "proxies": MessageLookupByLibrary.simpleMessage("代理"),
    "proxiesCount": m66,
    "proxiesProfileLabel": m67,
    "proxiesRemovedTip": m68,
    "proxiesReplacedTip": m69,
    "proxyChains": MessageLookupByLibrary.simpleMessage("代理鏈"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("策略組"),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage("策略組爲空"),
    "proxyGroupInUse": m70,
    "proxyGroupsAfterStart": MessageLookupByLibrary.simpleMessage(
      "啓動後在這裏顯示策略組",
    ),
    "proxyGroupsCount": m71,
    "proxyProviders": MessageLookupByLibrary.simpleMessage("代理集"),
    "proxyType": MessageLookupByLibrary.simpleMessage("代理類型"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("修剪緩存"),
    "publicKey": MessageLookupByLibrary.simpleMessage("公鑰"),
    "pureBlack": MessageLookupByLibrary.simpleMessage("純黑"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("純黑模式"),
    "qrcode": MessageLookupByLibrary.simpleMessage("二維碼"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage("掃描二維碼獲取配置文件"),
    "qrcodeTooLongTip": MessageLookupByLibrary.simpleMessage(
      "鏈接過長，無法生成二維碼，請改用“複製鏈接”。",
    ),
    "quickActions": MessageLookupByLibrary.simpleMessage("快捷操作"),
    "quickEdit": MessageLookupByLibrary.simpleMessage("快速編輯"),
    "recentRequests": MessageLookupByLibrary.simpleMessage("最近請求"),
    "recommendedIcons": MessageLookupByLibrary.simpleMessage("推薦"),
    "recordType": MessageLookupByLibrary.simpleMessage("記錄類型"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Redir端口"),
    "redo": MessageLookupByLibrary.simpleMessage("重做"),
    "regex": MessageLookupByLibrary.simpleMessage("正則"),
    "releaseMemory": MessageLookupByLibrary.simpleMessage("釋放內存"),
    "releaseMemoryFailed": MessageLookupByLibrary.simpleMessage("釋放內存失敗"),
    "remote": MessageLookupByLibrary.simpleMessage("遠程"),
    "remoteDestination": MessageLookupByLibrary.simpleMessage("遠程目標"),
    "remoteDnsResolve": MessageLookupByLibrary.simpleMessage("遠程 DNS 解析"),
    "remove": MessageLookupByLibrary.simpleMessage("移除"),
    "rename": MessageLookupByLibrary.simpleMessage("重命名"),
    "replace": MessageLookupByLibrary.simpleMessage("替換"),
    "replaceAll": MessageLookupByLibrary.simpleMessage("全部替換"),
    "request": MessageLookupByLibrary.simpleMessage("請求"),
    "requestHeaders": MessageLookupByLibrary.simpleMessage("請求頭"),
    "requests": MessageLookupByLibrary.simpleMessage("請求"),
    "requestsAndUpdates": MessageLookupByLibrary.simpleMessage("請求與更新"),
    "required": MessageLookupByLibrary.simpleMessage("必填"),
    "reset": MessageLookupByLibrary.simpleMessage("重置"),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "當前頁面存在更改，確定重置嗎？",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage("確定要重置嗎？"),
    "resourceUpdateInterval": MessageLookupByLibrary.simpleMessage("自動更新間隔"),
    "resourceUpdateIntervalTip": MessageLookupByLibrary.simpleMessage(
      "自動更新間隔必須大於0",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("資源"),
    "respectRules": MessageLookupByLibrary.simpleMessage("遵守規則"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "遵守規則使 DNS 連接遵守規則，需配置 Proxy Server Nameserver。",
    ),
    "responseCode": MessageLookupByLibrary.simpleMessage("響應碼"),
    "restart": MessageLookupByLibrary.simpleMessage("重啓"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage("您確定要重啓核心嗎？"),
    "restore": MessageLookupByLibrary.simpleMessage("恢復"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage("恢復所有數據"),
    "restoreOnlyConfig": MessageLookupByLibrary.simpleMessage("僅恢復配置文件"),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage("恢復策略"),
    "restoreStrategyCompatible": MessageLookupByLibrary.simpleMessage("兼容"),
    "restoreStrategyOverride": MessageLookupByLibrary.simpleMessage("覆蓋"),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage("恢復成功"),
    "result": MessageLookupByLibrary.simpleMessage("結果"),
    "retry": MessageLookupByLibrary.simpleMessage("重試"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("路由地址"),
    "routeExcludeAddress": MessageLookupByLibrary.simpleMessage("排除路由地址"),
    "routingMark": MessageLookupByLibrary.simpleMessage("路由標記"),
    "ru": MessageLookupByLibrary.simpleMessage("俄語"),
    "rule": MessageLookupByLibrary.simpleMessage("規則"),
    "ruleActionAndDesc": MessageLookupByLibrary.simpleMessage("邏輯規則 AND"),
    "ruleActionDomainDesc": MessageLookupByLibrary.simpleMessage("匹配完整域名"),
    "ruleActionDomainKeywordDesc": MessageLookupByLibrary.simpleMessage(
      "匹配域名關鍵字",
    ),
    "ruleActionDomainRegexDesc": MessageLookupByLibrary.simpleMessage(
      "使用域名正則表達式匹配",
    ),
    "ruleActionDomainSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "匹配域名後綴",
    ),
    "ruleActionDomainWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "通配符匹配，僅支持*和?通配符",
    ),
    "ruleActionDscpDesc": MessageLookupByLibrary.simpleMessage(
      "匹配DSCP標記（僅限 tproxy udp 入站）",
    ),
    "ruleActionDstPortDesc": MessageLookupByLibrary.simpleMessage("匹配請求目標端口範圍"),
    "ruleActionGeoipDesc": MessageLookupByLibrary.simpleMessage("匹配 IP 所屬國家代碼"),
    "ruleActionGeositeDesc": MessageLookupByLibrary.simpleMessage(
      "匹配 Geosite 內的域名",
    ),
    "ruleActionInNameDesc": MessageLookupByLibrary.simpleMessage("匹配入站名稱"),
    "ruleActionInPortDesc": MessageLookupByLibrary.simpleMessage("匹配入站端口"),
    "ruleActionInTypeDesc": MessageLookupByLibrary.simpleMessage("匹配入站類型"),
    "ruleActionInUserDesc": MessageLookupByLibrary.simpleMessage(
      "匹配入站用戶名，支持使用 / 分隔多個用戶名",
    ),
    "ruleActionIpAsnDesc": MessageLookupByLibrary.simpleMessage("匹配 IP 所屬 ASN"),
    "ruleActionIpCidr6Desc": MessageLookupByLibrary.simpleMessage(
      "匹配 IP 地址範圍，IP-CIDR6 只是一個別名",
    ),
    "ruleActionIpCidrDesc": MessageLookupByLibrary.simpleMessage("匹配 IP 地址範圍"),
    "ruleActionIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "匹配 IP 後綴範圍",
    ),
    "ruleActionMatchDesc": MessageLookupByLibrary.simpleMessage("匹配所有請求，無需條件"),
    "ruleActionNetworkDesc": MessageLookupByLibrary.simpleMessage("匹配TCP或者UDP"),
    "ruleActionNotDesc": MessageLookupByLibrary.simpleMessage("邏輯規則 NOT"),
    "ruleActionOrDesc": MessageLookupByLibrary.simpleMessage("邏輯規則 OR"),
    "ruleActionProcessNameDesc": MessageLookupByLibrary.simpleMessage(
      "使用進程匹配，在Android平臺可以匹配包名",
    ),
    "ruleActionProcessNameRegexDesc": MessageLookupByLibrary.simpleMessage(
      "使用進程名稱正則表達式匹配，在Android平臺可以匹配包名",
    ),
    "ruleActionProcessNameWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "使用進程名稱通配符匹配，僅支持*和?通配符",
    ),
    "ruleActionProcessPathDesc": MessageLookupByLibrary.simpleMessage(
      "使用完整進程路徑匹配",
    ),
    "ruleActionProcessPathRegexDesc": MessageLookupByLibrary.simpleMessage(
      "使用進程路徑正則表達式匹配",
    ),
    "ruleActionProcessPathWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "使用進程路徑通配符匹配，僅支持*和?通配符",
    ),
    "ruleActionRematchNameDesc": MessageLookupByLibrary.simpleMessage(
      "匹配重匹配名稱，多個名稱用/分隔",
    ),
    "ruleActionRuleSetDesc": MessageLookupByLibrary.simpleMessage(
      "引用規則集合，需配置rule-providers",
    ),
    "ruleActionSrcGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "匹配來源 IP 所屬國家代碼",
    ),
    "ruleActionSrcIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "匹配來源 IP 所屬 ASN",
    ),
    "ruleActionSrcIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "匹配來源 IP 地址範圍",
    ),
    "ruleActionSrcIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "匹配來源 IP 後綴範圍",
    ),
    "ruleActionSrcPortDesc": MessageLookupByLibrary.simpleMessage("匹配請求來源端口範圍"),
    "ruleActionSubRuleDesc": MessageLookupByLibrary.simpleMessage(
      "匹配至子規則，需要注意括號的使用",
    ),
    "ruleActionUidDesc": MessageLookupByLibrary.simpleMessage(
      "匹配 Linux USER ID",
    ),
    "ruleEmpty": MessageLookupByLibrary.simpleMessage("規則爲空"),
    "ruleListInvalid": MessageLookupByLibrary.simpleMessage(
      "規則必須是 YAML 列表，每項一條規則，例如 - DOMAIN,example.com,DIRECT",
    ),
    "rulePresetBittorrentDirect": MessageLookupByLibrary.simpleMessage(
      "BT 下載直連",
    ),
    "rulePresetBlockDot": MessageLookupByLibrary.simpleMessage(
      "屏蔽 DNS over TLS",
    ),
    "rulePresetBlockLoopback": MessageLookupByLibrary.simpleMessage("防止代理迴環"),
    "rulePresetBlockQuic": MessageLookupByLibrary.simpleMessage("屏蔽 QUIC"),
    "rulePresetBlockStun": MessageLookupByLibrary.simpleMessage("屏蔽 STUN"),
    "rulePresetLanDirect": MessageLookupByLibrary.simpleMessage("局域網直連"),
    "rulePresetSystemServicesDirect": MessageLookupByLibrary.simpleMessage(
      "Apple 與 Microsoft 直連",
    ),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("規則集"),
    "ruleSet": MessageLookupByLibrary.simpleMessage("規則集"),
    "ruleSetEmptyTip": MessageLookupByLibrary.simpleMessage("規則集中沒有可用的條目"),
    "ruleSetInvalidTip": MessageLookupByLibrary.simpleMessage("無法讀取該 mrs 文件"),
    "ruleSetMixedTip": MessageLookupByLibrary.simpleMessage(
      "規則集同時包含域名和 IP 段，無法判斷類型",
    ),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("規則目標"),
    "ruleTextInvalid": MessageLookupByLibrary.simpleMessage(
      "規則必須以受支持的類型開頭，例如 DOMAIN,example.com,DIRECT",
    ),
    "rules": MessageLookupByLibrary.simpleMessage("規則"),
    "rulesCount": m72,
    "runTime": MessageLookupByLibrary.simpleMessage("運行時長"),
    "running": MessageLookupByLibrary.simpleMessage("運行中"),
    "runtimeConfig": MessageLookupByLibrary.simpleMessage("運行時配置"),
    "safeMode": MessageLookupByLibrary.simpleMessage("安全模式"),
    "safeModeAppTitle": m73,
    "saturation": MessageLookupByLibrary.simpleMessage("飽和度"),
    "save": MessageLookupByLibrary.simpleMessage("保存"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("是否保存更改？"),
    "script": MessageLookupByLibrary.simpleMessage("腳本"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage("腳本模式，使用擴展腳本改寫整個配置"),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage("滾動到已選"),
    "search": MessageLookupByLibrary.simpleMessage("搜索"),
    "seconds": MessageLookupByLibrary.simpleMessage("秒"),
    "secondsCount": m74,
    "secretKey": MessageLookupByLibrary.simpleMessage("密鑰"),
    "sectionsInEffect": m75,
    "select": MessageLookupByLibrary.simpleMessage("選中"),
    "selectAll": MessageLookupByLibrary.simpleMessage("全選"),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage("請選擇規則集"),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage("請選擇分流策略"),
    "send": MessageLookupByLibrary.simpleMessage("發送"),
    "sendFromPhone": MessageLookupByLibrary.simpleMessage("從手機發送"),
    "sendFromPhoneConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "導入手機發來的鏈接？",
    ),
    "sendFromPhoneNoNetwork": MessageLookupByLibrary.simpleMessage(
      "這臺設備沒有連接局域網",
    ),
    "sendFromPhonePageHint": MessageLookupByLibrary.simpleMessage(
      "訂閱鏈接或代理分享鏈接",
    ),
    "sendFromPhonePageSent": MessageLookupByLibrary.simpleMessage(
      "已發送，請在另一臺設備上確認導入。",
    ),
    "sendFromPhonePageTitle": MessageLookupByLibrary.simpleMessage(
      "把鏈接發送到 FlClash",
    ),
    "sendFromPhonePermissionDenied": MessageLookupByLibrary.simpleMessage(
      "從手機接收鏈接需要「附近的設備」權限，FlClash 才能訪問局域網。請在應用設置中開啓。",
    ),
    "sendFromPhoneTip": MessageLookupByLibrary.simpleMessage(
      "用手機相機掃描二維碼，在打開的頁面裏粘貼鏈接。兩臺設備需要連在同一個網絡。",
    ),
    "server": MessageLookupByLibrary.simpleMessage("服務器"),
    "serviceAbnormalCount": m76,
    "serviceAllAvailable": MessageLookupByLibrary.simpleMessage("全部可用"),
    "serviceAvailable": MessageLookupByLibrary.simpleMessage("可用"),
    "serviceBlocked": MessageLookupByLibrary.simpleMessage("已被封禁"),
    "serviceCheckAll": MessageLookupByLibrary.simpleMessage("全部檢測"),
    "serviceComingSoon": MessageLookupByLibrary.simpleMessage("即將上線"),
    "serviceDisallowedIsp": MessageLookupByLibrary.simpleMessage("不允許的 ISP"),
    "serviceFailed": MessageLookupByLibrary.simpleMessage("檢測失敗"),
    "serviceManage": MessageLookupByLibrary.simpleMessage("管理服務"),
    "serviceOriginalsOnly": MessageLookupByLibrary.simpleMessage("僅限自制內容"),
    "servicePending": MessageLookupByLibrary.simpleMessage("待檢測"),
    "serviceRestricted": MessageLookupByLibrary.simpleMessage("訪問受限"),
    "serviceShownOnDashboard": MessageLookupByLibrary.simpleMessage("顯示在儀表盤"),
    "serviceStatus": MessageLookupByLibrary.simpleMessage("服務狀態"),
    "serviceUnavailable": MessageLookupByLibrary.simpleMessage("不可用"),
    "serviceUnsupportedRegion": MessageLookupByLibrary.simpleMessage("地區不支持"),
    "settingEntries": MessageLookupByLibrary.simpleMessage("設置項"),
    "settings": MessageLookupByLibrary.simpleMessage("設置"),
    "settingsCount": m77,
    "shareLinkUnreadable": m78,
    "shareLinksInvalid": MessageLookupByLibrary.simpleMessage("無法從鏈接中讀取代理"),
    "shareQrcodeTip": MessageLookupByLibrary.simpleMessage(
      "在另一臺設備上用 FlClash 掃碼即可導入此配置。",
    ),
    "show": MessageLookupByLibrary.simpleMessage("顯示"),
    "showLess": MessageLookupByLibrary.simpleMessage("收起"),
    "showMore": MessageLookupByLibrary.simpleMessage("展開"),
    "showNotificationStopAction": MessageLookupByLibrary.simpleMessage(
      "通知欄顯示停止按鈕",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage("顯示密碼"),
    "sidebar": MessageLookupByLibrary.simpleMessage("側邊欄"),
    "sidebarBlurDesc": MessageLookupByLibrary.simpleMessage(
      "背景模糊會讓側邊欄透出窗口後方的桌面。",
    ),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("靜默啓動"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage("靜默啓動時不顯示窗口。"),
    "singleAdd": MessageLookupByLibrary.simpleMessage("單條添加"),
    "singleImport": MessageLookupByLibrary.simpleMessage("單條導入"),
    "singleShareLinkOnly": MessageLookupByLibrary.simpleMessage(
      "這裏只能填寫一條鏈接，多條請在列表的快速編輯中填寫",
    ),
    "singleValueTip": m79,
    "size": MessageLookupByLibrary.simpleMessage("尺寸"),
    "skipCertVerify": MessageLookupByLibrary.simpleMessage("跳過證書驗證"),
    "skipDomain": MessageLookupByLibrary.simpleMessage("跳過域名"),
    "skipDomainDesc": MessageLookupByLibrary.simpleMessage("嗅探到跳過域名中的域名時不予採用。"),
    "skipDstAddress": MessageLookupByLibrary.simpleMessage("跳過目標地址"),
    "skipSrcAddress": MessageLookupByLibrary.simpleMessage("跳過來源地址"),
    "slide": MessageLookupByLibrary.simpleMessage("滑動"),
    "sliders": MessageLookupByLibrary.simpleMessage("滑塊"),
    "sniffProtocols": MessageLookupByLibrary.simpleMessage("協議"),
    "sniffer": MessageLookupByLibrary.simpleMessage("域名嗅探"),
    "snifferStatusDesc": MessageLookupByLibrary.simpleMessage(
      "域名嗅探從 TLS、HTTP、QUIC 流量中識別域名，供規則匹配。",
    ),
    "socksPort": MessageLookupByLibrary.simpleMessage("Socks端口"),
    "softStyle": MessageLookupByLibrary.simpleMessage("柔和"),
    "sort": MessageLookupByLibrary.simpleMessage("排序"),
    "source": MessageLookupByLibrary.simpleMessage("來源"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("源IP"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("特殊代理"),
    "specialRules": MessageLookupByLibrary.simpleMessage("特殊規則"),
    "spectrum": MessageLookupByLibrary.simpleMessage("光譜"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage("網速統計"),
    "splitStrategy": MessageLookupByLibrary.simpleMessage("分流策略"),
    "splitStrategyNotEmpty": MessageLookupByLibrary.simpleMessage("分流策略不能爲空"),
    "ssidsEmpty": MessageLookupByLibrary.simpleMessage("SSIDs爲空"),
    "stackMode": MessageLookupByLibrary.simpleMessage("棧模式"),
    "stackTrace": MessageLookupByLibrary.simpleMessage("堆棧信息"),
    "standard": MessageLookupByLibrary.simpleMessage("標準"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "標準模式，在配置的基礎上附加規則",
    ),
    "start": MessageLookupByLibrary.simpleMessage("啓動"),
    "startFromScratch": MessageLookupByLibrary.simpleMessage("從零開始"),
    "startVpn": MessageLookupByLibrary.simpleMessage("正在啓動VPN…"),
    "startupAndBackground": MessageLookupByLibrary.simpleMessage("啓動與後臺"),
    "status": MessageLookupByLibrary.simpleMessage("狀態"),
    "statusDesc": MessageLookupByLibrary.simpleMessage("關閉 DNS 後將使用系統 DNS。"),
    "stop": MessageLookupByLibrary.simpleMessage("暫停"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("正在停止VPN…"),
    "strategy": MessageLookupByLibrary.simpleMessage("策略"),
    "strictRoute": MessageLookupByLibrary.simpleMessage("嚴格路由"),
    "strictRouteDesc": MessageLookupByLibrary.simpleMessage(
      "嚴格路由防止 DNS 等流量繞過虛擬網卡，關閉 IPv6 時會阻斷本機的 IPv6 連接。",
    ),
    "style": MessageLookupByLibrary.simpleMessage("風格"),
    "submit": MessageLookupByLibrary.simpleMessage("提交"),
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage("訂閱信息"),
    "sudoPasswordTitle": MessageLookupByLibrary.simpleMessage("輸入 sudo 密碼"),
    "suspended": MessageLookupByLibrary.simpleMessage("掛起中…"),
    "switchProfile": MessageLookupByLibrary.simpleMessage("切換配置"),
    "sync": MessageLookupByLibrary.simpleMessage("同步"),
    "system": MessageLookupByLibrary.simpleMessage("系統"),
    "systemApp": MessageLookupByLibrary.simpleMessage("系統應用"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("系統代理"),
    "tab": MessageLookupByLibrary.simpleMessage("標籤頁"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("選項卡動畫"),
    "tapIconToRetry": MessageLookupByLibrary.simpleMessage("點擊圖標重試"),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage("點擊授權"),
    "target": MessageLookupByLibrary.simpleMessage("目標"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP併發"),
    "testInterval": MessageLookupByLibrary.simpleMessage("測試間隔"),
    "testUrl": MessageLookupByLibrary.simpleMessage("測速鏈接"),
    "testWhenUsed": MessageLookupByLibrary.simpleMessage("使用時測試"),
    "textScale": MessageLookupByLibrary.simpleMessage("文本縮放"),
    "textScalePreview": MessageLookupByLibrary.simpleMessage("應用內的文字將以這個大小顯示"),
    "theme": MessageLookupByLibrary.simpleMessage("主題"),
    "themeColor": MessageLookupByLibrary.simpleMessage("主題色彩"),
    "themeMode": MessageLookupByLibrary.simpleMessage("主題模式"),
    "tight": MessageLookupByLibrary.simpleMessage("緊湊"),
    "time": MessageLookupByLibrary.simpleMessage("時間"),
    "timeout": MessageLookupByLibrary.simpleMessage("超時"),
    "tintedStyle": MessageLookupByLibrary.simpleMessage("氛圍"),
    "tip": MessageLookupByLibrary.simpleMessage("提示"),
    "toggle": MessageLookupByLibrary.simpleMessage("切換"),
    "tolerance": MessageLookupByLibrary.simpleMessage("容差"),
    "tools": MessageLookupByLibrary.simpleMessage("工具"),
    "torch": MessageLookupByLibrary.simpleMessage("手電筒"),
    "total": MessageLookupByLibrary.simpleMessage("總計"),
    "totalDownload": MessageLookupByLibrary.simpleMessage("下載總量"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("總流量"),
    "totalUpload": MessageLookupByLibrary.simpleMessage("上傳總量"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("Tproxy端口"),
    "traffic": MessageLookupByLibrary.simpleMessage("流量"),
    "trafficPeak": m80,
    "trafficTotal": m81,
    "trafficUsage": MessageLookupByLibrary.simpleMessage("流量統計"),
    "transport": MessageLookupByLibrary.simpleMessage("傳輸協議"),
    "transportHeaders": m82,
    "tun": MessageLookupByLibrary.simpleMessage("虛擬網卡"),
    "tunAuthorizationFailed": MessageLookupByLibrary.simpleMessage(
      "虛擬網卡授權失敗，已關閉。",
    ),
    "tunDesc": MessageLookupByLibrary.simpleMessage("虛擬網卡僅在管理員模式生效。"),
    "tunOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "添加的項會覆寫所有配置的虛擬網卡設置，未添加的項沿用配置自身的設置。自定義配置自己添加的項優先。",
    ),
    "turnOff": MessageLookupByLibrary.simpleMessage("關閉"),
    "turnOn": MessageLookupByLibrary.simpleMessage("開啓"),
    "udpRelayMode": MessageLookupByLibrary.simpleMessage("UDP 中繼模式"),
    "udpTimeout": MessageLookupByLibrary.simpleMessage("UDP 超時"),
    "udpTimeoutDesc": MessageLookupByLibrary.simpleMessage(
      "UDP 超時以秒爲單位，僅在 gvisor、system 和 mixed 棧生效。",
    ),
    "ultra": MessageLookupByLibrary.simpleMessage("極致"),
    "undo": MessageLookupByLibrary.simpleMessage("撤銷"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("統一延遲"),
    "unknown": MessageLookupByLibrary.simpleMessage("未知"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage("未知網絡錯誤"),
    "unmaximize": MessageLookupByLibrary.simpleMessage("向下還原"),
    "unnamed": MessageLookupByLibrary.simpleMessage("未命名"),
    "unpinWindow": MessageLookupByLibrary.simpleMessage("取消置頂"),
    "update": MessageLookupByLibrary.simpleMessage("更新"),
    "upload": MessageLookupByLibrary.simpleMessage("上傳"),
    "uploadBandwidth": MessageLookupByLibrary.simpleMessage("上行帶寬"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlTip": m83,
    "useHosts": MessageLookupByLibrary.simpleMessage("使用Hosts"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("使用系統Hosts"),
    "usedShort": MessageLookupByLibrary.simpleMessage("已用"),
    "usedTraffic": MessageLookupByLibrary.simpleMessage("已用流量"),
    "userAgent": MessageLookupByLibrary.simpleMessage("用戶代理"),
    "username": MessageLookupByLibrary.simpleMessage("用戶名"),
    "value": MessageLookupByLibrary.simpleMessage("值"),
    "view": MessageLookupByLibrary.simpleMessage("查看"),
    "virtualIpv4": MessageLookupByLibrary.simpleMessage("虛擬 IPv4"),
    "vividStyle": MessageLookupByLibrary.simpleMessage("鮮明"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "檢測到VPN相關配置改動",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "VPN 通過 VpnService 自動路由系統所有流量。",
    ),
    "secondaryDevelopmentBuild": MessageLookupByLibrary.simpleMessage("二次開發構建"),
    "wakelock": MessageLookupByLibrary.simpleMessage("亮屏鎖"),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage("WebDAV配置"),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("白名單模式"),
    "writeToSystem": MessageLookupByLibrary.simpleMessage("寫入系統"),
    "writeToSystemDesc": MessageLookupByLibrary.simpleMessage(
      "寫入系統會同時設置系統時鐘，Android 上不生效。",
    ),
    "yearsAgo": m84,
    "yearsAgoShort": m85,
    "yes": MessageLookupByLibrary.simpleMessage("是"),
    "zhHant": MessageLookupByLibrary.simpleMessage("繁體中文"),
        "zhCN": MessageLookupByLibrary.simpleMessage("中文簡體"),
  };
}
