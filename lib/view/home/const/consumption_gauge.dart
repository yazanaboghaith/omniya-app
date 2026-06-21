import 'package:flutter/material.dart';
import 'package:omniya/const/app_color.dart';
import 'package:omniya/l10n/app_localizations.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class ConsumptionGauge extends StatelessWidget {
  final double value;

  const ConsumptionGauge({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gaugeWidth = screenWidth * 0.45;
    final gaugeHeight = gaugeWidth * 0.65;

    return SizedBox(
      height: gaugeHeight,
      width: gaugeWidth,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 0,
            maximum: 100,
            showLabels: false,
            showTicks: false,
            startAngle: 270,
            endAngle: 270,
            axisLineStyle: AxisLineStyle(
              thickness: 0.15,
              color: isDark
                  ? AppColors.text(context).withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.08),
              thicknessUnit: GaugeSizeUnit.factor,
            ),
            pointers: <GaugePointer>[
              RangePointer(
                value: value,
                width: 0.15,
                sizeUnit: GaugeSizeUnit.factor,
                enableAnimation: true,
                animationDuration: 1200,
                color: AppColors.speed,
                animationType: AnimationType.easeOutBack,
                cornerStyle: CornerStyle.bothCurve,
              ),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                positionFactor: 0.1,
                angle: 90,
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${value.toStringAsFixed(1)}%',
                      style: AppTextStyles.text17Bold(context),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.usage,
                      style: AppTextStyles.text13Grey(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
