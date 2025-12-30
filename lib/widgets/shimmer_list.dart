import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerList extends StatelessWidget {
  final int count;
  final double height;
  final bool isHorizontal;

  const ShimmerList({
    super.key,
    this.count = 6,
    this.height = 120,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget shimmerItem = Padding(
      padding: const EdgeInsets.all(12),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[800]!,
        highlightColor: Colors.grey[700]!,
        child: Container(
          height: height,
          width: isHorizontal ? 300 : double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );

    if (isHorizontal) {
      return SizedBox(
        height: height + 24,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: count,
          itemBuilder: (_, __) => shimmerItem,
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (_, __) => shimmerItem,
    );
  }
}