import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

import 'package:google_fonts/google_fonts.dart';

class ToastData {
  final String id;
  final String message;
  bool leaving;

  ToastData({required this.id, required this.message, this.leaving = false});
}

class ToastController extends ChangeNotifier {
  static const int maxVisible = 4;

  final List<ToastData> _toasts = [];
  List<ToastData> get toasts => List.unmodifiable(_toasts);

  void show(
    String message, {
    Duration duration = const Duration(milliseconds: 1600),
  }) {
    final id = '${DateTime.now().microsecondsSinceEpoch}';
    _toasts.add(ToastData(id: id, message: message));
    notifyListeners();

    Future.delayed(duration, () => _startLeaving(id));
    _enforceMax();
  }

  void _enforceMax() {
    final active = _toasts.where((t) => !t.leaving).toList();
    final overflow = active.length - maxVisible;
    if (overflow > 0) {
      for (var i = 0; i < overflow; i++) {
        _startLeaving(active[i].id);
      }
    }
  }

  void _startLeaving(String id) {
    final index = _toasts.indexWhere((t) => t.id == id);
    if (index == -1 || _toasts[index].leaving) return;

    _toasts[index].leaving = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 220), () {
      _toasts.removeWhere((t) => t.id == id);
      notifyListeners();
    });
  }
}

final toastController = ToastController();

// ВАЖНО: Positioned теперь снаружи, IgnorePointer — внутри него
class ToastStack extends StatelessWidget {
  const ToastStack({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;
    return Positioned(
      left: 16,
      right: 16,
      bottom: 26 + kBottomNavigationBarHeight + bottomSafeArea,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: toastController,
          builder: (context, _) {
            final toasts = toastController.toasts;
            // reversed: самое новое уведомление оказывается первым в списке -> отрисовывается сверху
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: toasts.reversed
                  .map((toast) => _ToastItem(toast: toast))
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}

class _ToastItem extends StatefulWidget {
  final ToastData toast;
  const _ToastItem({required this.toast});

  @override
  State<_ToastItem> createState() => _ToastItemState();
}

class _ToastItemState extends State<_ToastItem> {
  bool visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final show = visible && !widget.toast.leaving;
    return AnimatedOpacity(
      opacity: show ? 1 : 0,
      duration: const Duration(milliseconds: 220),
      child: AnimatedSlide(
        offset: show ? Offset.zero : const Offset(0, 0.3),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary, width: 1),
            ),
            child: Text(
              widget.toast.message,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
