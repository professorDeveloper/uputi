import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uputi/src/core/constants/app_icons.dart';

import '../../../../core/constants/app_color.dart';

class UPuttiHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String logoAsset;
  final String balance;
  final VoidCallback? onProfileTap;

  const UPuttiHomeAppBar({
    super.key,
    required this.logoAsset,
     this.balance="0 uzs",
    this.onProfileTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0.1,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB8DBF8), Color(0xFFCEE7FD), Color(0xFFECF2F8)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: kToolbarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 44,
                          child: Image.asset(
                            logoAsset!,
                            height: 38,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 6),
                        const Text(
                          "UPutti",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2B6CB0),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColor.Gray1,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 5,),
                              Text(balance),
                              SizedBox(width: 4),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColor.blueMain,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 20,
                                  color: AppColor.white,
                                ),
                              ),
                              SizedBox(width: 4,),

                            ],
                          ),
                        ),
                        SizedBox(width: 10,),
                        InkWell(
                          onTap: onProfileTap,
                          borderRadius: BorderRadius.circular(99),
                          child: SvgPicture.asset(AppIcons.bell,color: AppColor.blueMain,),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
