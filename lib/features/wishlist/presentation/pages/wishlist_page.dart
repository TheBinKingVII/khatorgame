import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khatorgame/core/utils/supabase_user_message.dart';
import 'package:khatorgame/features/deals/presentation/pages/deals_detail_page.dart';
import 'package:khatorgame/features/wishlist/domain/entities/wishlist_entity.dart';
import 'package:khatorgame/features/wishlist/presentation/controllers/wishlist_controller.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final WishlistController controller = Get.find<WishlistController>();

    return Obx(() {
      if (controller.syncBusy.value && controller.items.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.items.isEmpty) {
        return RefreshIndicator(
          onRefresh: () => _onRefresh(controller, context),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const <Widget>[
              SizedBox(height: 120),
              Icon(Icons.favorite_border, size: 56, color: Colors.grey),
              SizedBox(height: 16),
              Center(
                child: Text(
                  'Wishlist masih kosong.\nTarik ke bawah untuk menyegarkan.',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => _onRefresh(controller, context),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.items.length,
          itemBuilder: (BuildContext context, int index) {
            final WishlistItemEntity item = controller.items[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => DealsDetailPage(
                        dealId: item.dealId,
                        title: item.title,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.imageUrl,
                          width: 88,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (
                            BuildContext context,
                            Object error,
                            StackTrace? stackTrace,
                          ) =>
                              Container(
                            width: 88,
                            height: 56,
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.price,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Hapus dari wishlist',
                        onPressed: () async {
                          try {
                            await controller.remove(item.dealId);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Dihapus dari wishlist'),
                                ),
                              );
                            }
                          } catch (error) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(supabaseUserMessage(error)),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Future<void> _onRefresh(
    WishlistController controller,
    BuildContext context,
  ) async {
    try {
      await controller.syncFromRemote();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wishlist disinkronkan')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(supabaseUserMessage(error))),
        );
      }
    }
  }
}
