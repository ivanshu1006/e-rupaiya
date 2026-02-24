class SpinOptionsState {
  const SpinOptionsState({
    this.isLoading = false,
    this.errorMessage,
    this.options = const {},
  });

  final bool isLoading;
  final String? errorMessage;
  final Map<String, List<int>> options;

  static const _sentinel = Object();

  SpinOptionsState copyWith({
    bool? isLoading,
    Object? errorMessage = _sentinel,
    Map<String, List<int>>? options,
  }) {
    return SpinOptionsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      options: options ?? this.options,
    );
  }
}
