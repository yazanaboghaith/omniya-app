import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:omniya/model/services_response.dart';
import 'package:omniya/view/home/request_page/addrequest/controller/add_request_controller.dart';
import 'package:omniya/const/app_color.dart';
import 'package:omniya/view/home/payment_screen/const/custom_glass_dropdown.dart';

class AddRequestCard extends StatefulWidget {
  final AddonServiceModel? selectedRequestType;
  final ValueChanged<AddonServiceModel?> onRequestTypeChanged;
  final VoidCallback onSubmit;
  final bool isFormValid;

  const AddRequestCard({
    super.key,
    required this.selectedRequestType,
    required this.onRequestTypeChanged,
    required this.onSubmit,
    required this.isFormValid,
  });

  @override
  State<AddRequestCard> createState() => _AddRequestCardState();
}

class _AddRequestCardState extends State<AddRequestCard> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddonServiceController>().getAddonServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Consumer<AddonServiceController>(
      builder: (context, controller, _) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(w * 0.05 < 24 ? w * 0.05 : 24),
          decoration: _glassDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("إضافة طلب", style: AppTextStyles.text19Bold(context)),
              SizedBox(height: w * 0.04),
              Text("نوع الطلب", style: AppTextStyles.text15(context)),
              const SizedBox(height: 6),
              controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomGlassDropdown<AddonServiceModel>(
                      isLoading: false,
                      items: controller.addons,
                      selectedItem: widget.selectedRequestType,
                      hint: "اختر نوع الطلب",
                      itemAsString: (item) => item.name,
                      onChanged: widget.onRequestTypeChanged,
                    ),
              SizedBox(height: w * 0.06),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isFormValid
                        ? Colors.green.withValues(alpha: 0.6)
                        : Colors.grey.withOpacity(0.15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: widget.isFormValid ? widget.onSubmit : null,
                  child: const Text("إضافة طلب"),
                ),
              ),
            ],
          ),
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
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.03),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
    color: isDark
        ? AppColors.text(context).withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.04),
  );
}
