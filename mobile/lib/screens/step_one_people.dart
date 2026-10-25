import 'package:flutter/material.dart';

import '../models/item.dart';
import '../models/person.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/ant/ant.dart';
import '../widgets/common_widgets.dart';
import '../widgets/rounded_avatar.dart';

/// Port of step-1.tsx.
class StepOnePeople extends StatefulWidget {
  final List<Person> people;
  final ValueChanged<List<Person>> onPeopleChanged;
  final bool saveFriends;
  final ValueChanged<bool> onSaveFriendsChanged;
  final List<Item> items;
  final ValueChanged<List<Item>> onItemsChanged;

  const StepOnePeople({
    super.key,
    required this.people,
    required this.onPeopleChanged,
    required this.saveFriends,
    required this.onSaveFriendsChanged,
    required this.items,
    required this.onItemsChanged,
  });

  @override
  State<StepOnePeople> createState() => _StepOnePeopleState();
}

class _StepOnePeopleState extends State<StepOnePeople> {
  final ValueNotifier<List<int>> _avatarNumbers = ValueNotifier(_randomAvatars());
  final Map<String, GlobalKey> _rowKeys = {};

  static List<int> _randomAvatars() =>
      List.generate(52, (_) => generateRandomInteger(1, 1000));

  @override
  void initState() {
    super.initState();
    _scrollToLastRow();
  }

  @override
  void didUpdateWidget(covariant StepOnePeople oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.people.length != widget.people.length) _scrollToLastRow();
  }

  @override
  void dispose() {
    _avatarNumbers.dispose();
    super.dispose();
  }

  /// `document.getElementById('person-row-N').scrollIntoView()`.
  void _scrollToLastRow() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.people.isEmpty) return;
      final rowContext = _rowKeys[widget.people.last.uuid]?.currentContext;
      if (rowContext != null) Scrollable.ensureVisible(rowContext);
    });
  }

  void _addPerson() {
    widget.onPeopleChanged([...widget.people, Person()]);
    widget.onSaveFriendsChanged(false);
  }

  void _toggleSelectPerson(int index) {
    widget.people[index].selected = !widget.people[index].selected;
    widget.onPeopleChanged(List.of(widget.people));
  }

  void _deletePerson(int index) {
    final cloned = List.of(widget.people);
    final person = cloned[index];
    final paidByIndex = widget.items.indexWhere(
      (each) => each.paidBy?.name == person.name && each.paidBy?.profile == person.profile,
    );
    if (paidByIndex != -1) {
      widget.items[paidByIndex].paidBy = null;
      widget.onItemsChanged(List.of(widget.items));
    }
    cloned.removeAt(index);
    widget.onPeopleChanged(cloned);
    widget.onSaveFriendsChanged(false);
  }

  void _openAvatarModal(int changingIndex) {
    final md = Breakpoints.md(context);
    showAntModal<void>(
      context: context,
      title: 'Choose your Avatar',
      builder: (modalContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 320,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ValueListenableBuilder<List<int>>(
                valueListenable: _avatarNumbers,
                builder: (_, numbers, __) => CssGrid(
                  columns: md ? 4 : 3,
                  gap: 16,
                  children: [
                    for (final number in numbers)
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            widget.people[changingIndex].profile = '$avatarUrlBase$number';
                            widget.onPeopleChanged(List.of(widget.people));
                            Navigator.of(modalContext).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.third,
                              shape: BoxShape.circle,
                            ),
                            child: ProfileImage(url: '$avatarUrlBase$number', size: 48),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: AntButton(
              icon: AntIconData.undo,
              label: 'Generate Again',
              onPressed: () => _avatarNumbers.value = _randomAvatars(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sm = Breakpoints.sm(context);
    final md = Breakpoints.md(context);
    final headerStyle = cssText(weight: FontWeight.w700, color: AppColors.main);
    final headerPadding =
        sm ? const EdgeInsets.all(12) : const EdgeInsets.fromLTRB(4, 4, 4, 12);

    return LayoutBuilder(builder: (context, constraints) {
      // Auto-layout widths measured on a 373px table.
      const selectedWidth = 75.0;
      const profileWidth = 74.0;
      final rest = (constraints.maxWidth - selectedWidth - profileWidth).clamp(0.0, double.infinity);
      final noWidth = rest * 57 / 224;
      final nameWidth = rest * 109 / 224;
      final deleteWidth = rest * 58 / 224;

      Widget th(String text, double width) => SizedBox(
            width: width,
            child: Padding(
              padding: headerPadding,
              child: Text(text, textAlign: TextAlign.center, style: headerStyle),
            ),
          );

      Widget td(double width, Widget child, {EdgeInsets padding = const EdgeInsets.all(8)}) =>
          SizedBox(width: width, child: Padding(padding: padding, child: child));

      final table = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            th('Selected', selectedWidth),
            th('No.', noWidth),
            th('Profile', profileWidth),
            th('Name', nameWidth),
            SizedBox(width: deleteWidth),
          ]),
          for (var index = 0; index < widget.people.length; index++)
            KeyedSubtree(
              key: _rowKeys.putIfAbsent(widget.people[index].uuid, () => GlobalKey()),
              child: Row(
                children: [
                  td(
                    selectedWidth,
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _toggleSelectPerson(index),
                      child: SizedBox(
                        height: 32,
                        child: Center(
                          child: widget.people[index].selected
                              ? const AntTwoToneIcon(
                                  AntIconData.checkCircleTwoTone,
                                  size: 24,
                                  primary: AppColors.success,
                                  secondary: AppColors.successLight,
                                )
                              : Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.gray400, width: 2),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  td(noWidth, Text('${index + 1}', textAlign: TextAlign.center)),
                  td(
                    profileWidth,
                    Center(
                      child: GestureDetector(
                        onTap: () => _openAvatarModal(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.third,
                            shape: BoxShape.circle,
                          ),
                          child: ProfileImage(url: widget.people[index].profile, size: 48),
                        ),
                      ),
                    ),
                  ),
                  td(
                    nameWidth,
                    AntInput(
                      initialValue: widget.people[index].name,
                      placeholder: 'Nickname',
                      textAlign: TextAlign.center,
                      borderColor: AppColors.main,
                      onChanged: (value) {
                        widget.people[index].name = value;
                        widget.onPeopleChanged(List.of(widget.people));
                      },
                    ),
                    padding: EdgeInsets.symmetric(horizontal: md ? 40 : 12, vertical: 8),
                  ),
                  td(
                    deleteWidth,
                    Center(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _deletePerson(index),
                        child: const AntIcon(AntIconData.delete, size: 20, color: AppColors.danger),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(child: SingleChildScrollView(child: table)),
          ColoredBox(
            color: AppColors.second,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AntButton.primary(block: true, label: 'Add Person', onPressed: _addPerson),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: AntCheckbox(
                    checked: widget.saveFriends,
                    label: 'Save This List',
                    onChanged: widget.onSaveFriendsChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
