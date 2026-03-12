import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto_wallet/core/constants/app_colors.dart';
import 'package:crypto_wallet/core/constants/app_sizes.dart';
import 'package:crypto_wallet/shared/widgets/app_button.dart';
import 'package:crypto_wallet/shared/widgets/app_card.dart';
import 'package:crypto_wallet/features/transfer/presentation/providers/transfer_provider.dart';
import 'package:crypto_wallet/features/wallet/presentation/providers/wallet_provider.dart';

/// Receive BTC page
class ReceivePage extends ConsumerStatefulWidget {
  const ReceivePage({super.key});

  @override
  ConsumerState<ReceivePage> createState() => _ReceivePageState();
}

class _ReceivePageState extends ConsumerState<ReceivePage> {
  @override
  Widget build(BuildContext context) {
    final transferState = ref.watch(transferNotifierProvider);
    final walletAsync = ref.watch(userWalletProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive BTC'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions
            const Text(
              'Share this address to receive BTC',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppSizes.textBody,
                color: AppColors.secondLabel,
              ),
            ),
            const SizedBox(height: AppSizes.spacing24),

            // QR Code placeholder
            walletAsync.when(
              data: (wallet) => AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.spacing24),
                  child: Column(
                    children: [
                      // QR Code placeholder
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSizes.radius12),
                          border: Border.all(
                            color: AppColors.surface,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.radius12),
                          child: CustomPaint(
                            painter: _QRCodePlaceholderPainter(),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacing16),

                      // BTC Address
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSizes.spacing12),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(AppSizes.radius8),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Your BTC Address',
                              style: TextStyle(
                                fontSize: AppSizes.textCaption,
                                color: AppColors.secondLabel,
                              ),
                            ),
                            const SizedBox(height: AppSizes.spacing4),
                            Text(
                              wallet.btcAddress,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: AppSizes.textFootnote,
                                color: AppColors.label,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              loading: () => const AppCard(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              error: (e, s) => AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.spacing24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.danger,
                        size: 48,
                      ),
                      const SizedBox(height: AppSizes.spacing16),
                      Text(
                        'Failed to load wallet',
                        style: TextStyle(color: AppColors.danger),
                      ),
                      const SizedBox(height: AppSizes.spacing16),
                      AppButton(
                        text: 'Retry',
                        onPressed: () => ref.invalidate(userWalletProvider),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacing24),

            // Copy address button
            AppButton(
              text: 'Copy Address',
              type: AppButtonType.secondary,
              size: AppButtonSize.medium,
              fullWidth: true,
              icon: const Icon(Icons.copy),
              onPressed: _copyAddress,
            ),
            const SizedBox(height: AppSizes.spacing16),

            // Share button
            AppButton(
              text: 'Share',
              type: AppButtonType.primary,
              size: AppButtonSize.medium,
              fullWidth: true,
              icon: const Icon(Icons.share),
              onPressed: _shareAddress,
            ),

            // Success snackbar for copy
            if (transferState.recipientAddress != null) ...[
              const SizedBox(height: AppSizes.spacing16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacing12,
                  vertical: AppSizes.spacing8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radius8),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: AppColors.success,
                      size: 20,
                    ),
                    SizedBox(width: AppSizes.spacing8),
                    Expanded(
                      child: Text(
                        'Address copied to clipboard',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: AppSizes.textFootnote,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Warning notice
            const SizedBox(height: AppSizes.spacing24),
            Container(
              padding: const EdgeInsets.all(AppSizes.spacing12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radius8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_outlined,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: AppSizes.spacing8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Important',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.warning,
                            fontSize: AppSizes.textCaption,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacing4),
                        const Text(
                          'Only send Bitcoin (BTC) to this address. Sending other assets may result in permanent loss.',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: AppSizes.textFootnote,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyAddress() {
    final wallet = ref.read(userWalletProvider).value;
    if (wallet != null) {
      Clipboard.setData(ClipboardData(text: wallet.btcAddress));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Address copied to clipboard'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _shareAddress() {
    final wallet = ref.read(userWalletProvider).value;
    if (wallet != null) {
      // TODO: Implement share functionality
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Share coming soon')),
      );
    }
  }
}

/// Placeholder QR code painter
class _QRCodePlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.btcOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final iconSize = size.width * 0.3;

    // Draw Bitcoin icon placeholder
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '₿',
        style: TextStyle(
          fontSize: 80,
          color: AppColors.btcOrange,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    // Draw border pattern (mock QR code)
    final cellSize = size.width / 10;
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 10; j++) {
        // Skip center area (where BTC icon is)
        if (i >= 3 && i <= 6 && j >= 3 && j <= 6) continue;

        // Draw random cells for QR code effect
        if ((i + j) % 3 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(
              i * cellSize + cellSize * 0.2,
              j * cellSize + cellSize * 0.2,
              cellSize * 0.6,
              cellSize * 0.6,
            ),
            Paint()..color = AppColors.btcOrange.withOpacity(0.3),
          );
        }
      }
    }

    // Draw corner markers
    _drawCornerMarker(canvas, size, Offset.zero, paint);
    _drawCornerMarker(
      canvas,
      size,
      Offset(size.width - cellSize * 3, 0),
      paint,
    );
    _drawCornerMarker(
      canvas,
      size,
      Offset(0, size.height - cellSize * 3),
      paint,
    );
  }

  void _drawCornerMarker(Canvas canvas, Size size, Offset offset, Paint paint) {
    final cellSize = size.width / 10;
    final markerSize = cellSize * 3;

    // Outer square
    canvas.drawRect(
      Rect.fromLTWH(offset.dx, offset.dy, markerSize, markerSize),
      paint,
    );

    // Inner square
    canvas.drawRect(
      Rect.fromLTWH(
        offset.dx + cellSize,
        offset.dy + cellSize,
        cellSize,
        cellSize,
      ),
      Paint()..color = AppColors.btcOrange,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
