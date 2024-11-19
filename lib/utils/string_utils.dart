String emailToKey(String email) {
  return email.replaceAll('.', '_').replaceAll('@', '_');
}
