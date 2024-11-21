class Profile {
  final String username;
  final String? photoURL;
  final String profileImageUrl;
  final int posts;
  final int followers;
  final int following;
  final String fullName;
  final String bio;
  final List<String> postImages;

  Profile({
    required this.username,
    this.photoURL,
    required this.profileImageUrl,
    required this.posts,
    required this.followers,
    required this.following,
    required this.fullName,
    required this.bio,
    required this.postImages,
  });
} 