enum AuthFlow {
  login,
  register,
}

AuthFlow? authFlowFromApi(Object? value) {
  if (value == null) return null;
  final raw = value.toString().trim().toUpperCase();
  switch (raw) {
    case 'LOGIN':
      return AuthFlow.login;
    case 'REGISTER':
      return AuthFlow.register;
  }
  return null;
}
