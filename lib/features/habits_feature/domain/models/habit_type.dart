enum HabitType {
  boolean, // Simple yes/no checkbox
  counter, // Track quantity with numbers
}

extension HabitTypeExtension on HabitType {
  String get name {
    switch (this) {
      case HabitType.boolean:
        return 'boolean';
      case HabitType.counter:
        return 'counter';
    }
  }

  static HabitType fromString(String value) {
    switch (value) {
      case 'counter':
        return HabitType.counter;
      case 'boolean':
      default:
        return HabitType.boolean;
    }
  }
}
