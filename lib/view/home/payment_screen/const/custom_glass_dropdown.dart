import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:omniya/const/app_color.dart';

class CustomGlassDropdown<T> extends StatefulWidget {
  final List<T> items;
  final T? selectedItem;
  final String hint;
  final String Function(T) itemAsString;
  final ValueChanged<T?> onChanged;
  final bool isLoading;

  const CustomGlassDropdown({
    super.key,
    required this.items,
    this.selectedItem,
    required this.hint,
    required this.itemAsString,
    required this.onChanged,
    this.isLoading = false,
  });

  @override
  State<CustomGlassDropdown<T>> createState() => _CustomGlassDropdownState<T>();
}

class _CustomGlassDropdownState<T> extends State<CustomGlassDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (widget.isLoading || widget.items.isEmpty) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeDropdown,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 8),
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: size.width,
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.text(context).withValues(alpha: 0.15),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      color: AppColors.text(context).withValues(alpha: 0.1),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: widget.items.length,
                        itemBuilder: (context, index) {
                          final item = widget.items[index];
                          final isSelected = item == widget.selectedItem;
                          return InkWell(
                            onTap: () {
                              widget.onChanged(item);
                              _closeDropdown();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.2)
                                  : Colors.transparent,
                              child: Center(
                                child: Text(
                                  widget.itemAsString(item),
                                  style: TextStyle(
                                    color: AppColors.text(context),
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() => _isOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = widget.selectedItem;

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.text(context).withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.01),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: AppColors.text(context).withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: widget.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        selected == null
                            ? widget.hint
                            : widget.itemAsString(selected),
                        style: TextStyle(
                          color: widget.selectedItem != null
                              ? AppColors.text(context)
                              : AppColors.text(context).withValues(alpha: 0.5),
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              Icon(
                _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: AppColors.text(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
