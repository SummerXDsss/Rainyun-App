class RainyunUser {
  final int uid;
  final String name;
  final String? avatar;
  final String email;
  final String? phone;
  final double balance;
  final String? companyName;
  final int verified;
  final String? realName;

  RainyunUser({
    required this.uid,
    required this.name,
    this.avatar,
    required this.email,
    this.phone,
    required this.balance,
    this.companyName,
    required this.verified,
    this.realName,
  });

  factory RainyunUser.fromJson(Map<String, dynamic> json) {
    return RainyunUser(
      uid: json['UID'] as int,
      name: json['Name'] as String,
      avatar: json['Avatar'] as String?,
      email: json['Email'] as String,
      phone: json['Phone'] as String?,
      balance: (json['Balance'] as num?)?.toDouble() ?? 0.0,
      companyName: json['CompanyName'] as String?,
      verified: json['Verified'] as int? ?? 0,
      realName: json['RealName'] as String?,
    );
  }

  String get displayName => name.isNotEmpty ? name : 'UID: $uid';
  
  String get avatarUrl => avatar != null && avatar!.isNotEmpty 
      ? 'https://api.v2.rainyun.com$avatar' 
      : '';
  
  bool get isVerified => verified == 1;
}
