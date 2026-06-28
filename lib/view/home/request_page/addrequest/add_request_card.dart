import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:omniya/core/l10n/app_localizations.dart';
import 'package:omniya/model/service_package.dart';
import 'package:provider/provider.dart';
import 'package:omniya/core/const/app_color.dart';
import 'package:omniya/view/home/payment_screen/const/custom_glass_dropdown.dart';
import 'package:omniya/view/home/request_page/addrequest/controller/add_request_controller.dart';

class AddRequestCard extends StatefulWidget {
  final ServicePackage? selectedPackage;
  final ValueChanged<ServicePackage?> onPackageChanged;

  const AddRequestCard({
    super.key,
    required this.selectedPackage,
    required this.onPackageChanged,
  });

  @override
  State<AddRequestCard> createState() => _AddRequestCardState();
}

class _AddRequestCardState extends State<AddRequestCard> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final l10 = AppLocalizations.of(context)!;

    return Consumer<AddonServiceController>(
      builder: (context, controller, _) {
        final package = widget.selectedPackage;

        final bool isEnabled = package != null;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(w * 0.05 < 24 ? w * 0.05 : 24),
          decoration: _glassDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10.add_request, style: AppTextStyles.text19Bold(context)),
              SizedBox(height: w * 0.04),
              Text(l10.request_type, style: AppTextStyles.text15(context)),
              const SizedBox(height: 6),
              if (controller.isPackagesLoading)
                const Center(child: CircularProgressIndicator())
              else if (controller.servicePackages.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                    border:
                        Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    controller.packagesError ?? l10.no_packages,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.text15(context)
                        .copyWith(color: Colors.redAccent),
                  ),
                )
              else
                CustomGlassDropdown<ServicePackage>(
                  items: controller.servicePackages,
                  selectedItem: widget.selectedPackage,
                  hint: l10.choose_request_type,
                  itemAsString: (item) => item.name,
                  onChanged: widget.onPackageChanged,
                ),
              SizedBox(height: w * 0.06),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEnabled
                        ? Colors.green.withValues(alpha: 0.6)
                        : Colors.grey.withValues(alpha: 0.15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: isEnabled
                      ? () {
                          _showConfirmDialog(context, package);
                        }
                      : null,
                  child: Text(l10.add_request_button),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showConfirmDialog(
    BuildContext pageContext,
    ServicePackage package,
  ) {
    bool loading = false;
    bool showResult = false;
    String message = "";

    final l10 = AppLocalizations.of(pageContext)!;
    return showDialog(
      context: pageContext,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Dialog(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showResult) ...[
                        Text(message,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.text15(context)),
                      ] else if (loading) ...[
                        const CircularProgressIndicator(),
                        const SizedBox(height: 15),
                        Text(l10.loading_sending),
                      ] else ...[
                        Text(
                          l10.confirm_request_title,
                          style: AppTextStyles.text19Bold(context),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          l10.confirm_request_message(package.name),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.text15(context),
                        ),
                        const SizedBox(height: 25),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.green.withValues(alpha: 0.6),
                                ),
                                onPressed: () async {
                                  setState(() => loading = true);

                                  String serverMessage = "";

                                  try {
                                    if (package.actions.isEmpty) {
                                      throw Exception(l10.error);
                                    }

                                    final itemAction = package.actions.first;
                                    final action =
                                        itemAction.create ?? itemAction.remove;

                                    if (action == null || action.url.isEmpty) {
                                      throw Exception(l10.error);
                                    }

                                    String secureUrl = action.url
                                        .replaceAll("http://", "https://");

                                    final res = await context
                                        .read<AddonServiceController>()
                                        .apiClient
                                        .post(
                                      Uri.parse(secureUrl),
                                      {
                                        ...action.body,
                                        "new_service_id": package.id,
                                      },
                                    );
                                    final body = json.decode(res.body);

                                    serverMessage = body["message"] ??
                                        body["error"] ??
                                        l10.error;
                                  } catch (e) {
                                    serverMessage = e.toString();
                                  }

                                  setState(() {
                                    loading = false;
                                    showResult = true;
                                    message = serverMessage;
                                  });

                                  final controller =
                                      context.read<AddonServiceController>();

                                  await Future.delayed(
                                      const Duration(seconds: 1));

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    await controller.refreshServicePackages();
                                    widget.onPackageChanged(null);
                                  }
                                },
                                child: Text(l10.confirm),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white24,
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: Text(l10.cancel),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

BoxDecoration _glassDecoration(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final w = MediaQuery.of(context).size.width;

  return BoxDecoration(
    borderRadius: BorderRadius.circular(w * 0.07),
    border: Border.all(
      width: 1,
      color: AppColors.text(context).withValues(alpha: 0.1),
    ),
    color: isDark
        ? AppColors.text(context).withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.04),
  );
}
