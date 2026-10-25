import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
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
import '../theme/app_theme.dart';
import '../utils/calculations.dart';
import '../widgets/ant/ant.dart';
import '../widgets/common_widgets.dart';
import '../widgets/login_popup.dart';
import '../widgets/next_button.dart';
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

/// Port of frontend/src/app/page.tsx (plus the data loading in login-popup.tsx).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = AuthService();
  late final FriendsService _friends = FriendsService(Supabase.instance.client);
  late final HistoryService _history = HistoryService(Supabase.instance.client);
  final LoginState _login = LoginState();
  StreamSubscription<AuthState>? _authSub;

  /// Bumped to re-mount the page, like navigating back to "/" on the web.
  int _mountKey = 0;
  int _currentStep = 0;
  List<Item> _items = [Item()];
  List<Person> _people = [Person()];
  SplitDictionary _splitDict = {};
  List<Result> _results = [];
  bool _saveFriends = false;
  final bool _isPremiumUser = false;

  @override
  void initState() {
    super.initState();
    _resetState();
    _loadPeople();
    _authSub = _auth.authStateChanges.listen((state) {
      if (state.event == AuthChangeEvent.signedIn) {
        _checkUser();
      } else if (state.event == AuthChangeEvent.signedOut) {
        _login.update((s) {
          s.user = null;
          s.histories = null;
          s.historiesError = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _login.dispose();
    super.dispose();
  }

  /// The initial state of page.tsx.
  void _resetState() {
    _mountKey++;
    _currentStep = 0;
    _items = [Item()];
    _people = [Person()];
    _splitDict = {};
    _results = [];
    _saveFriends = false;
  }

  /// page.tsx's mount effect followed by login-popup.tsx's `checkUser`.
  Future<void> _loadPeople() async {
    final prefs = await SharedPreferences.getInstance();
    final friends = prefs.getString('friends') ?? '';
    if (friends.isNotEmpty && mounted) {
      final list = (jsonDecode(friends) as List)
          .map((e) => Person.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      setState(() {
        _people = list;
        _saveFriends = true;
      });
    }
    await _checkUser();
  }

  Future<void> _checkUser() async {
    final user = _auth.currentUser;
    _login.update((s) => s.user = user);
    if (user == null) return;
    unawaited(_checkFriends());
    await _fetchUserHistories(user.id);
  }

  Future<void> _checkFriends() async {
    try {
      final people = await _friends.fetchFriends();
      if (mounted) setState(() => _people = people);
    } catch (e) {
      debugPrint('Error getting friends: $e');
    }
  }

  Future<void> _fetchUserHistories(String userId) async {
    _login.update((s) {
      s.historiesLoading = true;
      s.historiesError = null;
    });
    try {
      final histories = await _history.fetchUserHistories(userId);
      _login.update((s) => s.histories = histories);
    } catch (e) {
      _login.update((s) {
        s.histories = [];
        s.historiesError = e is PostgrestException ? e.message : 'Failed to load history.';
      });
    } finally {
      _login.update((s) => s.historiesLoading = false);
    }
  }

  List<Person> get _selectedPeople => _people.where((p) => p.selected).toList();

  bool _goNextButtonDisabled() {
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
    for (final item in _items) {
      item.isValid();
    }
    final isValid = _items.every((e) => e.isValid());
    if (isValid) return true;
    setState(() => _items = List.of(_items));
    return false;
  }

  Future<void> _goNext() async {
    if (_goNextButtonDisabled()) {
      if (_currentStep == 0 && _people.every((p) => !p.selected)) {
        AntMessage.error(context, 'Please select at least one person to continue');
      }
      if (_currentStep == 2 && someStepsAreEmpty(_splitDict)) {
        AntMessage.error(
          context,
          'Some items are not assigned to anyone. Please assign them to continue',
        );
      }
      return;
    }

    switch (_currentStep) {
      case 0:
        if (_saveFriends) {
          // The web call runs unauthenticated too, where RLS rejects it.
          if (_login.user != null) {
            unawaited(_friends
                .createOrUpdateFriends(_people)
                .catchError((Object e) => debugPrint('$e')));
          }
        } else {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('friends');
        }
        setState(() => _currentStep = 1);
        break;
      case 1:
        if (_isStepTwoValid()) {
          final itemUUIDs = _items.map((e) => e.uuid).toSet();
          setState(() {
            _currentStep = 2;
            _splitDict = {
              for (final uuid in _splitDict.keys)
                if (itemUUIDs.contains(uuid)) uuid: _splitDict[uuid]!,
            };
          });
        }
        break;
      case 2:
        final results = calculateResults(_items, _selectedPeople, _splitDict);
        setState(() {
          _results = results;
          _currentStep = 3;
        });
        break;
    }
  }

  void _goBack() {
    if (_currentStep > 0) setState(() => _currentStep -= 1);
  }

  Future<void> _signIn() async {
    try {
      await _auth.signInWithGoogle();
    } catch (e) {
      if (mounted) AntMessage.error(context, 'Login failed: $e');
    }
  }

  void _logout() {
    _auth.signOut();
    _login.update((s) {
      s.user = null;
      s.histories = null;
      s.historiesError = null;
    });
  }

  /// `router.push('/history/:id')`; coming back re-mounts the home page.
  Future<void> _openHistory(String historyId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => HistoryScreen(historyId: historyId)),
    );
    if (!mounted) return;
    setState(_resetState);
    await _loadPeople();
  }

  Widget _currentStepUI() {
    switch (_currentStep) {
      case 0:
        return StepOnePeople(
          people: _people,
          onPeopleChanged: (v) => setState(() => _people = v),
          saveFriends: _saveFriends,
          onSaveFriendsChanged: (v) => setState(() => _saveFriends = v),
          items: _items,
          onItemsChanged: (v) => setState(() => _items = v),
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
        return const Text('Not Implemented yet!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final fullHeight = media.size.height - media.viewPadding.top - media.viewPadding.bottom;
    final width = media.size.width;
    final md = width >= 768;
    // `.main-content`: 95vw x (100dvh - 220px) on phones,
    // min(90vw, 600px) x (100dvh - 340px) with a 0.5rem margin from md up.
    final contentWidth = md ? math.min(width * 0.9, 600.0) : width * 0.95;
    final contentHeight = math.max(0.0, fullHeight - (md ? 340 : 220));

    return Scaffold(
      backgroundColor: AppColors.second,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: SizedBox(
            height: fullHeight,
            child: Center(
              child: SizedBox(
                width: contentWidth + (md ? 16 : 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Let’s Split the Bills',
                      textAlign: TextAlign.center,
                      style: md
                          ? cssText(size: 48, lineHeight: 48, color: AppColors.main)
                          : cssText(size: 36, lineHeight: 40, color: AppColors.main),
                    ),
                    const SizedBox(height: 12),
                    if (md)
                      AntSteps(current: _currentStep, steps: kSteps)
                    else ...[
                      StepBadge(
                        current: _currentStep + 1,
                        total: kSteps.length,
                        title: kSteps[_currentStep],
                      ),
                      const SizedBox(height: 8),
                    ],
                    Padding(
                      padding: EdgeInsets.all(md ? 8 : 0),
                      child: SizedBox(
                        height: contentHeight,
                        child: KeyedSubtree(
                          key: ValueKey('$_mountKey-$_currentStep'),
                          child: _currentStepUI(),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        LoginPopup(
                          state: _login,
                          auth: _auth,
                          isPremiumUser: _isPremiumUser,
                          onLogin: _signIn,
                          onLogout: _logout,
                          onOpenHistory: _openHistory,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleNavButton(
                                icon: AntIconData.arrowLeft,
                                label: 'Go Back',
                                labelFirst: true,
                                dimmed: _currentStep == 0,
                                onTap: _goBack,
                              ),
                              SizedBox(width: md ? 20 : 12),
                              NextButton(
                                currentStep: _currentStep,
                                stepsLength: kSteps.length,
                                results: _results,
                                goNextDisabled: _goNextButtonDisabled(),
                                goNext: _goNext,
                                login: _login,
                                onHistorySaved: _openHistory,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
