import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/item.dart';
import '../models/person.dart';
import '../models/split.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/calculations.dart';
import '../utils/format.dart';
import '../widgets/ant/ant.dart';
import '../widgets/common_widgets.dart';
import '../widgets/rounded_avatar.dart';

/// Port of step-3.tsx.
class StepThreeAssign extends StatefulWidget {
  final List<Item> items;
  final List<Person> people;
  final SplitDictionary splitDict;
  final ValueChanged<SplitDictionary> onSplitDictChanged;
  final ValueChanged<List<Item>> onItemsChanged;

  const StepThreeAssign({
    super.key,
    required this.items,
    required this.people,
    required this.splitDict,
    required this.onSplitDictChanged,
    required this.onItemsChanged,
  });

  @override
  State<StepThreeAssign> createState() => _StepThreeAssignState();
}

class _StepThreeAssignState extends State<StepThreeAssign> {
  @override
  void initState() {
    super.initState();
    // The mount effect: a random icon for every item and a split per item,
    // keeping only people who are still selected.
    final peopleUUIDs = widget.people.map((p) => p.uuid).toSet();
    final splitDict = widget.splitDict;
    for (final item in widget.items) {
      item.image = foodImages[generateRandomInteger(0, 20)];
      final split = splitDict[item.uuid];
      if (split != null) {
        split.sharingPersonUUIDs =
            split.sharingPersonUUIDs.where(peopleUUIDs.contains).toSet();
      } else {
        splitDict[item.uuid] = ItemSplit(
          itemUUID: item.uuid,
          itemPrice: item.price,
          sharingPersonUUIDs: <String>{},
        );
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onSplitDictChanged(splitDict);
      widget.onItemsChanged(widget.items);
    });
  }

  Map<String, Person> get _peopleDict => {for (final p in widget.people) p.uuid: p};

  bool _isAllSelected(String? uuid) {
    if (uuid == null) return false;
    return widget.splitDict[uuid]?.sharingPersonUUIDs.length == widget.people.length;
  }

  void _toggleSelectAll(String? uuid) {
    if (uuid == null) return;
    final split = widget.splitDict[uuid];
    if (split == null) return;
    split.sharingPersonUUIDs = split.sharingPersonUUIDs.length == widget.people.length
        ? <String>{}
        : widget.people.map((p) => p.uuid).toSet();
    widget.onSplitDictChanged(widget.splitDict);
  }

  void _assignPerson(String itemUUID, String personUUID) {
    final sharing = widget.splitDict[itemUUID]!.sharingPersonUUIDs;
    sharing.contains(personUUID) ? sharing.remove(personUUID) : sharing.add(personUUID);
    widget.onSplitDictChanged(widget.splitDict);
  }

  void _openChangeIcon(int itemIndex) {
    final md = Breakpoints.md(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    // Modal body width minus `p-5` and the grid gaps.
    final bodyWidth = math.min(520.0, screenWidth - (md ? 32 : 16)) - (md ? 32 : 16);
    final columns = md ? 4 : 3;
    final cellWidth = (bodyWidth - 40 - 16 * (columns - 1)) / columns;
    final tile = math.min(104.0, cellWidth);

    showAntModal<void>(
      context: context,
      title: 'Change Icon',
      builder: (modalContext) => SizedBox(
        height: 320,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: CssGrid(
            columns: columns,
            gap: 16,
            children: [
              for (final image in foodImages)
                GestureDetector(
                  onTap: () {
                    widget.items[itemIndex].image = image;
                    widget.onItemsChanged(List.of(widget.items));
                    Navigator.of(modalContext).pop();
                  },
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ItemImage(image: image, size: tile),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openParticipants(String itemUUID) {
    showAntModal<void>(
      context: context,
      title: 'Choose Participants',
      closable: false,
      builder: (modalContext) => StatefulBuilder(
        builder: (context, setModalState) {
          final md = Breakpoints.md(context);
          final allSelected = _isAllSelected(itemUUID);
          final sharing = widget.splitDict[itemUUID]?.sharingPersonUUIDs ?? <String>{};
          // `mt-3` collapses with the title's 8px bottom margin: 12px in total.
          return Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: AntButton(
                    minWidth: 160,
                    label: allSelected ? 'Deselect All' : 'Select All',
                    background: allSelected ? AppColors.main : null,
                    foreground: allSelected ? AppColors.white : null,
                    onPressed: () {
                      _toggleSelectAll(itemUUID);
                      setModalState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 320,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: CssGrid(
                      columns: md ? 4 : 3,
                      gap: md ? 16 : 8,
                      children: [
                        for (final person in widget.people)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              _assignPerson(itemUUID, person.uuid);
                              setModalState(() {});
                            },
                            child: Center(
                              child: _ParticipantChoice(
                                person: person,
                                selected: sharing.contains(person.uuid),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: AntButton(
                    label: 'Close',
                    onPressed: () => Navigator.of(modalContext).pop(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final md = Breakpoints.md(context);
    final peopleDict = _peopleDict;

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: widget.items.length,
      itemBuilder: (context, itemIndex) {
        final item = widget.items[itemIndex];
        final sharing = widget.splitDict[item.uuid]?.sharingPersonUUIDs ?? <String>{};

        final imageBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _openChangeIcon(itemIndex),
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ItemImage(image: item.image),
                    if (item.paidBy != null)
                      Positioned(
                        top: -16,
                        left: -32,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Paid By', style: cssText(size: 12, lineHeight: 16)),
                              RoundedAvatar(person: item.paidBy!, ringColor: AppColors.main),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Text(
              '${item.name} - ${item.isPercentage ? '${jsNum(item.percent)} %' : jsNum(item.price)}',
              textAlign: TextAlign.center,
              style: cssText(size: 24, lineHeight: 36),
            ),
          ],
        );

        final participantsBlock = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _openParticipants(item.uuid),
              child: sharing.isNotEmpty
                  ? _SharedPeople(peopleDict: peopleDict, sharing: sharing)
                  : const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Center(child: UnknownPerson(size: AvatarSize.lg)),
                    ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.only(bottom: md ? 0 : 12),
              child: Row(
                children: [
                  Expanded(
                    child: AntButton.primary(
                      block: true,
                      icon: AntIconData.userAdd,
                      label: 'Select Participants',
                      horizontalPadding: 4,
                      onPressed: () => _openParticipants(item.uuid),
                    ),
                  ),
                  SizedBox(width: md ? 12 : 4),
                  Expanded(
                    child: AntButton(
                      block: true,
                      icon: AntIconData.usergroupAdd,
                      label: _isAllSelected(item.uuid) ? 'Deselect All' : 'Select All',
                      background: AppColors.second,
                      borderColor: AppColors.main,
                      onPressed: () => _toggleSelectAll(item.uuid),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        return Container(
          margin: const EdgeInsets.only(top: 8),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: md ? 8 : 0),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.main)),
          ),
          child: md
              ? Row(
                  children: [
                    Expanded(child: imageBlock),
                    const SizedBox(width: 20),
                    Expanded(flex: 2, child: participantsBlock),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [imageBlock, const SizedBox(height: 20), participantsBlock],
                ),
        );
      },
    );
  }
}

/// `ItemImage` in step-3.tsx: an 80px icon in a `bg-third p-3 rounded-md` box.
class ItemImage extends StatelessWidget {
  final String image;
  final double size;

  const ItemImage({super.key, required this.image, this.size = 104});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.third,
        borderRadius: BorderRadius.circular(6),
      ),
      child: image.isEmpty
          ? const SizedBox.shrink()
          : SvgPicture.asset(image, width: size - 24, height: size - 24),
    );
  }
}

/// `ShowSomeSharedPeople`: the first three participants and a "+N" bubble.
class _SharedPeople extends StatelessWidget {
  final Map<String, Person> peopleDict;
  final Set<String> sharing;

  /// The web component starts at 3 and only changes on a window resize.
  static const int _shown = 3;

  const _SharedPeople({required this.peopleDict, required this.sharing});

  @override
  Widget build(BuildContext context) {
    final md = Breakpoints.md(context);
    final list = sharing.toList();
    final textStyle = cssText();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < math.min(_shown, list.length); i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.third, shape: BoxShape.circle),
                child: ProfileImage(url: peopleDict[list[i]]?.profile ?? '', size: md ? 48 : 32),
              ),
              Text(
                (peopleDict[list[i]]?.name ?? '').isEmpty ? '-' : peopleDict[list[i]]!.name,
                textAlign: TextAlign.center,
                style: textStyle,
              ),
            ],
          ),
        ],
        if (list.length > _shown) ...[
          const SizedBox(width: 4),
          Container(
            width: md ? 64 : 48,
            height: md ? 64 : 48,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.fourth, shape: BoxShape.circle),
            child: Text('+${list.length - _shown}', style: textStyle.copyWith(color: AppColors.white)),
          ),
        ],
      ],
    );
  }
}

/// One avatar in the "Choose Participants" grid.
class _ParticipantChoice extends StatelessWidget {
  final Person person;
  final bool selected;

  const _ParticipantChoice({required this.person, required this.selected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: selected ? AppColors.fourth : AppColors.third,
                  shape: BoxShape.circle,
                ),
                child: ProfileImage(url: person.profile, size: 48),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Opacity(
                  opacity: selected ? 1 : 0,
                  child: Container(
                    width: 25,
                    height: 25,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.main,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    child: const AntIcon(AntIconData.check, size: 14, color: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
          Text(person.name.isEmpty ? '-' : person.name, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
