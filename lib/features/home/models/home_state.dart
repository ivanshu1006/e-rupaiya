import 'quick_action_model.dart';

class HomeState {
  const HomeState({
    this.isFetching = false,
    this.errorMessage,
    this.latestPayload,
    this.quickActions,
  });

  final bool isFetching;
  final String? errorMessage;
  final List<dynamic>? latestPayload;
  final List<QuickActionCategory>? quickActions;

  static const _sentinel = Object();

  HomeState copyWith({
    bool? isFetching,
    Object? errorMessage = _sentinel,
    List<dynamic>? latestPayload,
    Object? quickActions = _sentinel,
  }) {
    return HomeState(
      isFetching: isFetching ?? this.isFetching,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      latestPayload: latestPayload ?? this.latestPayload,
      quickActions: quickActions == _sentinel
          ? this.quickActions
          : quickActions as List<QuickActionCategory>?,
    );
  }
}
