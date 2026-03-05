import 'quick_action_model.dart';
import 'quick_actions_model.dart';

class HomeState {
  const HomeState({
    this.isFetching = false,
    this.isFetchingCreditCards = false,
    this.isFetchingRecharge = false,
    this.errorMessage,
    this.allQuickActions,
    this.quickActions,
    this.creditCardActions,
    this.rechargeActions,
  });

  final bool isFetching;
  final bool isFetchingCreditCards;
  final bool isFetchingRecharge;
  final String? errorMessage;
  final List<Data>? allQuickActions;
  final List<QuickActionCategory>? quickActions;
  // null = not yet fetched, [] = fetched & empty, [...] = has data
  final List<Data>? creditCardActions;
  final List<Data>? rechargeActions;

  static const _sentinel = Object();

  HomeState copyWith({
    bool? isFetching,
    bool? isFetchingCreditCards,
    bool? isFetchingRecharge,
    Object? errorMessage = _sentinel,
    List<Data>? allQuickActions,
    Object? quickActions = _sentinel,
    Object? creditCardActions = _sentinel,
    Object? rechargeActions = _sentinel,
  }) {
    return HomeState(
      isFetching: isFetching ?? this.isFetching,
      isFetchingCreditCards:
          isFetchingCreditCards ?? this.isFetchingCreditCards,
      isFetchingRecharge: isFetchingRecharge ?? this.isFetchingRecharge,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      allQuickActions: allQuickActions ?? this.allQuickActions,
      quickActions: quickActions == _sentinel
          ? this.quickActions
          : quickActions as List<QuickActionCategory>?,
      creditCardActions: creditCardActions == _sentinel
          ? this.creditCardActions
          : creditCardActions as List<Data>?,
      rechargeActions: rechargeActions == _sentinel
          ? this.rechargeActions
          : rechargeActions as List<Data>?,
    );
  }
}
