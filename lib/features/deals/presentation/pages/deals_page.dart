import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khatorgame/features/deals/domain/entities/deals_entity.dart';
import 'package:khatorgame/features/deals/presentation/controllers/deals_controller.dart';
import 'package:khatorgame/features/deals/presentation/pages/deals_detail_page.dart';

class DealsPage extends StatefulWidget {
  const DealsPage({super.key});

  @override
  State<DealsPage> createState() => _DealsPageState();
}

class _DealsPageState extends State<DealsPage> {
  final DealsController _controller = Get.put(DealsController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _controller.loadInitialDeals();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    Get.delete<DealsController>();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients ||
        _controller.isLoadingMore.value ||
        !_controller.hasMore.value) {
      return;
    }

    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double currentScroll = _scrollController.position.pixels;
    if (currentScroll >= (maxScroll - 300)) {
      _controller.loadMoreDeals();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.isInitialLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_controller.errorMessage.value != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Gagal memuat deals.\n${_controller.errorMessage.value}',
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      if (_controller.deals.isEmpty) {
        return const Center(child: Text('Belum ada deal tersedia.'));
      }

      return RefreshIndicator(
        onRefresh: _controller.loadInitialDeals,
        child: GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.82,
          ),
          itemCount:
              _controller.deals.length + (_controller.isLoadingMore.value ? 2 : 0),
          itemBuilder: (BuildContext context, int index) {
            if (index >= _controller.deals.length) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }

            final DealsEntity deal = _controller.deals[index];
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => DealsDetailPage(
                      dealId: deal.dealId,
                      title: deal.title,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.white,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.network(
                              deal.thumb,
                              fit: BoxFit.cover,
                              errorBuilder: (
                                BuildContext context,
                                Object error,
                                StackTrace? stackTrace,
                              ) =>
                                  Container(
                                color: Colors.grey.shade200,
                                alignment: Alignment.center,
                                child: const Icon(Icons.broken_image_outlined),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '-${deal.savingsAsPercent}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  deal.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '\$${deal.salePrice}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '\$${deal.normalPrice}',
                              style: const TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
