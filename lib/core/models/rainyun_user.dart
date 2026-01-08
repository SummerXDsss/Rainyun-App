class RainyunUser {
  final int uid;
  final String name;
  final String? avatar;
  final String email;
  final String? phone;
  final double balance;
  final int points;
  final int vipLevel;
  final String? shareCode;
  final int verified;
  final String? certifyStatus;
  final double totalSale;    // 累计消费
  final double totalResell;  // 累计推广

  RainyunUser({
    required this.uid,
    required this.name,
    this.avatar,
    required this.email,
    this.phone,
    required this.balance,
    this.points = 0,
    this.vipLevel = 0,
    this.shareCode,
    required this.verified,
    this.certifyStatus,
    this.totalSale = 0,
    this.totalResell = 0,
  });

  factory RainyunUser.fromJson(Map<String, dynamic> json) {
    return RainyunUser(
      uid: json['ID'] as int? ?? 0,
      name: json['Name'] as String? ?? '',
      avatar: json['IconUrl'] as String?,
      email: json['Email'] as String? ?? '',
      phone: json['Phone'] as String?,
      balance: (json['Money'] as num?)?.toDouble() ?? 0.0,
      points: json['Points'] as int? ?? 0,
      vipLevel: json['VipLevel'] as int? ?? 0,
      shareCode: json['ShareCode'] as String?,
      verified: json['Certify'] as int? ?? 0,
      certifyStatus: json['CertifyStatus'] as String?,
      totalSale: (json['TotalSale'] as num?)?.toDouble() ?? 0.0,
      totalResell: (json['TotalResell'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get displayName => name.isNotEmpty ? name : 'UID: $uid';
  
  String get avatarUrl => avatar != null && avatar!.isNotEmpty 
      ? (avatar!.startsWith('http') ? avatar! : 'https://cn-sy1.rains3.com$avatar')
      : '';
  
  bool get isVerified => verified == 1 || certifyStatus == 'passed';
  
  String get vipTitle {
    switch (vipLevel) {
      case 1: return 'Ⅰ级会员';
      case 2: return 'Ⅱ级会员';
      case 3: return 'Ⅲ级会员';
      case 4: return 'Ⅳ级会员';
      case 5: return 'Ⅴ级会员';
      default: return '普通用户';
    }
  }
}
