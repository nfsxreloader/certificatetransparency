class CertificateTransparencyException implements Exception {
  const CertificateTransparencyException();

  @override
  String toString() {
    return 'CertificateTransparencyException: Connection is not secure';
  }
}
