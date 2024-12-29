class UserPreferences {
  bool isDarkMode;
  String defaultSortOrder;

  UserPreferences({
    required this.isDarkMode,
    required this.defaultSortOrder,
  });

  Map<String, dynamic> toMap() {
    return {
      'isDarkMode': isDarkMode,
      'defaultSortOrder': defaultSortOrder,
    };
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      isDarkMode: map['isDarkMode'],
      defaultSortOrder: map['defaultSortOrder'],
    );
  }
}
