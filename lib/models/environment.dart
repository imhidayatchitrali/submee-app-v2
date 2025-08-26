class Environment {
  const Environment({
    required this.baseApiUrl,
    required this.googleClientIdSignIn,
    required this.environmentName,
    required this.apiKey,
  });

  factory Environment.fromDotEnv(Map<String, dynamic> data) => Environment(
        baseApiUrl: data['API_BASE_URL'],
        googleClientIdSignIn: data['GOOGLE_CLIENT_ID_SIGN_IN'],
        environmentName: data['ENVIRONMENT'],
        apiKey: data['VERSION_API_KEY'],
      );
  final String baseApiUrl;
  final String googleClientIdSignIn;
  final String environmentName;
  final String apiKey;
}
