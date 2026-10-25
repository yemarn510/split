import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/person.dart';

class FriendsService {
  FriendsService(this._client);

  final SupabaseClient _client;

  Future<List<Person>> fetchFriends() async {
    final data = await _client.from('friend').select();
    final list = (data as List)
        .map((row) {
          final map = Map<String, dynamic>.from(row as Map);
          return Person(
            id: (map['id'] as num?)?.toInt(),
            name: (map['name'] as String?) ?? '',
            profile: (map['profile'] as String?) ?? '',
          );
        })
        .toList();
    if (list.isEmpty) return [Person()];
    return list;
  }

  /// Mirrors frontend `createOrUpdateFriends`.
  Future<void> createOrUpdateFriends(List<Person> people) async {
    final peopleToCreate = people
        .where((p) => p.id == null)
        .map((p) => {'name': p.name, 'profile': p.profile})
        .toList();

    final peopleToUpdate = people.where((p) => p.id != null).toList();

    final existing = await _client.from('friend').select('id');
    final toDelete = <int>{
      for (final row in (existing as List))
        if (row['id'] != null) (row['id'] as num).toInt(),
    };

    if (peopleToCreate.isNotEmpty) {
      await _client.from('friend').insert(peopleToCreate).select();
    }

    for (final friend in peopleToUpdate) {
      await _client
          .from('friend')
          .update({'name': friend.name, 'profile': friend.profile})
          .eq('id', friend.id!)
          .select();
      toDelete.remove(friend.id);
    }

    if (toDelete.isNotEmpty) {
      await _client.from('friend').delete().inFilter('id', toDelete.toList());
    }
  }
}
