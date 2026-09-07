import 'package:flutter/material.dart';
import 'package:omniya/core/const/app_color.dart';
import 'package:omniya/core/l10n/app_localizations.dart';

class RouterValuesWidget extends StatelessWidget {
  final Map<String, String?> values;
  final String? downstreamCrc;

  const RouterValuesWidget({
    super.key,
    required this.values,
    required this.downstreamCrc,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final downstreamRate = _formatRate(
      values['downstreamRate'],
    );

    final upstreamRate = _formatRate(
      values['upstreamRate'],
    );

    final downstreamSnr = _formatDb(
      values['downstreamSnr'],
    );

    final upstreamSnr = _formatDb(
      values['upstreamSnr'],
    );

    final downstreamAttenuation = _formatDb(
      values['downstreamAttenuation'],
    );

    final upstreamAttenuation = _formatDb(
      values['upstreamAttenuation'],
    );

    return _sectionCard(
      context: context,
      title: l10n.router_line_quality,
      subtitle: l10n.router_current_connection_data,
      icon: Icons.speed_rounded,
      iconColor: AppColors.speed,
      child: Column(
        children: [
          _mainSpeedCard(
            context,
            downstreamRate,
            upstreamRate,
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 850) {
                return _fourColumns(
                  context,
                  downstreamSnr,
                  upstreamSnr,
                  downstreamAttenuation,
                  upstreamAttenuation,
                );
              }

              if (constraints.maxWidth >= 520) {
                return _twoColumns(
                  context,
                  downstreamSnr,
                  upstreamSnr,
                  downstreamAttenuation,
                  upstreamAttenuation,
                );
              }

              return _smallColumns(
                context,
                downstreamSnr,
                upstreamSnr,
                downstreamAttenuation,
                upstreamAttenuation,
              );
            },
          ),
          const SizedBox(height: 12),
          _crcCard(
            context,
            downstreamCrc,
          ),
        ],
      ),
    );
  }

  Widget _fourColumns(
    BuildContext context,
    String downstreamSnr,
    String upstreamSnr,
    String downstreamAttenuation,
    String upstreamAttenuation,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.15,
      children: [
        _statCard(
          context,
          AppLocalizations.of(context)!.router_downstream_snr,
          downstreamSnr,
          Icons.signal_cellular_alt_rounded,
        ),
        _statCard(
          context,
          AppLocalizations.of(context)!.router_upstream_snr,
          upstreamSnr,
          Icons.signal_cellular_alt_rounded,
        ),
        _statCard(
          context,
          AppLocalizations.of(context)!.router_downstream_attenuation,
          downstreamAttenuation,
          Icons.network_check_rounded,
        ),
        _statCard(
          context,
          AppLocalizations.of(context)!.router_upstream_attenuation,
          upstreamAttenuation,
          Icons.network_check_rounded,
        ),
      ],
    );
  }

  Widget _twoColumns(
    BuildContext context,
    String downstreamSnr,
    String upstreamSnr,
    String downstreamAttenuation,
    String upstreamAttenuation,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.45,
      children: [
        _statCard(
          context,
          AppLocalizations.of(context)!.router_downstream_snr,
          downstreamSnr,
          Icons.signal_cellular_alt_rounded,
        ),
        _statCard(
          context,
          AppLocalizations.of(context)!.router_upstream_snr,
          upstreamSnr,
          Icons.signal_cellular_alt_rounded,
        ),
        _statCard(
          context,
          AppLocalizations.of(context)!.router_downstream_attenuation,
          downstreamAttenuation,
          Icons.network_check_rounded,
        ),
        _statCard(
          context,
          AppLocalizations.of(context)!.router_upstream_attenuation,
          upstreamAttenuation,
          Icons.network_check_rounded,
        ),
      ],
    );
  }

  Widget _smallColumns(
    BuildContext context,
    String downstreamSnr,
    String upstreamSnr,
    String downstreamAttenuation,
    String upstreamAttenuation,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                context,
                "Snr Downstream",
                downstreamSnr,
                Icons.signal_cellular_alt_rounded,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _statCard(
                context,
                "Snr upstream",
                upstreamSnr,
                Icons.signal_cellular_alt_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _statCard(
                context,
                "Attenuation Downstream",
                downstreamAttenuation,
                Icons.network_check_rounded,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _statCard(
                context,
                "Attenuation Upstream",
                upstreamAttenuation,
                Icons.network_check_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _mainSpeedCard(
    BuildContext context,
    String download,
    String upload,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.speed,
            AppColors.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            l10n.router_current_connection_speed,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _speedValue(
                  icon: Icons.download_rounded,
                  title: "Download",
                  value: download,
                ),
              ),
              Container(
                width: 1,
                height: 55,
                color: Colors.white.withValues(alpha: .15),
              ),
              Expanded(
                child: _speedValue(
                  icon: Icons.upload_rounded,
                  title: "Uplpoad",
                  value: upload,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _speedValue({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
        const SizedBox(height: 7),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: .04)
            : Colors.white.withValues(alpha: .65),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: .07),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.speed.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.speed,
              size: 19,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.text10Grey(context),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTextStyles.text15(
                context,
                isBold: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _crcCard(
    BuildContext context,
    String? value,
  ) {
    // final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withValues(alpha: .5),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.wifi_tethering_error_rounded,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            "Crc Error",
            style: AppTextStyles.text15(
              context,
              isBold: true,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _formatCrc(value),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF171722) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: .07)
              : AppColors.primary.withValues(alpha: .075),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.text17Bold(context),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.text13Grey(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  String _formatCrc(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '--';
    }

    final match = RegExp(r'\d+').firstMatch(value);

    return match?.group(0) ?? '--';
  }

  String _formatDb(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '--';
    }

    final match = RegExp(
      r'-?\d+(?:\.\d+)?',
    ).firstMatch(value);

    if (match == null) {
      return '--';
    }

    final number = double.tryParse(
      match.group(0)!,
    );

    if (number == null) {
      return '--';
    }

    return '${number.toStringAsFixed(number % 1 == 0 ? 0 : 1)} dB';
  }

  String _formatRate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '--';
    }

    var raw = value.trim().toLowerCase();
    raw = raw.replaceAll(',', '');

    final match = RegExp(
      r'^(-?\d+(?:\.\d+)?)\s*(kbps|mbps|kbit/s|mbit/s)?$',
      caseSensitive: false,
    ).firstMatch(raw);

    if (match == null) {
      final numberMatch = RegExp(
        r'-?\d+(?:\.\d+)?',
      ).firstMatch(raw);

      if (numberMatch == null) {
        return '--';
      }

      final number = double.tryParse(
        numberMatch.group(0)!,
      );

      if (number == null) {
        return '--';
      }

      return _formatMbps(number / 1000);
    }

    final number = double.tryParse(
      match.group(1)!,
    );

    if (number == null) {
      return '--';
    }

    final unit = match.group(2)?.toLowerCase();

    if (unit == 'mbps' || unit == 'mbit/s') {
      return _formatMbps(number);
    }

    return _formatMbps(number / 1000);
  }

  String _formatMbps(double value) {
    return value >= 10
        ? '${value.toStringAsFixed(1)} Mbps'
        : '${value.toStringAsFixed(2)} Mbps';
  }
}

class RouterStatisticsLoadingWidget extends StatelessWidget {
  const RouterStatisticsLoadingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF171722)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            l10n.router_line_quality,
            style: AppTextStyles.text17Bold(context),
          ),
          const SizedBox(height: 20),
          CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.speed,
          ),
          const SizedBox(height: 14),
          Text(
            l10n.router_reading_router_data,
            style: AppTextStyles.text13Grey(context),
          ),
        ],
      ),
    );
  }
}
