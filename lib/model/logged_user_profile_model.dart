// class LoggedUserProfile {
//   final int id;
//   final String displayName;
//   final String email;
//   final String bio;
//   final String profilePicture;
//   final String coverImage;
//   final String mobileNo;
//
//   LoggedUserProfile({
//     required this.id,
//     required this.displayName,
//     required this.email,
//     required this.bio,
//     required this.profilePicture,
//     required this.coverImage,
//     required this.mobileNo,
//   });
//
//   // Factory method to create a UserProfile from a JSON object
//   factory LoggedUserProfile.fromJson(Map<String, dynamic> json) {
//     return LoggedUserProfile(
//       id: json['id'] ?? 0,
//       displayName: json['displayName'] ?? '',
//       email: json['email'] ?? '',
//       bio: json['bio'] ?? '',
//       profilePicture: json['profilePicture'] ?? '',
//       coverImage: json['coverImage'] ?? '',
//       mobileNo: json['mobileNo'] ?? '',
//     );
//   }
//
//   // Method to convert a UserProfile to a JSON object
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'displayName': displayName,
//       'email': email,
//       'bio': bio,
//       'profilePicture': profilePicture,
//       'coverImage': coverImage,
//       'mobileNo': mobileNo,
//     };
//   }
//
//   @override
//   String toString() {
//     return 'LoggedUserProfile{id: $id, displayName: $displayName, email: $email, bio: $bio, profilePicture: $profilePicture, coverImage: $coverImage, mobileNo: $mobileNo}';
//   }
// }

class LoggedUserProfile {
  final int id;
  final String displayName;
  final String email;
  final String bio;
  final String profilePicture;
  final String coverImage;
  final String mobileNo;
  final String firstName;
  final String lastName;
  final String dob;
  final String gender;
  final String religion;
  final List<String>? languages;
  final Map<String, dynamic>? address;
  final String website;
  final Map<String, dynamic>? socialLinks;
  final List<String>? skills;
  final List<Map<String, dynamic>>? professionalProjects;
  final List<Map<String, dynamic>>? volunteerWork;
  final List<Map<String, dynamic>>? placesLived;
  final List<Map<String, dynamic>>? schools;
  final List<Map<String, dynamic>>? colleges;
  final List<Map<String, dynamic>>? works;
  final List<String>? interestedIn;
  final bool isProfileLocked;
  late final bool isFriend;
  final bool isRequestSend;
  final bool isRequestReceived;
  final int friendRequestId;
  final String type;
  final bool isFollowing;

  LoggedUserProfile({
    required this.id,
    required this.displayName,
    required this.email,
    required this.bio,
    required this.profilePicture,
    required this.coverImage,
    required this.mobileNo,
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.gender,
    required this.religion,
    this.languages,
    this.address,
    required this.website,
    this.socialLinks,
    this.skills,
    this.professionalProjects,
    this.volunteerWork,
    this.placesLived,
    this.schools,
    this.colleges,
    this.works,
    this.interestedIn,
    required this.isProfileLocked,
    required this.isFriend,
    required this.isRequestSend,
    required this.isRequestReceived,
    required this.friendRequestId,
    required this.type,
    required this.isFollowing
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
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      dob: json['dob'] ?? '',
      gender: json['gender'] ?? '',
      religion: json['religion'] ?? '',
      languages: (json['languages'] as List?)?.map((e) => e.toString()).toList(),
      address: json['address'] as Map<String, dynamic>?,
      website: json['website'] ?? '',
      socialLinks: json['socialLinks'] as Map<String, dynamic>?,
      skills: (json['skills'] as List?)?.map((e) => e.toString()).toList(),
      professionalProjects: (json['professionalProjects'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      volunteerWork: (json['volunteerWork'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      placesLived: (json['placesLived'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      schools: (json['schools'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      colleges: (json['colleges'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      works: (json['works'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      interestedIn: (json['interestedIn'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      isProfileLocked: json['isProfileLocked'] ?? false,
      isFriend: json['isFriend'] ?? false,
      isRequestSend: json['isRequestSend'] ?? false,
      isRequestReceived: json['isRequestReceived'] ?? false,
      friendRequestId: json['friendRequestId'] ?? 0, // Default to 0 if null
      type: json['type'] ?? '',
      isFollowing: json['isFollowing'] ?? false
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
      'firstName': firstName,
      'lastName': lastName,
      'dob': dob,
      'gender': gender,
      'religion': religion,
      'languages': languages,
      'address': address,
      'website': website,
      'socialLinks': socialLinks,
      'skills': skills,
      'professionalProjects': professionalProjects,
      'volunteerWork': volunteerWork,
      'placesLived': placesLived,
      'schools': schools,
      'colleges': colleges,
      'works': works,
      'interestedIn': interestedIn,
      'isProfileLocked': isProfileLocked,
      'isFriend': isFriend,
      'isRequestSend': isRequestSend,
      'isRequestReceived': isRequestReceived,
      'friendRequestId': friendRequestId,
      'type': type,
      'isFollowing': isFollowing
    };
  }

  @override
  String toString() {
    return 'LoggedUserProfile{id: $id, displayName: $displayName, email: $email, bio: $bio, profilePicture: $profilePicture, coverImage: $coverImage, mobileNo: $mobileNo, firstName: $firstName, lastName: $lastName, dob: $dob, gender: $gender, religion: $religion, languages: $languages, address: $address, website: $website, socialLinks: $socialLinks, skills: $skills, professionalProjects: $professionalProjects, volunteerWork: $volunteerWork, placesLived: $placesLived, schools: $schools, colleges: $colleges, works: $works, interestedIn: $interestedIn, isProfileLocked: $isProfileLocked, isFriend: $isFriend, isRequestSend: $isRequestSend, isRequestReceived: $isRequestReceived, friendRequestId: $friendRequestId, type: $type, isFollowing: $isFollowing}';
  }
}