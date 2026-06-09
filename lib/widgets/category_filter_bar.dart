import 'package:flutter/material.dart';

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
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: Material(
              color: isSelected ? AppleColors.label : AppleColors.card,
              borderRadius: BorderRadius.circular(20),
              elevation: isSelected ? 0 : 0,
              shadowColor: Colors.transparent,
              child: InkWell(
                onTap: () => onSelected(category),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppleColors.label
                          : AppleColors.separator.withValues(alpha: 0.6),
                    ),
                    boxShadow: isSelected
                        ? null
                        : const [
                            BoxShadow(
                              color: Color(0x05000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Text(
                    category,
                    style: AppleTextStyles.footnote.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : AppleColors.label,
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
