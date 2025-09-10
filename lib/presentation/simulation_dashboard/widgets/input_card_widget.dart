import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class InputCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String hintText;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixWidget;

  /// Units available for selection (e.g. ['hectares','acres'] or ['sacks/ha','sacks/acre']).
  /// If null or length <= 1, the unit will be shown as a static label.
  final List<String>? units;
  /// Called when user selects a different unit from [units].
  final ValueChanged<String>? onUnitChanged;

  const InputCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.hintText,
    required this.onChanged,
    this.keyboardType = TextInputType.number,
    this.inputFormatters,
    this.suffixWidget,
    this.units,
    this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final controller = TextEditingController(text: value);

    Widget unitWidget;
    if (units == null || units!.length <= 1 || onUnitChanged == null) {
      unitWidget = Text(
        unit,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isDark
              ? AppTheme.textSecondaryDark
              : AppTheme.textSecondaryLight,
        ),
      );
    } else {
      unitWidget = PopupMenuButton<String>(
        tooltip: 'Alterar unidade',
        initialValue: unit,
        onSelected: onUnitChanged,
        itemBuilder: (ctx) => units!
            .map((u) => PopupMenuItem<String>(value: u, child: Text(u)))
            .toList(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(unit,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                )),
            const SizedBox(width: 6),
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
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                  ),
                ),
              ),
              unitWidget,
            ],
          ),
          SizedBox(height: 1.h),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hintText,
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: onChanged,
          ),
          if (suffixWidget != null) ...[
            SizedBox(height: 1.h),
            suffixWidget!,
          ],
        ],
      ),
    );
  }
}
