import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:omniya/core/const/app_color.dart';
import 'package:omniya/core/l10n/app_localizations.dart';
import 'package:omniya/model/setting/router_model.dart';
import 'package:omniya/view/home/router_setting/router/const/router_model_tile.dart';

class RouterModelsSheet extends StatelessWidget {
  final List<RouterModel> routers;

  final Future<void> Function(
    RouterModel router,
  ) onRouterSelected;

  const RouterModelsSheet({
    super.key,
    required this.routers,
    required this.onRouterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final maxWidth = width >= 900 ? 700.0 : 600.0;
    final horizontalPadding = width >= 600 ? 24.0 : 16.0;
    final containerPadding = width >= 600 ? 24.0 : 18.0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: horizontalPadding,
          right: horizontalPadding,
          bottom: 16,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(30),
            bottom: Radius.circular(30),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 15,
              sigmaY: 5,
            ),
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: size.height * 0.85,
              ),
              padding: EdgeInsets.all(containerPadding),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: isDark
                    ? AppColors.text(context).withValues(alpha: 0.20)
                    : Colors.grey.withValues(
                        alpha: 0.80,
                      ),
                border: Border.all(
                  color: AppColors.text(context).withValues(alpha: 0.20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _SheetHandle(),
                  const SizedBox(
                    height: 20,
                  ),
                  RouterModelsSheetHeader(
                    onClose: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  Divider(
                    color: AppColors.text(context).withValues(alpha: 0.20),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                      ),
                      itemCount: routers.length,
                      separatorBuilder: (_, __) {
                        return const SizedBox(
                          height: 10,
                        );
                      },
                      itemBuilder: (context, index) {
                        final router = routers[index];

                        return RouterModelTile(
                          router: router,
                          onTap: () async {
                            await onRouterSelected(
                              router,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 5,
      decoration: BoxDecoration(
        color: AppColors.text(context).withValues(alpha: 0.50),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class RouterModelsSheetHeader extends StatelessWidget {
  final VoidCallback onClose;

  const RouterModelsSheetHeader({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;
    final iconBoxSize = width >= 600 ? 52.0 : 48.0;
    final iconSize = width >= 600 ? 27.0 : 25.0;
    final titleSize = width >= 600 ? 20.0 : 18.0;

    return Row(
      children: [
        Container(
          width: iconBoxSize,
          height: iconBoxSize,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.95),
                AppColors.secondary.withValues(alpha: 0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.20),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            Icons.router_rounded,
            color: Colors.white,
            size: iconSize,
          ),
        ),
        const SizedBox(
          width: 14,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.router_choose_model,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.text(context),
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                l10n.router_choose_model_subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.grey(context),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onClose,
          icon: Icon(
            Icons.close_rounded,
            color: AppColors.grey(context),
          ),
        ),
      ],
    );
  }
}
