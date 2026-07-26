import 'dart:math';
import 'package:uuid/uuid.dart';

const String avatarUrlBase =
    'https://api.dicebear.com/7.x/miniavs/png?size=200&hair=classic01,curly,long,ponyTail&seed=';

int generateRandomInteger(int min, int max) {
  return min + Random().nextInt(max - min + 1);
}

class Person {
  int? id;
  late String uuid;
  String name;
  late String profile;
  bool selected;

  Person({
    this.id,
    this.name = '',
    String? profile,
    this.selected = false,
    String? uuid,
  }) {
    this.uuid = uuid ?? Uuid().v4();
    this.profile = profile ?? '$avatarUrlBase${generateRandomInteger(1, 400)}';
  }

  Person copyWith({
    int? id,
    String? name,
    String? profile,
    bool? selected,
    String? uuid,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      profile: profile ?? this.profile,
      selected: selected ?? this.selected,
      uuid: uuid ?? this.uuid,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'profile': profile,
        'selected': selected,
      };

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as int?,
      name: (json['name'] as String?) ?? '',
      profile: json['profile'] as String?,
      selected: (json['selected'] as bool?) ?? false,
      uuid: json['uuid'] as String?,
    );
  }
}
