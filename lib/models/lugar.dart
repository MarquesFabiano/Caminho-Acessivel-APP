class Lugar {
  final String id;
  final String name;
  final String formattedAddress;
  final List<String> tiposDeAcessibilidade;
  final bool aprovado;
  final double avaliacao;
  String comentarios; // Novo campo para comentários

  Lugar({
    required this.id,
    required this.name,
    required this.formattedAddress,
    required this.tiposDeAcessibilidade,
    required this.aprovado,
    required this.avaliacao,
    this.comentarios = '', // Campo de comentários com valor padrão
  });

  factory Lugar.fromMap(Map<String, dynamic> map) {
    return Lugar(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      formattedAddress: map['formattedAddress'] ?? '',
      tiposDeAcessibilidade: List<String>.from(map['tiposDeAcessibilidade'] ?? []),
      aprovado: map['aprovado'] ?? false,
      avaliacao: map['avaliacao'] ?? 0.0,
      comentarios: map['comentarios'] ?? '', // Novo campo para comentários
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
      'comentarios': comentarios, // Incluir comentários ao salvar
    };
  }
}
