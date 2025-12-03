import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MaraCodeInput extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool autoFocus;

  const MaraCodeInput({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.autoFocus = true,
  });

  @override
  State<MaraCodeInput> createState() => MaraCodeInputState();
}

class MaraCodeInputState extends State<MaraCodeInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FocusScope.of(context).requestFocus(_focusNode);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<String> get _digits {
    final text = _controller.text;
    return List.generate(widget.length, (i) => i < text.length ? text[i] : '');
  }

  String get value => _controller.text;

  void clear() {
    _controller.clear();
    setState(() {});
    focus();
  }

  void focus() {
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void _handleChanged(String value) {
    setState(() {});
    widget.onChanged?.call(value);
    if (value.length == widget.length) {
      widget.onCompleted?.call(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 0,
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              maxLength: widget.length,
              autofillHints: const [AutofillHints.oneTimeCode],
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
              ),
              onChanged: _handleChanged,
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: focus,
          behavior: HitTestBehavior.translucent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(widget.length, (index) {
              final digit = _digits[index];
              final isActive = _controller.text.length == index;
              return Container(
                width: 48,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? AppColors.languageButtonColor
                        : AppColors.borderColor,
                    width: 1.5,
                  ),
                  color: Colors.white,
                ),
                child: Text(
                  digit,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
