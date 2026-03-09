import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  Asosiy shimmer animatsiya engine
// ─────────────────────────────────────────────
class _ShimmerBase extends StatefulWidget {
  final Widget child;
  const _ShimmerBase({required this.child});

  @override
  State<_ShimmerBase> createState() => _ShimmerBaseState();
}

class _ShimmerBaseState extends State<_ShimmerBase>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(_anim.value - 1, 0),
              end: Alignment(_anim.value, 0),
              colors: const [
                Color(0xFFEEEEEE),
                Color(0xFFE0E0E0),
                Color(0xFFF5F5F5),
                Color(0xFFE0E0E0),
                Color(0xFFEEEEEE),
              ],
              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ─────────────────────────────────────────────
//  Yordamchi: to'ldirilgan quti (placeholder)
// ─────────────────────────────────────────────
class _Box extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _Box({
    this.width = double.infinity,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TripCard shimmer (booking & driver trip)
// ─────────────────────────────────────────────
class TripCardShimmer extends StatelessWidget {
  const TripCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return _ShimmerBase(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chiziq (status indicator)
                Container(
                  width: 3.5,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(width: 10),
                // Manzillar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const _Box(width: 16, height: 16, radius: 99),
                          const SizedBox(width: 6),
                          const Expanded(child: _Box(height: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const _Box(width: 16, height: 16, radius: 99),
                          const SizedBox(width: 6),
                          const Expanded(child: _Box(height: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Narx chip
                const _Box(width: 72, height: 28, radius: 99),
              ],
            ),
            const SizedBox(height: 12),
            // Meta chips (sana, vaqt, o'rindiq)
            Row(
              children: [
                const _Box(width: 80, height: 26, radius: 99),
                const SizedBox(width: 10),
                const _Box(width: 64, height: 26, radius: 99),
                const SizedBox(width: 10),
                const _Box(width: 48, height: 26, radius: 99),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MyTripCard shimmer (haydovchi o'z triplari)
// ─────────────────────────────────────────────
class MyTripCardShimmer extends StatelessWidget {
  const MyTripCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return _ShimmerBase(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header qatori
            Row(
              children: [
                const Expanded(child: _Box(height: 14)),
                const SizedBox(width: 12),
                const _Box(width: 72, height: 26, radius: 99),
              ],
            ),
            const SizedBox(height: 10),
            // Manzillar
            const _Box(height: 14),
            const SizedBox(height: 6),
            const _Box(height: 14, width: 200),
            const SizedBox(height: 10),
            // Meta chips
            Row(
              children: [
                const _Box(width: 80, height: 26, radius: 99),
                const SizedBox(width: 10),
                const _Box(width: 64, height: 26, radius: 99),
                const SizedBox(width: 10),
                const _Box(width: 48, height: 26, radius: 99),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Butun sahifa uchun shimmer ListView
//  (HomeLoading / HomeInitial holatida ko'rsatiladi)
// ─────────────────────────────────────────────
class HomeShimmerList extends StatelessWidget {
  /// [showMyTripsSection] — "Mening buyurtmalarim" bo'limini ham ko'rsatish
  final bool showMyTripsSection;

  const HomeShimmerList({super.key, this.showMyTripsSection = false});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Tab bar skeleton
        Container(
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: _ShimmerBase(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Bookings / MyOrders section
        if (showMyTripsSection) ...[
          const TripCardShimmer(),
          const TripCardShimmer(),
        ],

        const SizedBox(height: 26),

        // Section title skeleton
        _ShimmerBase(
          child: const _Box(width: 180, height: 18),
        ),
        const SizedBox(height: 12),

        // Driver trips list skeleton
        const TripCardShimmer(),
        const TripCardShimmer(),
        const TripCardShimmer(),
      ],
    );
  }
}