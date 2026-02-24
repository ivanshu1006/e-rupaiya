import 'quick_action_model.dart';
import 'quick_actions_model.dart';

class HomeState {
  const HomeState({
    this.isFetching = false,
    this.errorMessage,
    this.allQuickActions,
    this.quickActions,
  });

  final bool isFetching;
  final String? errorMessage;
  final List<Data>? allQuickActions;
  final List<QuickActionCategory>? quickActions;

  static const _sentinel = Object();

  HomeState copyWith({
    bool? isFetching,
    Object? errorMessage = _sentinel,
    List<Data>? allQuickActions,
    Object? quickActions = _sentinel,
  }) {
    return HomeState(
      isFetching: isFetching ?? this.isFetching,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      allQuickActions: allQuickActions ?? this.allQuickActions,
      quickActions: quickActions == _sentinel
          ? this.quickActions
          : quickActions as List<QuickActionCategory>?,
    );
  }
}
