import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:food_app/database/cart_manager.dart';
import 'package:food_app/database/user_accounts.dart';
import 'package:food_app/main.dart';
import 'package:food_app/app_colors.dart';

class OrderTrackingPage extends StatefulWidget {
  final double subtotal;
  final double deliveryFee;
  final double totalAmount;
  final int totalItems;
  final CartManager cartManager;
  final UserAccounts? loggedInUser;

  const OrderTrackingPage({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    required this.totalItems,
    required this.cartManager,
    this.loggedInUser,
  });

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  double progress = 0.0;
  double selectedTip = 0;

  final int etaSeconds = 10;
  late Timer _timer;
  int _timePassed = 0;

  bool isDelivered = false;

  final TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startEtaCountdown();
  }

  void _startEtaCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timePassed >= etaSeconds) {
        timer.cancel();
        setState(() {});
        return;
      }

      setState(() {
        _timePassed++;
        progress = _timePassed / etaSeconds;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _chatController.dispose();
    super.dispose();
  }

  void _onOrderReceived() {
    setState(() {
      isDelivered = true;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Order has been received")));

    // Show loading for 5-10 seconds then navigate back
    _showLoadingAndNavigate();
  }

  void _showLoadingAndNavigate() {
    // Generate random delay between 5-10 seconds
    int randomSeconds = Random().nextInt(6) + 5; // 5-10 seconds

    Future.delayed(Duration(seconds: randomSeconds), () async {
      if (mounted) {
        // Replace entire navigation stack with a fresh MainScreen
        // (ensures the app lands on the Menu/Home tab)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => MainScreen(loggedInUser: widget.loggedInUser),
          ),
          (route) => false,
        );
      }
    });
  }

  String _formatRemainingTime() {
    int remaining = etaSeconds - _timePassed;
    int min = remaining ~/ 60;
    int sec = remaining % 60;
    return "$min:${sec.toString().padLeft(2, '0')} mins";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 22, left: 20, right: 20),
              child: _buildStatusCard(),
            ),
          ),

          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.12,
            maxChildSize: 0.75,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  children: [
                    Center(
                      child: Container(
                        width: 60,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _riderCard(),
                    const SizedBox(height: 16),
                    _orderSummary(),
                    const SizedBox(height: 16),
                    _chatInput(),
                    const SizedBox(height: 18),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final bool isFinished = _timePassed >= etaSeconds;

    return Container(
      height: 180,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDelivered ? AppColors.success : AppColors.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: isFinished
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDelivered
                            ? "Thank you for your order!"
                            : "Your order has arrived!",
                        style: const TextStyle(
                          color: AppColors.textOnPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (!isDelivered)
                        ElevatedButton(
                          onPressed: _onOrderReceived,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.card,
                            foregroundColor: AppColors.textPrimary,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Order Received"),
                        ),
                    ],
                  )
                : Center(
                    child: Text(
                      "${_formatRemainingTime()}\nOrder is On\nthe Way",
                      style: const TextStyle(
                        color: AppColors.textOnPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.28,
                      ),
                    ),
                  ),
          ),

          SizedBox(
            width: 100,
            height: 100,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: isDelivered
                  ? Container(
                      key: const ValueKey("success_icon"),
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.textOnPrimary,
                        ),
                        strokeWidth: 4,
                      ),
                    )
                  : isFinished
                  ? Container(
                      key: const ValueKey("check_icon"),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.check_circle,
                        size: 72,
                        color: AppColors.textOnPrimary,
                      ),
                    )
                  : LoadingProgressRing(
                      key: const ValueKey("loading_ring"),
                      progress: progress,
                      size: 100,
                      strokeWidth: 14,
                      deliveryImageAsset:
                          "assets/deliverypage/bag/delivpic.png",
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _riderCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage("assets/deliverypage/rider/driver.png"),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ariel",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "Motorbike",
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
    );
  }

  Widget _orderSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Summary",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Items:",
                style: TextStyle(color: AppColors.textPrimary),
              ),
              Text(
                "${widget.totalItems}",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Subtotal:",
                style: TextStyle(color: AppColors.textPrimary),
              ),
              Text(
                "₱${widget.subtotal.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Delivery Fee:",
                style: TextStyle(color: AppColors.textPrimary),
              ),
              Text(
                "₱${widget.deliveryFee.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          // Show tip if included in totalAmount (totalAmount = subtotal + deliveryFee + tip)
          Builder(
            builder: (context) {
              final double tip =
                  widget.totalAmount - widget.subtotal - widget.deliveryFee;
              if (tip > 0.009) {
                return Column(
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Tip:",
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                        Text(
                          "₱${tip.toStringAsFixed(2)}",
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total:",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                "₱${widget.totalAmount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chatInput() {
    return TextField(
      controller: _chatController,
      decoration: InputDecoration(
        hintText: "Chat with your rider",
        filled: true,
        fillColor: AppColors.card,
        prefixIcon: const Icon(Icons.chat_bubble_outline),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      textInputAction: TextInputAction.send,
      onSubmitted: (val) {
        _chatController.clear();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Message sent")));
      },
    );
  }
}

class LoadingProgressRing extends StatefulWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final String? deliveryImageAsset;

  const LoadingProgressRing({
    super.key,
    required this.progress,
    this.size = 90,
    this.strokeWidth = 12,
    this.deliveryImageAsset,
  });

  @override
  State<LoadingProgressRing> createState() => _LoadingProgressRingState();
}

class _LoadingProgressRingState extends State<LoadingProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animatedProgress;

  double _oldValue = 0.0;

  @override
  void initState() {
    super.initState();

    _oldValue = widget.progress;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10),
    );

    _animatedProgress = Tween<double>(
      begin: _oldValue,
      end: widget.progress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant LoadingProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);

    if ((widget.progress - _oldValue).abs() > 0.0001) {
      _animatedProgress = Tween<double>(
        begin: _oldValue,
        end: widget.progress,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

      _oldValue = widget.progress;
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animatedProgress,
        builder: (context, _) {
          return CustomPaint(
            painter: _RingPainter(
              progress: _animatedProgress.value,
              strokeWidth: widget.strokeWidth,
            ),
            child: Center(
              child: ClipOval(
                child: Image.asset(
                  widget.deliveryImageAsset ?? "",
                  width: widget.size * 0.5,
                  height: widget.size * 0.5,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  _RingPainter({required this.progress, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final fg = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    canvas.drawArc(rect, -pi / 2, 2 * pi, false, bg);
    canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
