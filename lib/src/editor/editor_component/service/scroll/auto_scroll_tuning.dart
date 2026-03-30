/// Define os parâmetros que controlam o comportamento do auto scroll do editor.
///
/// Manual rápido:
/// Quer fazer o auto scroll começar mais longe da borda?
/// Aumente [selectionDragEdgeOffset].
///
/// Quer fazer o auto scroll começar mais perto da borda?
/// Diminua [selectionDragEdgeOffset].
///
/// Quer deixar o auto scroll mais rápido de forma geral?
/// Aumente [velocityScalar].
///
/// Quer deixar o auto scroll mais lento de forma geral?
/// Diminua [velocityScalar].
///
/// Quer aumentar a velocidade máxima?
/// Aumente [maximumAutoScrollDelta].
///
/// Quer reduzir a velocidade máxima?
/// Diminua [maximumAutoScrollDelta].
///
/// Quer fazer o scroll começar com mais força perto da borda?
/// Aumente [minimumAutoScrollDelta].
///
/// Quer deixar o começo do scroll mais suave?
/// Diminua [minimumAutoScrollDelta].
///
/// Quer permitir que arrastar ainda mais para fora da borda continue
/// acelerando o scroll?
/// Aumente [overDragMax].
///
/// Quer fazer a velocidade saturar mais cedo?
/// Diminua [overDragMax].
///
/// Quer deixar a resposta mais agressiva e imediata?
/// Aumente [scrollDeltaSmoothingFactor].
///
/// Quer deixar a resposta mais suave?
/// Diminua [scrollDeltaSmoothingFactor].
///
/// Quer aumentar a cadência dos passos do auto scroll?
/// Diminua [animationDuration].
///
/// Quer reduzir a cadência dos passos do auto scroll?
/// Aumente [animationDuration].
class AutoScrollConfig {
  const AutoScrollConfig({
    required this.velocityScalar,
    required this.minimumAutoScrollDelta,
    required this.maximumAutoScrollDelta,
    required this.overDragMax,
    required this.scrollDeltaSmoothingFactor,
    required this.animationDuration,
    required this.selectionDragEdgeOffset,
  });

  /// Multiplica a distância de overscroll para produzir o delta bruto de scroll.
  ///
  /// Aumentar este valor deixa o auto scroll mais agressivo.
  /// Diminuir este valor deixa o auto scroll mais lento e menos reativo.
  final double velocityScalar;

  /// Delta mínimo aplicado em um tick de auto scroll quando o delta calculado
  /// ainda é diferente de zero.
  ///
  /// Aumentar este valor faz o scroll começar com mais "tranco" perto da borda.
  /// Diminuir este valor deixa o início do auto scroll mais suave.
  final double minimumAutoScrollDelta;

  /// Delta máximo permitido em um único tick de auto scroll.
  ///
  /// Aumentar este valor permite uma velocidade máxima maior.
  /// Diminuir este valor limita mais cedo a velocidade máxima.
  final double maximumAutoScrollDelta;

  /// Distância máxima de overscroll considerada pelo algoritmo.
  ///
  /// Aumentar este valor permite que arrastar mais para fora da borda continue
  /// aumentando a velocidade.
  /// Diminuir este valor faz a velocidade saturar mais cedo.
  final double overDragMax;

  /// Fator de interpolação usado para suavizar a mudança de delta entre ticks.
  ///
  /// Aumentar este valor deixa a resposta mais rápida e mais agressiva.
  /// Diminuir este valor deixa a aceleração e desaceleração mais suaves,
  /// porém menos responsivas.
  final double scrollDeltaSmoothingFactor;

  /// Duração de cada passo de movimento do auto scroll.
  ///
  /// Aumentar este valor faz cada tick durar mais, o que tende a reduzir a
  /// cadência percebida.
  /// Diminuir este valor deixa a cadência mais rápida e mais seca.
  final Duration animationDuration;

  /// Tamanho da zona de ativação usada durante o drag de seleção.
  ///
  /// Aumentar este valor faz o auto scroll começar mais longe da borda.
  /// Diminuir este valor exige chegar mais perto da borda para ativar.
  ///
  /// Este parâmetro altera quando o auto scroll começa, não a velocidade bruta.
  final double selectionDragEdgeOffset;

  static const desktopOrWeb = AutoScrollConfig(
    velocityScalar: 5,
    minimumAutoScrollDelta: 0.07,
    maximumAutoScrollDelta: 20,
    overDragMax: 30.0,
    scrollDeltaSmoothingFactor: 0.35,
    animationDuration: Duration(milliseconds: 16),
    selectionDragEdgeOffset: 200,
  );

  static const mobile = AutoScrollConfig(
    velocityScalar: 0.15,
    minimumAutoScrollDelta: 0.07,
    maximumAutoScrollDelta: 3.5,
    overDragMax: 20.0,
    scrollDeltaSmoothingFactor: 0.35,
    animationDuration: Duration.zero,
    selectionDragEdgeOffset: 200,
  );

  AutoScrollConfig copyWith({
    double? velocityScalar,
    double? minimumAutoScrollDelta,
    double? maximumAutoScrollDelta,
    double? overDragMax,
    double? scrollDeltaSmoothingFactor,
    Duration? animationDuration,
    double? selectionDragEdgeOffset,
  }) {
    return AutoScrollConfig(
      velocityScalar: velocityScalar ?? this.velocityScalar,
      minimumAutoScrollDelta:
          minimumAutoScrollDelta ?? this.minimumAutoScrollDelta,
      maximumAutoScrollDelta:
          maximumAutoScrollDelta ?? this.maximumAutoScrollDelta,
      overDragMax: overDragMax ?? this.overDragMax,
      scrollDeltaSmoothingFactor:
          scrollDeltaSmoothingFactor ?? this.scrollDeltaSmoothingFactor,
      animationDuration: animationDuration ?? this.animationDuration,
      selectionDragEdgeOffset:
          selectionDragEdgeOffset ?? this.selectionDragEdgeOffset,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is AutoScrollConfig &&
        other.velocityScalar == velocityScalar &&
        other.minimumAutoScrollDelta == minimumAutoScrollDelta &&
        other.maximumAutoScrollDelta == maximumAutoScrollDelta &&
        other.overDragMax == overDragMax &&
        other.scrollDeltaSmoothingFactor == scrollDeltaSmoothingFactor &&
        other.animationDuration == animationDuration &&
        other.selectionDragEdgeOffset == selectionDragEdgeOffset;
  }

  @override
  int get hashCode => Object.hash(
        velocityScalar,
        minimumAutoScrollDelta,
        maximumAutoScrollDelta,
        overDragMax,
        scrollDeltaSmoothingFactor,
        animationDuration,
        selectionDragEdgeOffset,
      );
}
