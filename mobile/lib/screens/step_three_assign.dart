import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/item.dart';
import '../models/person.dart';
import '../models/split.dart';
import '../theme/app_colors.dart';
import '../utils/calculations.dart';
import '../widgets/rounded_avatar.dart';

class StepThreeAssign extends StatefulWidget {
  final List<Item> items;
  final List<Person> people;
  final SplitDictionary splitDict;
  final ValueChanged<SplitDictionary> onSplitDictChanged;
  final ValueChanged<List<Item>> onItemsChanged;

  const StepThreeAssign({
    Key? key,
    required this.items,
    required this.people,
    required this.splitDict,
    required this.onSplitDictChanged,
    required this.onItemsChanged,
  }) : super(key: key);

  @override
  State<StepThreeAssign> createState() => _StepThreeAssignState();
}

class _StepThreeAssignState extends State<StepThreeAssign> {
  @override
  void initState() {
    super.initState();
    _ensureSplitDict();
  }

  void _ensureSplitDict() {
    final peopleUUIDs = widget.people.map((p) => p.uuid).toSet();
    final updated = Map<String, ItemSplit>.from(widget.splitDict);
    final items = List<Item>.from(widget.items);

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.image.isEmpty) {
        items[i] = item.copyWith(
          image: foodImages[generateRandomInteger(0, foodImages.length - 1)],
        );
      }
      final existing = updated[item.uuid];
      if (existing != null) {
        updated[item.uuid] = existing.copyWith(
          sharingPersonUUIDs: existing.sharingPersonUUIDs
              .where(peopleUUIDs.contains)
              .toSet(),
        );
      } else {
        updated[item.uuid] = ItemSplit(
          itemUUID: item.uuid,
          itemPrice: item.price,
          sharingPersonUUIDs: {},
        );
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onItemsChanged(items);
      widget.onSplitDictChanged(updated);
    });
  }

  bool _isAllSelected(String uuid) {
    final split = widget.splitDict[uuid];
    if (split == null) return false;
    return split.sharingPersonUUIDs.length == widget.people.length;
  }

  void _toggleSelectAll(String uuid) {
    final updated = Map<String, ItemSplit>.from(widget.splitDict);
    final current = updated[uuid];
    if (current == null) return;
    if (current.sharingPersonUUIDs.length == widget.people.length) {
      updated[uuid] = current.copyWith(sharingPersonUUIDs: {});
    } else {
      updated[uuid] = current.copyWith(
        sharingPersonUUIDs: widget.people.map((p) => p.uuid).toSet(),
      );
    }
    widget.onSplitDictChanged(updated);
  }

  Future<void> _changeIcon(int itemIndex) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Change Icon'),
          content: SizedBox(
            width: double.maxFinite,
            height: 320,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: foodImages.length,
              itemBuilder: (_, i) {
                return GestureDetector(
                  onTap: () {
                    final items = List<Item>.from(widget.items);
                    items[itemIndex] =
                        items[itemIndex].copyWith(image: foodImages[i]);
                    widget.onItemsChanged(items);
                    Navigator.pop(ctx);
                  },
                  child: _ItemImage(image: foodImages[i]),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _chooseParticipants(String itemUUID) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final selected =
                widget.splitDict[itemUUID]?.sharingPersonUUIDs ?? {};
            final allSelected = selected.length == widget.people.length;

            return AlertDialog(
              title: const Text('Choose Participants'),
              content: SizedBox(
                width: double.maxFinite,
                height: 380,
                child: Column(
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor:
                            allSelected ? AppColors.main : AppColors.second,
                        foregroundColor:
                            allSelected ? AppColors.white : AppColors.main,
                        minimumSize: const Size(160, 36),
                      ),
                      onPressed: () {
                        _toggleSelectAll(itemUUID);
                        setModalState(() {});
                      },
                      child: Text(allSelected ? 'Deselect All' : 'Select All'),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: widget.people.length,
                        itemBuilder: (_, i) {
                          final person = widget.people[i];
                          final isSelected = selected.contains(person.uuid);
                          return GestureDetector(
                            onTap: () {
                              final updated =
                                  Map<String, ItemSplit>.from(widget.splitDict);
                              final split = updated[itemUUID]!.copyWith();
                              if (split.sharingPersonUUIDs
                                  .contains(person.uuid)) {
                                split.sharingPersonUUIDs.remove(person.uuid);
                              } else {
                                split.sharingPersonUUIDs.add(person.uuid);
                              }
                              updated[itemUUID] = split;
                              widget.onSplitDictChanged(updated);
                              setModalState(() {});
                            },
                            child: Column(
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.fourth
                                            : AppColors.third,
                                        shape: BoxShape.circle,
                                      ),
                                      child: CircleAvatar(
                                        radius: 24,
                                        backgroundImage:
                                            NetworkImage(person.profile),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: AnimatedOpacity(
                                        opacity: isSelected ? 1 : 0,
                                        duration:
                                            const Duration(milliseconds: 150),
                                        child: Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: AppColors.main,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            size: 12,
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  person.name.isEmpty ? '-' : person.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final peopleDict = {for (final p in widget.people) p.uuid: p};

    return ListView.builder(
      itemCount: widget.items.length,
      itemBuilder: (_, itemIndex) {
        final item = widget.items[itemIndex];
        final sharing =
            widget.splitDict[item.uuid]?.sharingPersonUUIDs ?? <String>{};
        final priceLabel = item.isPercentage
            ? '${item.name} - ${item.percent} %'
            : '${item.name} - ${item.price}';

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.main),
            ),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _changeIcon(itemIndex),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _ItemImage(image: item.image),
                    if (item.paidBy != null)
                      Positioned(
                        top: -12,
                        left: -24,
                        child: Column(
                          children: [
                            const Text(
                              'Paid By',
                              style: TextStyle(fontSize: 10),
                            ),
                            RoundedAvatar(
                              person: item.paidBy!,
                              bg: AppColors.main,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                priceLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.main,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _chooseParticipants(item.uuid),
                child: sharing.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: UnknownPerson(size: AvatarSize.lg),
                      )
                    : _SharedPeoplePreview(
                        peopleDict: peopleDict,
                        sharing: sharing,
                      ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _chooseParticipants(item.uuid),
                      icon: const Icon(Icons.person_add_alt_1, size: 18),
                      label: const Text(
                        'Select Participants',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _toggleSelectAll(item.uuid),
                      icon: const Icon(Icons.group_add, size: 18),
                      label: Text(
                        _isAllSelected(item.uuid)
                            ? 'Deselect All'
                            : 'Select All',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ItemImage extends StatelessWidget {
  final String image;

  const _ItemImage({required this.image});

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
          ? const SizedBox(width: 80, height: 80)
          : SvgPicture.asset(
              image,
              width: 80,
              height: 80,
            ),
    );
  }
}

class _SharedPeoplePreview extends StatelessWidget {
  final Map<String, Person> peopleDict;
  final Set<String> sharing;

  const _SharedPeoplePreview({
    required this.peopleDict,
    required this.sharing,
  });

  @override
  Widget build(BuildContext context) {
    final maxShow = MediaQuery.of(context).size.width < 500 ? 2 : 3;
    final list = sharing.toList();
    final visible = list.take(maxShow).toList();
    final overflow = list.length - maxShow;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...visible.map((uuid) {
          final person = peopleDict[uuid];
          if (person == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                PersonAvatarOnly(profileUrl: person.profile, size: 32),
                Text(
                  person.name.isEmpty ? '-' : person.name,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        }),
        if (overflow > 0)
          Container(
            width: 48,
            height: 48,
            margin: const EdgeInsets.only(left: 4),
            decoration: const BoxDecoration(
              color: AppColors.fourth,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '+$overflow',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
