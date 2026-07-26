import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/item.dart';
import '../models/person.dart';
import '../models/result.dart';
import '../models/split.dart';
import '../services/auth_service.dart';
import '../services/friends_service.dart';
import '../services/history_service.dart';
import '../theme/app_colors.dart';
import '../utils/calculations.dart';
import '../widgets/common_widgets.dart';
import '../widgets/login_sheet.dart';
import '../widgets/rounded_avatar.dart';
import 'history_screen.dart';
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
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = AuthService();
  late final FriendsService _friends =
      FriendsService(Supabase.instance.client);
  late final HistoryService _history =
      HistoryService(Supabase.instance.client);

  StreamSubscription<AuthState>? _authSub;

  int _currentStep = 0;
  List<Person> _people = [Person()];
  List<Item> _items = [Item()];
  SplitDictionary _splitDict = {};
  List<Result> _results = [];
  bool _saveFriends = false;
  bool _savingHistory = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _loadFriends();
    _authSub = _auth.authStateChanges.listen((state) async {
      setState(() => _user = state.session?.user);
      if (state.session?.user != null) {
        try {
          final people = await _friends.fetchFriends();
          if (!mounted) return;
          setState(() {
            _people = people;
            _saveFriends = true;
          });
        } catch (_) {
          // Keep local people if remote fetch fails.
        }
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    if (_user != null) {
      try {
        final people = await _friends.fetchFriends();
        if (!mounted) return;
        setState(() {
          _people = people;
          _saveFriends = true;
        });
        return;
      } catch (_) {}
    }

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
      if (_user != null) {
        try {
          await _friends.createOrUpdateFriends(_people);
        } catch (e) {
          if (!mounted) return;
          _showMessage('Could not sync friends: $e');
        }
      }
    } else {
      await prefs.remove('friends');
    }
  }

  List<Person> get _selectedPeople =>
      _people.where((p) => p.selected).toList();

  bool _selectedPeopleMissingNames() {
    return _selectedPeople.any((p) => p.name.trim().isEmpty);
  }

  bool _goNextDisabled() {
    switch (_currentStep) {
      case 0:
        return _people.isEmpty ||
            _people.every((p) => !p.selected) ||
            _selectedPeopleMissingNames();
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

  Future<void> _goNext() async {
    if (_goNextDisabled()) {
      if (_currentStep == 0 && _people.every((p) => !p.selected)) {
        _showMessage('Please select at least one person to continue');
      } else if (_currentStep == 0 && _selectedPeopleMissingNames()) {
        _showMessage('Please enter a name for every selected person');
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
        await _persistFriendsIfNeeded();
        setState(() => _currentStep = 1);
        break;
      case 1:
        if (_isStepTwoValid()) {
          final newDict = <String, ItemSplit>{};
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

  void _showMessage(String text, {Color color = AppColors.danger}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: color),
    );
  }

  void _showLogin() {
    showDialog<void>(
      context: context,
      builder: (_) => LoginSheet(
        onPeopleLoaded: (people) {
          setState(() {
            _people = people;
            _saveFriends = true;
          });
        },
      ),
    );
  }

  Future<void> _saveHistory(String memo) async {
    final user = _auth.currentUser;
    if (user == null) {
      _showMessage('Please login with Google before sharing history.');
      return;
    }

    setState(() => _savingHistory = true);
    try {
      final results = _results.where((r) => r.total > 0).toList();
      final historyId = await _history.saveHistory(
        user: user,
        results: results,
        memo: memo,
      );
      if (!mounted) return;
      Navigator.of(context).pop(); // close memo dialog if open
      Navigator.of(context).pop(); // close share dialog
      _showMessage('History saved.', color: AppColors.main);
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => HistoryScreen(historyId: historyId),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString());
    } finally {
      if (mounted) setState(() => _savingHistory = false);
    }
  }

  void _openMemoDialog() {
    if (_auth.currentUser == null) return;
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add a memo'),
          content: TextField(
            controller: controller,
            maxLength: 120,
            decoration: const InputDecoration(
              hintText: 'Optional memo (e.g., Dinner at NN)',
            ),
            onSubmitted: (_) => _saveHistory(controller.text),
          ),
          actions: [
            TextButton(
              onPressed: _savingHistory ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _savingHistory
                  ? null
                  : () => _saveHistory(controller.text),
              child: _savingHistory
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
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
          content: SizedBox(
            width: 340,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const TextSpan(text: ' has to pay'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...result.items.map((item) {
                            final share = item.sharedNumber == 0
                                ? 1
                                : item.sharedNumber;
                            final line = item.isPercentage
                                ? '${item.paidBy?.name} - ${item.name} ${item.percent} % - ${item.price.toStringAsFixed(2)}'
                                : '${item.paidBy?.name} - ${item.name} ${item.price} / $share - ${(item.price / share).toStringAsFixed(2)}';
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                line,
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                          ...((result.totalToPayFor ?? {}).entries.map((e) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${e.key} total',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    e.value.toStringAsFixed(2),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
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
                if (_user != null) ...[
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _savingHistory ? null : _openMemoDialog,
                    icon: const Icon(Icons.history),
                    label: const Text('Save History'),
                  ),
                ],
              ],
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

  Widget _loginButton() {
    final avatar = _auth.avatarUrl;
    final name = _auth.displayName;
    if (_user == null) {
      return GestureDetector(
        onTap: _showLogin,
        child: const Row(
          children: [
            UnknownPerson(),
            SizedBox(width: 6),
            Text('Login', style: TextStyle(color: AppColors.main)),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _showLogin,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: AppColors.third,
          borderRadius: BorderRadius.all(Radius.circular(999)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: avatar != null ? NetworkImage(avatar) : null,
              child: avatar == null ? const Icon(Icons.person, size: 16) : null,
            ),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 90),
              child: Text(
                name ?? 'User',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.main, fontSize: 13),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
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
                      _loginButton(),
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
