
enum AppRole {

  teacher,

  student;

  static AppRole fromBackendRole(String? backendRole) {
    switch (backendRole) {
      case 'ADMIN':
        return AppRole.teacher;
      case 'USER':
      default:
        return AppRole.student;
    }
  }

  String get backendRole => switch (this) {
        AppRole.teacher => 'ADMIN',
        AppRole.student => 'USER',
      };

  String get label => switch (this) {
        AppRole.teacher => 'Teacher',
        AppRole.student => 'Student',
      };
}
