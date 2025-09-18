import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class InputCardWidget extends StatefulWidget {
  final String widget.title;
  final String value;
  final String widget.unit;
  final String widget.hintText;
  final ValueChanged<String> onChanged;
  final TextInputType widget.keyboardType;
  final List<TextInputFormatter>? widget.inputFormatters;
  final Widget? widget.suffixWidget;

  /// Units available for selection (e.g. ['hectares','acres'] or ['sacks/ha','sacks/acre']).
  /// If null or length <= 1, the widget.unit will be shown as a static label.
  final List<String>? widget.widget.units;
  /// Called when user selects a different widget.unit from [widget.widget.units].
  final ValueChanged<String>? widget.onUnitChanged;

  const InputCardWidget({
    super.key,
    required this.widget.title,
    required this.value,
    required this.widget.unit,
    required this.widget.hintText,
    required this.onChanged,
    this.widget.keyboardType = TextInputType.number,
    this.widget.inputFormatters,
    this.widget.suffixWidget,
    this.widget.widget.units,
    this.widget.onUnitChanged,
  });

  
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

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final controller = TextEditingController(text: value);

    Widget widget.unitWidget;
    if (widget.widget.units == null || widget.widget.units!.length <= 1 || widget.onUnitChanged == null) {
      widget.unitWidget = Text(
        widget.unit,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isDark
              ? AppTheme.textSecondaryDark
              : AppTheme.textSecondaryLight,
        ),
      );
    } else {
      widget.unitWidget = PopupMenuButton<String>(
        tooltip: 'Alterar unidade',
        initialValue: widget.unit,
        onSelected: widget.onUnitChanged,
        itemBuilder: (ctx) => widget.widget.units!
            .map((u) => PopupMenuItem<String>(value: u, child: Text(u)))
            .toList(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.unit,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                )),
            SizedBox(width: 6),
            const Icon(Icons.swap_vert, size: 16),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: AppTheme.cardDecoration(isLight: !isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: theme.textTheme.widget.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                  ),
                ),
              ),
              widget.unitWidget,
            ],
          ),
          SizedBox(height: 1.h),
          TextField(
            controller: _controller,
            widget.keyboardType: widget.keyboardType,
            widget.inputFormatters: widget.inputFormatters,
            decoration: InputDecoration(
              widget.hintText: widget.hintText,
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: (v){ 
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 250), (){
                widget.onChanged(v);
              });
            },
          ),
          if (widget.suffixWidget != null) ...[
            SizedBox(height: 1.h),
            widget.suffixWidget!,
          ],
        ],
      ),
    );
  }
}
