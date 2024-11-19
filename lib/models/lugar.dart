class Lugar {
  final String id;
  final String name;
  final String formattedAddress;
  final List<String> tiposDeAcessibilidade;
  final bool aprovado;
  final double avaliacao;

  Lugar({
    required this.id,
    required this.name,
    required this.formattedAddress,
    required this.tiposDeAcessibilidade,
    required this.aprovado,
    required this.avaliacao,
  });

  factory Lugar.fromMap(Map<String, dynamic> map) {
    return Lugar(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      formattedAddress: map['formattedAddress'] ?? '',
      tiposDeAcessibilidade: List<String>.from(map['tiposDeAcessibilidade'] ?? []),
      aprovado: map['aprovado'] ?? false,
      avaliacao: map['avaliacao'] ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'formattedAddress': formattedAddress,
      'tiposDeAcessibilidade': tiposDeAcessibilidade,
      'aprovado': aprovado,
      'avaliacao': avaliacao,
    };
  }
}