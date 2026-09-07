import 'package:flutter/material.dart';
import 'package:omniya/core/const/app_color.dart';
import 'package:omniya/model/setting/router_model.dart';
import 'package:omniya/view/home/router_setting/router/const/brand_card.dart';
import 'router_selection_header.dart';

class RouterBrandContent extends StatelessWidget {
  final List<RouterBrand> brands;
  final Future<void> Function() onRefresh;
  final Future<void> Function(RouterBrand brand) onBrandSelected;

  const RouterBrandContent({
    super.key,
    required this.brands,
    required this.onRefresh,
    required this.onBrandSelected,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final horizontalPadding = width >= 900
              ? 40.0
              : width >= 600
                  ? 30.0
                  : width < 360
                      ? 14.0
                      : 18.0;
          final spacing = width >= 600 ? 20.0 : 14.0;
          final columns = width < 360
              ? 1
              : width >= 1000
                  ? 4
                  : width >= 650
                      ? 3
                      : 2;
          final ratio = width >= 1000
              ? 1.05
              : width >= 650
                  ? 1.0
                  : width < 360
                      ? 0.82
                      : 0.9;

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              20,
              horizontalPadding,
              30,
            ),
            children: [
              const RouterSelectionHeader(),
              const SizedBox(height: 24),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1100,
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      childAspectRatio: ratio,
                    ),
                    itemCount: brands.length,
                    itemBuilder: (context, index) {
                      final brand = brands[index];

                      return BrandCard(
                        brand: brand,
                        onTap: () => onBrandSelected(brand),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
