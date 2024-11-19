enum Acessibilidade {
  cadeiraDeRodas,
  deficientesVisuais,
  deficientesAuditivos,
  deficientesCognitivos,
}

class AcessibilidadeTypes {
  static const Map<Acessibilidade, String> labels = {
    Acessibilidade.cadeiraDeRodas: 'Cadeira de rodas',
    Acessibilidade.deficientesVisuais: 'Deficientes visuais',
    Acessibilidade.deficientesAuditivos: 'Deficientes auditivos',
    Acessibilidade.deficientesCognitivos: 'Deficientes cognitivos',
  };
}
