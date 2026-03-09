import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_color.dart';

class OfferPriceResult {
  final int price;
  final int seats;
  final String? comment;

  OfferPriceResult({
    required this.price,
    required this.seats,
    required this.comment,
  });
}

Future<OfferPriceResult?> showOfferPriceBottomSheet(
    BuildContext context, {
      int minSeats = 1,
      int maxSeats = 4,
      int initialSeats = 1,
    }) {
  if (maxSeats > 4) maxSeats = 4;
  if (minSeats < 1) minSeats = 1;
  if (initialSeats < minSeats) initialSeats = minSeats;
  if (initialSeats > maxSeats) initialSeats = maxSeats;

  return showModalBottomSheet<OfferPriceResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _OfferPriceSheet(
      minSeats: minSeats,
      maxSeats: maxSeats,
      initialSeats: initialSeats,
    ),
  );
}


class _OfferPriceSheet extends StatefulWidget {
  const _OfferPriceSheet({
    required this.minSeats,
    required this.maxSeats,
    required this.initialSeats,
  });

  final int minSeats;
  final int maxSeats;
  final int initialSeats;

  @override
  State<_OfferPriceSheet> createState() => _OfferPriceSheetState();
}

class _OfferPriceSheetState extends State<_OfferPriceSheet> {
  late final TextEditingController _priceCtrl;
  late final TextEditingController _commentCtrl;
  late final FocusNode _priceFocus;

  late int _seats;
  bool _loading = false;
  bool _showComment = false;

  @override
  void initState() {
    super.initState();
    _priceCtrl = TextEditingController();
    _commentCtrl = TextEditingController();
    _priceFocus = FocusNode();
    _seats = widget.initialSeats;

    // Narx o'zgarganda UI qayta qurilishi uchun listener
    _priceCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _commentCtrl.dispose();
    _priceFocus.dispose();
    super.dispose();
  }

  int _parsePrice() {
    final raw = _priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isEmpty) return 0;
    return int.tryParse(raw) ?? 0;
  }

  /// 1 o'rindiq uchun narx × tanlangan o'rindiqlar soni
  int get _totalPrice => _parsePrice() * _seats;

  /// Raqamni 3 xonali guruhlash: 30000 → "30 000"
  String _formatNumber(int value) {
    if (value <= 0) return '0';
    final str = value.toString();
    final buffer = StringBuffer();
    final startIndex = str.length % 3;
    for (int i = 0; i < str.length; i++) {
      if (i != 0 && (i - startIndex) % 3 == 0) buffer.write(' ');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  void _setSeats(int v) {
    if (_loading) return;
    if (v < widget.minSeats || v > widget.maxSeats) return;
    HapticFeedback.selectionClick();
    setState(() => _seats = v);
  }

  Future<void> _submit() async {
    if (_loading) return;

    final price = _parsePrice();
    if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('offer_price_required'.tr())),
      );
      return;
    }

    setState(() => _loading = true);

    final res = OfferPriceResult(
      price: price,
      seats: _seats,
      comment: _commentCtrl.text.trim().isEmpty
          ? null
          : _commentCtrl.text.trim(),
    );

    await Future.delayed(const Duration(milliseconds: 120));
    if (mounted) Navigator.pop(context, res);
  }

  @override
  Widget build(BuildContext context) {
    final unitPrice = _parsePrice();
    final total = _totalPrice;
    final hasPrice = unitPrice > 0;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 22,
              offset: Offset(0, 12),
              color: Color(0x1A000000),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Drag handle ──
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6E8EE),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 10),

                // ── Sarlavha ──
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'offer_price_title'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.1,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: _loading ? null : () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.close, size: 20),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Narx label ──
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'offer_price_label'.tr(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withOpacity(0.72),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // ── Narx input ──
                TextField(
                  controller: _priceCtrl,
                  focusNode: _priceFocus,
                  enabled: !_loading,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    hintText: 'offer_price_hint'.tr(),
                    filled: true,
                    fillColor: const Color(0xFFF6F7FB),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                      const BorderSide(color: Color(0xFFE2E5EC)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                      const BorderSide(color: Color(0xFFE2E5EC)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                      BorderSide(color: AppColor.blueMain, width: 1.4),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'offer_currency'.tr(),
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ),

                const SizedBox(height: 12),

                // ── O'rindiqlar ──
                Row(
                  children: [
                    Text(
                      'offer_seats_label'.tr(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withOpacity(0.72),
                      ),
                    ),
                    const Spacer(),
                    Wrap(
                      spacing: 8,
                      children: List.generate(widget.maxSeats, (i) {
                        final v = i + 1;
                        return _SeatChip(
                          value: v,
                          selected: _seats == v,
                          loading: _loading,
                          onTap: () => _setSeats(v),
                        );
                      }),
                    ),
                  ],
                ),

                // ── Jami narx bloki ──
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  child: hasPrice
                      ? Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColor.blueMain.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColor.blueMain.withOpacity(0.18),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Chap: formula
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                              children: [
                                TextSpan(
                                  text: _formatNumber(unitPrice),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                                const TextSpan(text: ' × '),
                                TextSpan(
                                  text: '$_seats',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                                const TextSpan(text: " = "),
                              ],
                            ),
                          ),
                        ),
                        // O'ng: jami
                        Text(
                          '${_formatNumber(total)} so\'m',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColor.blueMain,
                          ),
                        ),
                      ],
                    ),
                  )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 10),

                // ── Izoh toggle ──
                InkWell(
                  onTap: _loading
                      ? null
                      : () => setState(() => _showComment = !_showComment),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          _showComment
                              ? Icons.expand_less
                              : Icons.expand_more,
                          size: 20,
                          color: const Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'offer_comment_label'.tr(),
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                ),

                if (_showComment) ...[
                  const SizedBox(height: 6),
                  TextField(
                    controller: _commentCtrl,
                    enabled: !_loading,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: 'offer_comment_hint'.tr(),
                      filled: true,
                      fillColor: const Color(0xFFF6F7FB),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                        const BorderSide(color: Color(0xFFE2E5EC)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                        const BorderSide(color: Color(0xFFE2E5EC)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                            color: AppColor.blueMain, width: 1.4),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // ── Tugmalar ──
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: _Btn(
                          text: 'offer_btn_cancel'.tr(),
                          filled: false,
                          loading: _loading,
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: _Btn(
                          text: 'offer_btn_send'.tr(),
                          filled: true,
                          loading: _loading,
                          onTap: _submit,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _SeatChip extends StatelessWidget {
  final int value;
  final bool selected;
  final bool loading;
  final VoidCallback onTap;

  const _SeatChip({
    required this.value,
    required this.selected,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColor.blueMain : const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person,
              size: 16,
              color: selected ? Colors.white : const Color(0xFF111827),
            ),
            const SizedBox(width: 6),
            Text(
              "$value",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color:
                selected ? Colors.white : const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String text;
  final bool filled;
  final bool loading;
  final VoidCallback onTap;

  const _Btn({
    required this.text,
    required this.filled,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = filled ? AppColor.blueMain : const Color(0xFFF0F2F6);
    final fg = filled ? Colors.white : const Color(0xFF111827);

    return ElevatedButton(
      onPressed: loading ? null : onTap,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: bg,
        foregroundColor: fg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
      ).copyWith(
        overlayColor: WidgetStateProperty.all(
          filled
              ? Colors.white.withOpacity(0.12)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 160),
        child: loading && filled
            ? const SizedBox(
          key: ValueKey('l'),
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : Text(
          key: const ValueKey('t'),
          text,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}