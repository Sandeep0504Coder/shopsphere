import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoader extends StatelessWidget {
  int itemCount;
  ShimmerLoader({super.key, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: itemCount,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, __) {
            return Column(
              children: [
                Container(
                  height: 30,
                  width: 60,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                  ),
                ),
                // const SizedBox(height: 8),
                // Container(
                //   width: 60,
                //   height: 30,
                //   color: Colors.white,
                // ),
              ],
            );
          },
        ),
      ),
    );
  }
}
