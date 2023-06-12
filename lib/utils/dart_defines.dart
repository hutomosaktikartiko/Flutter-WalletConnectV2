class DartDefines {
  static const String projectId = String.fromEnvironment(
    'PROJECT_ID',
    defaultValue: '8eaf78b8e19d71bfa435b5f34eef83e6',
  );
  
  static const String ethereumPrivateKey = String.fromEnvironment(
    'ETHEREUM_PRIVATE_KEY',
    defaultValue:
        '415d3d81c550d9cc6794a5d842f5b819238570192254bdb7dd80885840be1963',
  );
  static const String ethereumPublicKey = String.fromEnvironment(
    'ETHEREUM_PUBLIC_KEY',
    defaultValue: '0xeB900400cbaD60dACB53c1a37C11FE02AC49bf1C',
  );
}
