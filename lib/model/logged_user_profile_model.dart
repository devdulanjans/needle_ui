class LoggedUserProfile {
  final int id;
  final String displayName;
  final String email;
  final String bio;
  final String profilePicture;
  final String coverImage;
  final String mobileNo;

  LoggedUserProfile({
    required this.id,
    required this.displayName,
    required this.email,
    required this.bio,
    required this.profilePicture,
    required this.coverImage,
    required this.mobileNo,
  });

  // Factory method to create a UserProfile from a JSON object
  factory LoggedUserProfile.fromJson(Map<String, dynamic> json) {
    return LoggedUserProfile(
      id: json['id'] ?? 0,
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      coverImage: json['coverImage'] ?? '',
      mobileNo: json['mobileNo'] ?? '',
    );
  }

  // Method to convert a UserProfile to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'bio': bio,
      'profilePicture': profilePicture,
      'coverImage': coverImage,
      'mobileNo': mobileNo,
    };
  }
}