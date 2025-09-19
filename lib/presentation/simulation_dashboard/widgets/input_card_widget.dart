import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Card de input com:
/// - título
/// - campo de texto com controlador persistente
/// - seletor de unidade (opcional)
/// - sufixo (opcional)
///
/// Observações:
/// - Sem `const` em widgets que dependem de valores dinâmicos.
/// - Debounce de 250ms no onChanged para evitar rebuilds a cada dígito.
/// - `units` + `onUnitChanged` são opcionais. Quando presentes, mostra um seletor.
class InputCardWidget extends StatefulWidget {
  const InputCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.hintText,
    required this.onChanged,
    this.unit = '',
    this.units,
    this.onUnitChanged,
    this.inputFormatters,
    this.keyboardType,
    this.suffixWidget,
  });

  final String title;
  final String value;

  /// Texto do hint no campo de entrada
  final String hintText;

  /// Unidade selecionada (texto exibido à direita, ex.: "sc/ha")
  final String unit;

  /// Lista de unidades disponíveis (se null/empty, não mostra seletor)
  final List<String>? units;

  /// Callback quando a unidade muda
  final ValueChanged<String>? onUnitChanged;

  /// Callback do valor digitado (com debounce)
  final ValueChanged<String> onChanged;

  /// Formatadores opcionais para o campo
  final List<TextInputFormatter>? inputFormatters;

  /// Tipo de teclado
  final TextInputType? keyboardType;

  /// Widget opcional a ser exibido como sufixo (ex.: ícone)
  final Widget? suffixWidget;

  @override
  State<InputCardWidget> createState() => _InputCardWidgetState();
}

class _InputCardWidgetState extends State<InputCardWidget> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant InputCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se o valor vindo de cima mudou, sincroniza o controlador
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChangedWithDebounce(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      widget.onChanged(v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            widget.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Campo de texto
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: widget.keyboardType ?? const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: widget.inputFormatters,
                  onChanged: _onChangedWithDebounce,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    border: const OutlineInputBorder(),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Seletor de unidade (se units != null && !empty)
              if (widget.units != null && widget.units!.isNotEmpty)
                _UnitSelector(
                  currentUnit: widget.unit,
                  units: widget.units!,
                  onChanged: widget.onUnitChanged,
                ),

              // Sufixo opcional
              if (widget.suffixWidget != null) ...[
                const SizedBox(width: 8),
                widget.suffixWidget!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _UnitSelector extends StatelessWidget {
  const _UnitSelector({
    required this.currentUnit,
    required this.units,
    required this.onChanged,
  });

  final String currentUnit;
  final List<String> units;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: units.contains(currentUnit) ? currentUnit : (units.isNotEmpty ? units.first : null),
          isDense: true,
          onChanged: (v) {
            if (v != null && onChanged != null) onChanged!(v);
          },
          items: units
              .map((u) => DropdownMenuItem<String>(
                    value: u,
                    child: Text(u),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
