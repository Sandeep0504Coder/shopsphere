class Region {
  final String id;
  final String countryName;
  final String countryAbbreviation;
  final List<States>? states; 

  Region({
    required this.id,
    required this.countryName,
    required this.countryAbbreviation,
    required this.states,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['_id'],
      countryName: json['countryName'],
      countryAbbreviation: json['countryAbbreviation'],
      states: json['states'] != null
        ? List<States>.from(
            (json['states'] as List).map((state) => States.fromJson(state)))
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'countryName': countryName,
      'countryAbbreviation': countryAbbreviation,
    };
  }
}

class States {
  final String id;
  final String stateName;
  final String stateAbbreviation;

  States({
    required this.id,
    required this.stateName,
    required this.stateAbbreviation,
  });

  factory States.fromJson(Map<String, dynamic> json) {
    return States(
      id: json['_id'],
      stateName: json['stateName'],
      stateAbbreviation: json['stateAbbreviation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'stateName': stateName,
      'stateAbbreviation': stateAbbreviation,
    };
  }
}


