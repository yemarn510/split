import 'dart:math';
import 'package:uuid/uuid.dart';

/// Same URL the web app stores in `friend.profile`.
const String avatarUrlBase =
    'https://api.dicebear.com/7.x/miniavs/svg?size=200&hair=classic01,curly,long,ponyTail&seed=';

final Random _random = Random();

/// Uniform integer in [min, max], like `generateRandomInteger` in person.models.ts.
int generateRandomInteger(int min, int max) {
  return min + _random.nextInt(max - min + 1);
}

/// Flutter cannot decode SVG through `Image.network`, so dicebear avatars are
/// displayed through the identical PNG endpoint.
String displayProfileUrl(String url) {
  return url.replaceFirst('/7.x/miniavs/svg?', '/7.x/miniavs/png?');
}

/// Mirrors frontend/src/models/person.models.ts.
class Person {
  int? id;
  String uuid;
  String name;
  String profile;
  bool selected;

  Person({
    this.id,
    this.name = '',
    String profile = '',
    this.selected = false,
  })  : uuid = const Uuid().v4(),
        profile = profile.isNotEmpty
            ? profile
            : '$avatarUrlBase${generateRandomInteger(1, 400)}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'uuid': uuid,
        'profile': profile,
        'selected': selected,
      };

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: (json['id'] as num?)?.toInt(),
      name: (json['name'] as String?) ?? '',
      profile: (json['profile'] as String?) ?? '',
      selected: (json['selected'] as bool?) ?? false,
    );
  }
}
