import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/constants.dart';

class BehaviorColorPicker extends StatefulWidget {
  final BehaviorColor initialColor;
  final Function(BehaviorColor) onColorSelected;

  const BehaviorColorPicker({
    Key? key,
    required this.initialColor,
    required this.onColorSelected,
  }) : super(key: key);

  @override
  State<BehaviorColorPicker> createState() => _BehaviorColorPickerState();
}

class _BehaviorColorPickerState extends State<BehaviorColorPicker> {
  late BehaviorColor selectedColor;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.behaviorStatus,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          children: BehaviorColor.values.map((color) {
            final isSelected = selectedColor == color;
            return GestureDetector(
              onTap: () {
                setState(() => selectedColor = color);
                widget.onColorSelected(color);
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(color.colorValue),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 24)
                    : Center(
                        child: Text(
                          color.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class BehaviorColorBadge extends StatelessWidget {
  final BehaviorColor color;
  final double size;

  const BehaviorColorBadge({
    Key? key,
    required this.color,
    this.size = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Color(color.colorValue),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(color.colorValue).withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Tooltip(
        message: color.label,
        child: const SizedBox(),
      ),
    );
  }
}

class BehaviorFilterButton extends StatelessWidget {
  final BehaviorColor color;
  final bool isSelected;
  final VoidCallback onTap;

  const BehaviorFilterButton({
    Key? key,
    required this.color,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? Color(color.colorValue) : Color(color.colorValue).withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          border: Border.all(
            color: Color(color.colorValue),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          color.label,
          style: TextStyle(
            color: isSelected ? Colors.white : Color(color.colorValue),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class RollNumberCard extends StatelessWidget {
  final String rollNumber;
  final BehaviorColor? behaviorColor;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const RollNumberCard({
    Key? key,
    required this.rollNumber,
    this.behaviorColor,
    required this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: behaviorColor != null ? Color(behaviorColor!.colorValue).withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: behaviorColor != null ? Color(behaviorColor!.colorValue) : AppColors.lightGrey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                rollNumber,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDarkBlue,
                    ),
              ),
            ),
            if (behaviorColor != null)
              Positioned(
                top: 4,
                right: 4,
                child: BehaviorColorBadge(color: behaviorColor!, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType inputType;
  final int maxLines;
  final String? Function(String?)? validator;
  final bool isRequired;

  const CustomTextField({
    Key? key,
    required this.label,
    this.hint,
    required this.controller,
    this.inputType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.isRequired = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            children: isRequired
                ? [
                    TextSpan(
                      text: ' *',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          maxLines: maxLines,
          minLines: 1,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.md),
          ),
        ),
      ],
    );
  }
}

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double width;
  final bool isLoading;
  final IconData? icon;

  const CustomButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = AppColors.primaryBlue,
    this.textColor = Colors.white,
    this.width = double.infinity,
    this.isLoading = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
        ),
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : (icon != null ? Icon(icon, color: textColor) : const SizedBox.shrink()),
        label: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: AppFontSize.md,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color backgroundColor;
  final IconData icon;

  const StatCard({
    Key? key,
    required this.label,
    required this.value,
    this.backgroundColor = AppColors.primaryLightBlue,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 28),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDarkBlue,
                ),
          ),
        ],
      ),
    );
  }
}

class DialogUtil {
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String positiveButtonLabel = 'Yes',
    String negativeButtonLabel = 'No',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(negativeButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              positiveButtonLabel,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
