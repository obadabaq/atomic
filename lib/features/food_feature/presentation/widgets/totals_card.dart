import 'package:atomic/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:text_scroll/text_scroll.dart';

class TotalsCard extends StatefulWidget {
  final int total;
  final String title;
  final ThemeData theme;

  const TotalsCard({
    Key? key,
    required this.total,
    required this.title,
    required this.theme,
  }) : super(key: key);

  @override
  State<TotalsCard> createState() => _TotalsCardState();
}

class _TotalsCardState extends State<TotalsCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.w),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12.sp),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTotal(),
            _buildTitleText(),
          ],
        ),
      ),
    );
  }

  Widget _buildTotal() {
    return TextScroll(
      widget.total.toString(),
      style: widget.theme.textTheme.headlineLarge?.copyWith(
        color: CustomColors.blackColor,
      ),
    );
  }

  Widget _buildTitleText() {
    return Text(
      "total ${widget.title}",
      overflow: TextOverflow.ellipsis,
      maxLines: 3,
      style: widget.theme.textTheme.bodySmall?.copyWith(
        color: CustomColors.blackColor,
      ),
    );
  }
}
