class Configuration {
  final String key;
  final String value;

  Configuration({required this.key, required this.value});

  factory Configuration.fromMap(Map<String, dynamic> map) {
    return Configuration(
      key: map['key'] ?? '',
      value: map['value'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'value': value,
    };
  }
}
