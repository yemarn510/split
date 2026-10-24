import 'package:flutter/material.dart';
import '../models/person.dart';
import '../theme/app_colors.dart';
import '../widgets/rounded_avatar.dart';

class StepOnePeople extends StatefulWidget {
  final List<Person> people;
  final ValueChanged<List<Person>> onPeopleChanged;
  final bool saveFriends;
  final ValueChanged<bool> onSaveFriendsChanged;

  const StepOnePeople({
    super.key,
    required this.people,
    required this.onPeopleChanged,
    required this.saveFriends,
    required this.onSaveFriendsChanged,
  });

  @override
  State<StepOnePeople> createState() => _StepOnePeopleState();
}

class _StepOnePeopleState extends State<StepOnePeople> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  @override
  void didUpdateWidget(covariant StepOnePeople oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.people.length != widget.people.length) {
      _disposeControllers();
      _syncControllers();
    }
  }

  void _syncControllers() {
    _controllers =
        widget.people.map((p) => TextEditingController(text: p.name)).toList();
  }

  void _disposeControllers() {
    for (final c in _controllers) {
      c.dispose();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _addPerson() {
    final updated = List<Person>.from(widget.people)..add(Person());
    widget.onPeopleChanged(updated);
    widget.onSaveFriendsChanged(false);
  }

  void _deletePerson(int index) {
    final updated = List<Person>.from(widget.people)..removeAt(index);
    widget.onPeopleChanged(updated);
    widget.onSaveFriendsChanged(false);
  }

  void _toggleSelect(int index) {
    final updated = List<Person>.from(widget.people);
    updated[index] =
        updated[index].copyWith(selected: !updated[index].selected);
    widget.onPeopleChanged(updated);
  }

  Future<void> _pickAvatar(int index) async {
    final seeds = List.generate(52, (_) => generateRandomInteger(1, 1000));
    String? selected;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return AlertDialog(
              title: const Text('Choose your Avatar'),
              content: SizedBox(
                width: double.maxFinite,
                height: 320,
                child: Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                        itemCount: seeds.length,
                        itemBuilder: (_, i) {
                          final url = '$avatarUrlBase${seeds[i]}';
                          return PersonAvatarOnly(
                            profileUrl: url,
                            size: 48,
                            onTap: () {
                              selected = url;
                              Navigator.of(ctx).pop();
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        setModalState(() {
                          seeds
                            ..clear()
                            ..addAll(List.generate(
                                52, (_) => generateRandomInteger(1, 1000)));
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Generate Again'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selected != null) {
      final updated = List<Person>.from(widget.people);
      updated[index] = updated[index].copyWith(profile: selected);
      widget.onPeopleChanged(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Row(
                    children: const [
                      SizedBox(
                        width: 64,
                        child: Text(
                          'Selected',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                            color: AppColors.main,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'No.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.main,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Profile',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.main,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Name',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.main,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(width: 40),
                    ],
                  ),
                ),
                ...List.generate(widget.people.length, (index) {
                  final person = widget.people[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 64,
                          child: GestureDetector(
                            onTap: () => _toggleSelect(index),
                            child: person.selected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: AppColors.success,
                                    size: 28,
                                  )
                                : Container(
                                    width: 24,
                                    height: 24,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.grey.shade500,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '${index + 1}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.main),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: PersonAvatarOnly(
                              profileUrl: person.profile,
                              size: 48,
                              onTap: () => _pickAvatar(index),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: TextField(
                              controller: _controllers[index],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.main,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Nickname',
                              ),
                              onChanged: (value) {
                                final updated =
                                    List<Person>.from(widget.people);
                                updated[index] =
                                    updated[index].copyWith(name: value);
                                widget.onPeopleChanged(updated);
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: IconButton(
                            onPressed: () => _deletePerson(index),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        Container(
          color: AppColors.second,
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 36,
                child: ElevatedButton(
                  onPressed: _addPerson,
                  child: const Text('Add Person'),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: widget.saveFriends,
                      onChanged: (v) => widget.onSaveFriendsChanged(v ?? false),
                    ),
                    const Text(
                      'Save This List',
                      style: TextStyle(color: AppColors.main),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
