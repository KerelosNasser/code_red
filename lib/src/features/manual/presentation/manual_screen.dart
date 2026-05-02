import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/dara_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';

class ManualScreen extends StatefulWidget {
  const ManualScreen({super.key});

  @override
  State<ManualScreen> createState() => _ManualScreenState();
}

class _ManualScreenState extends State<ManualScreen> {
  final PdfViewerController _pdfController = PdfViewerController();

  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLoaded = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DaraAppBar(
        title: 'MANUAL',
        actions: [
          // Page indicator chip
          if (_isLoaded)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white30, width: 1),
                ),
                child: Text(
                  '$_currentPage / $_totalPages',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.scaleFont(13),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Branded top band ─────────────────────────────────────────────
          _TopBand(isLoaded: _isLoaded),

          // ── PDF viewer card ──────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                context.scaleWidth(14),
                0,
                context.scaleWidth(14),
                context.scaleWidth(14),
              ),
              child: _PdfCard(
                child: PdfViewer.asset(
                  'assets/sample_manual.pdf',
                  controller: _pdfController,
                  params: PdfViewerParams(
                    onViewerReady: (document, controller) {
                      setState(() {
                        _totalPages = document.pages.length;
                        _isLoaded = true;
                      });
                    },
                    onPageChanged: (pageNumber) {
                      setState(() {
                        _currentPage = pageNumber ?? 1;
                      });
                    },
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .slideY(begin: 0.04, end: 0),
          ),
        ],
      ),
      // ── Page navigation FAB ────────────────────────────────────────────
      floatingActionButton: _isLoaded
          ? _PageNavFab(
              controller: _pdfController,
              currentPage: _currentPage,
              totalPages: _totalPages,
            ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.6, 0.6))
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top brand band
// ─────────────────────────────────────────────────────────────────────────────

class _TopBand extends StatelessWidget {
  final bool isLoaded;
  const _TopBand({required this.isLoaded});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlueDark, AppColors.accentMaroon],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        context.scaleWidth(20),
        10,
        context.scaleWidth(20),
        22,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              color: AppColors.secondaryGold,
              size: context.scaleFont(26),
            ),
          ),
          SizedBox(width: context.scaleWidth(14)),
          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DaRa App Manual',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.scaleFont(16),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isLoaded
                      ? 'Pinch to zoom · Scroll to read'
                      : 'Loading document…',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: context.scaleFont(12),
                  ),
                ),
              ],
            ),
          ),
          // Animated loading dot
          if (!isLoaded)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.secondaryGold,
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.06, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PDF card container — gives the viewer a card feel that matches DaraCard
// ─────────────────────────────────────────────────────────────────────────────

class _PdfCard extends StatelessWidget {
  final Widget child;
  const _PdfCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlueDark.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page navigation FAB (prev / next)
// ─────────────────────────────────────────────────────────────────────────────

class _PageNavFab extends StatelessWidget {
  final PdfViewerController controller;
  final int currentPage;
  final int totalPages;

  const _PageNavFab({
    required this.controller,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondaryGold, AppColors.secondaryGoldDark],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGold.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _NavBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: currentPage > 1
                ? () => controller.goToPage(pageNumber: currentPage - 1)
                : null,
          ),
          Container(
            width: 1,
            height: 28,
            color: Colors.white30,
          ),
          _NavBtn(
            icon: Icons.arrow_forward_ios_rounded,
            onTap: currentPage < totalPages
                ? () => controller.goToPage(pageNumber: currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? Colors.white : Colors.white38,
        ),
      ),
    );
  }
}
