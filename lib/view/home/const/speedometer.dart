import 'package:flutter/material.dart';
import 'package:omniya/const/app_color.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SpeedometerWidget extends StatelessWidget {
  final String speedText; // بدل double

  const SpeedometerWidget({
    super.key,
    required this.speedText,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gaugeWidth = screenWidth * 0.45;
    final gaugeHeight = gaugeWidth * 0.65;

    const double maxSpeed = 100;
    return SizedBox(
      height: gaugeHeight,
      width: gaugeWidth,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 0,
            maximum: maxSpeed,
            showLabels: false,
            showTicks: true,
            startAngle: 180,
            endAngle: 0,
            radiusFactor: 1,
            canScaleToFit: true,

            majorTickStyle: MajorTickStyle(
              length: gaugeWidth * 0.04,
              thickness: 2,
              color: AppColors.speed,
            ),
            minorTicksPerInterval: 0,
            interval: 20,

            axisLineStyle: AxisLineStyle(
              thickness: 0.22,
              color: isDark
                  ? AppColors.text(context).withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              thicknessUnit: GaugeSizeUnit.factor,
            ),
            pointers: <GaugePointer>[
              RangePointer(
                value: maxSpeed,
                width: 0.22,
                sizeUnit: GaugeSizeUnit.factor,
                enableAnimation: true,
                animationDuration: 500,
                color: AppColors.speed,
                dashArray: const <double>[39, 1],
              ),
            ],

            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                positionFactor: 0.05,
                angle: 90,
                widget: Transform.translate(
                  offset: Offset(0, -gaugeHeight * 0.14),
                  child: Text(
                    speedText,
                    style: TextStyle(
                      color: AppColors.text(context),
                      fontSize: gaugeWidth * 0.08,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
