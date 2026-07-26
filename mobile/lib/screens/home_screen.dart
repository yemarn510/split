import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/item.dart';
import '../models/person.dart';
import '../models/result.dart';
import '../models/split.dart';
import '../theme/app_colors.dart';
import '../utils/calculations.dart';
import '../widgets/common_widgets.dart';
import '../widgets/rounded_avatar.dart';
import 'step_four_review.dart';
import 'step_one_people.dart';
import 'step_three_assign.dart';
import 'step_two_items.dart';

const List<String> kSteps = [
  'Add People',
  'Add Items',
  'Assign People & Items',
  'Review & Split',
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentStep = 0;
  List<Person> _people = [Person()];
  List<Item> _items = [Item()];
  SplitDictionary _splitDict = {};
  List<Result> _results = [];
  bool _saveFriends = false;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('friends');
    if (raw != null && raw.isNotEmpty) {
      final list = (jsonDecode(raw) as List)
          .map((e) => Person.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      setState(() {
        _people = list.isEmpty ? [Person()] : list;
        _saveFriends = true;
      });
    }
  }

  Future<void> _persistFriendsIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (_saveFriends) {
      await prefs.setString(
        'friends',
        jsonEncode(_people.map((p) => p.toJson()).toList()),
      );
    } else {
      await prefs.remove('friends');
    }
  }

  List<Person> get _selectedPeople =>
      _people.where((p) => p.selected).toList();

  bool _goNextDisabled() {
    switch (_currentStep) {
      case 0:
        return _people.isEmpty || _people.every((p) => !p.selected);
      case 1:
        return _items.isEmpty;
      case 2:
        return someStepsAreEmpty(_splitDict);
      default:
        return false;
    }
  }

  bool _isStepTwoValid() {
    final checking = _items.map((e) {
      e.isValid();
      return e;
    }).toList();
    final valid = checking.every((e) => e.error.isEmpty);
    setState(() => _items = checking);
    return valid;
  }

  void _goNext() {
    if (_goNextDisabled()) {
      if (_currentStep == 0 && _people.every((p) => !p.selected)) {
        _showMessage('Please select at least one person to continue');
      }
      if (_currentStep == 2 && someStepsAreEmpty(_splitDict)) {
        _showMessage(
          'Some items are not assigned to anyone. Please assign them to continue',
        );
      }
      return;
    }

    switch (_currentStep) {
      case 0:
        _persistFriendsIfNeeded();
        setState(() => _currentStep = 1);
        break;
      case 1:
        if (_isStepTwoValid()) {
          final newDict = <String, Split>{};
          for (final item in _items) {
            if (_splitDict.containsKey(item.uuid)) {
              newDict[item.uuid] = _splitDict[item.uuid]!;
            }
          }
          setState(() {
            _splitDict = newDict;
            _currentStep = 2;
          });
        }
        break;
      case 2:
        final results =
            calculateResults(_items, _selectedPeople, _splitDict);
        setState(() {
          _results = results;
          _currentStep = 3;
        });
        break;
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  void _showLogin() {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Login'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const UnknownPerson(size: AvatarSize.lg),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Google login will connect in a later update',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: const Text('Login with Google'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showShare() {
    final results = _results.where((r) => r.total > 0).toList();
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Share with your friends'),
          content: Container(
            width: 340,
            height: 320,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.shareBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: ListView(
              children: results.map((result) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          color: AppColors.main,
                          fontSize: 18,
                        ),
                        children: [
                          TextSpan(
                            text: result.person.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const TextSpan(text: ' has to pay'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...result.items.map((item) {
                      final share =
                          item.sharedNumber == 0 ? 1 : item.sharedNumber;
                      final line = item.isPercentage
                          ? '${item.paidBy?.name} - ${item.name} ${item.percent} % - ${item.price.toStringAsFixed(2)}'
                          : '${item.paidBy?.name} - ${item.name} ${item.price} / $share - ${(item.price / share).toStringAsFixed(2)}';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(line, style: const TextStyle(fontSize: 13)),
                      );
                    }),
                    const SizedBox(height: 8),
                    ...((result.totalToPayFor ?? {}).entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${e.key} total',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              e.value.toStringAsFixed(2),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      );
                    })),
                    const Divider(color: Colors.black87, thickness: 1),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _currentStepUI() {
    switch (_currentStep) {
      case 0:
        return StepOnePeople(
          people: _people,
          onPeopleChanged: (v) => setState(() => _people = v),
          saveFriends: _saveFriends,
          onSaveFriendsChanged: (v) => setState(() => _saveFriends = v),
        );
      case 1:
        return StepTwoItems(
          items: _items,
          people: _selectedPeople,
          onItemsChanged: (v) => setState(() => _items = v),
        );
      case 2:
        return StepThreeAssign(
          items: _items,
          people: _selectedPeople,
          splitDict: _splitDict,
          onSplitDictChanged: (v) => setState(() => _splitDict = v),
          onItemsChanged: (v) => setState(() => _items = v),
        );
      case 3:
        return StepFourReview(results: _results);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    return Scaffold(
      backgroundColor: AppColors.second,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Text(
                    "Let's Split the Bills",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                      fontSize: isMobile ? 32 : 40,
                      fontWeight: FontWeight.w600,
                      color: AppColors.main,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isMobile)
                    StepBadge(
                      current: _currentStep + 1,
                      total: kSteps.length,
                      title: kSteps[_currentStep],
                    )
                  else
                    DesktopStepper(
                      currentStep: _currentStep,
                      steps: kSteps,
                    ),
                  const SizedBox(height: 8),
                  Expanded(child: _currentStepUI()),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _showLogin,
                        child: Row(
                          children: const [
                            UnknownPerson(),
                            SizedBox(width: 6),
                            Text(
                              'Login',
                              style: TextStyle(color: AppColors.main),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          CircleNavButton(
                            icon: Icons.arrow_back,
                            label: 'Go Back',
                            labelAfter: false,
                            enabled: _currentStep > 0,
                            onTap: _goBack,
                          ),
                          const SizedBox(width: 16),
                          if (_currentStep == 3)
                            CircleNavButton(
                              icon: Icons.open_in_new,
                              label: 'Share',
                              onTap: _showShare,
                            )
                          else
                            CircleNavButton(
                              icon: Icons.arrow_forward,
                              label: 'Go Next',
                              enabled: true,
                              dimmed: _goNextDisabled(),
                              onTap: _goNext,
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
