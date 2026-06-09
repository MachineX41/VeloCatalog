import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/apple_theme.dart';

class CategoryFilterBar extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const CategoryFilterBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return AnimatedScale(
            scale: isSelected ? 1 : 0.98,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: isSelected ? AppleColors.label : AppleColors.card,
                borderRadius: BorderRadius.circular(19),
                border: Border.all(
                  color: isSelected
                      ? AppleColors.label
                      : AppleColors.separator.withValues(alpha: 0.5),
                ),
                boxShadow: isSelected
                    ? null
                    : const [
                        BoxShadow(
                          color: Color(0x04000000),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (!isSelected) {
                      HapticFeedback.selectionClick();
                      onSelected(category);
                    }
                  },
                  borderRadius: BorderRadius.circular(19),
                  splashColor: isSelected
                      ? Colors.transparent
                      : AppleColors.blue.withValues(alpha: 0.08),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        style: AppleTextStyles.footnote.copyWith(
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected ? Colors.white : AppleColors.label,
                        ),
                        child: Text(category),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
