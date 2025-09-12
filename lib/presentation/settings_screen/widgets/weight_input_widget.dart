import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WeightInputWidget extends StatefulWidget {
  final double currentWeight;
  final Function(double) onWeightChanged;

  const WeightInputWidget({
    super.key,
    required this.currentWeight,
    required this.onWeightChanged,
  });

  @override
  State<WeightInputWidget> createState() => _WeightInputWidgetState();
}

class _WeightInputWidgetState extends State<WeightInputWidget> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentWeight.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: AppTheme.glassmorphismDecoration(isLight: !isDark),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        leading: Container(
          width: 12.w,
          height: 6.h,
          decoration: BoxDecoration(
            color: (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'scale',
              color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
              size: 24,
            ),
          ),
        ),
        title: Text(
          'Kg per Sack Weight',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: _isEditing
            ? _buildEditingField(theme, isDark)
            : _buildDisplayField(theme, isDark),
        trailing: _isEditing
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _saveWeight,
                    icon: CustomIconWidget(
                      iconName: 'check',
                      color:
                          isDark ? AppTheme.successDark : AppTheme.successLight,
                      size: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: _cancelEdit,
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: isDark ? AppTheme.errorDark : AppTheme.errorLight,
                      size: 20,
                    ),
                  ),
                ],
              )
            : IconButton(
                onPressed: _startEdit,
                icon: CustomIconWidget(
                  iconName: 'edit',
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                  size: 20,
                ),
              ),
      ),
    );
  }

  Widget _buildDisplayField(ThemeData theme, bool isDark) {
    return Text(
      '${widget.currentWeight.toStringAsFixed(1)} kg',
      style: theme.textTheme.bodyMedium?.copyWith(
        color:
            isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
      ),
    );
  }

  Widget _buildEditingField(ThemeData theme, bool isDark) {
    return Container(
      width: 30.w,
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
              width: 2,
            ),
          ),
          suffixText: 'kg',
          suffixStyle: theme.textTheme.bodySmall?.copyWith(
            color: isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight,
          ),
        ),
        autofocus: true,
        onSubmitted: (_) => _saveWeight(),
      ),
    );
  }

  void _startEdit() {
    setState(() {
      _isEditing = true;
      _controller.text = widget.currentWeight.toString();
    });
  }

  void _saveWeight() {
    final value = double.tryParse(_controller.text);
    if (value != null && value > 0 && value <= 1000) {
      widget.onWeightChanged(value);
      setState(() {
        _isEditing = false;
      });
    } else {
      _showValidationError();
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _controller.text = widget.currentWeight.toString();
    });
  }

  void _showValidationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please enter a valid weight between 0.1 and 1000 kg'),
        backgroundColor: AppTheme.errorLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
