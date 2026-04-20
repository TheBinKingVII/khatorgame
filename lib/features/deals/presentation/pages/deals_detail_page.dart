import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khatorgame/core/utils/supabase_user_message.dart';
import 'package:khatorgame/features/deals/data/repositories/deals_repository_impl.dart';
import 'package:khatorgame/features/deals/domain/entities/deals_entity.dart';
import 'package:khatorgame/features/deals/domain/usecases/deals_usecase.dart';
import 'package:khatorgame/features/wishlist/domain/entities/wishlist_entity.dart';
import 'package:khatorgame/features/wishlist/presentation/controllers/wishlist_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class DealsDetailPage extends StatefulWidget {
  const DealsDetailPage({required this.dealId, required this.title, super.key});

  final String dealId;
  final String title;

  @override
  State<DealsDetailPage> createState() => _DealsDetailPageState();
}

class _DealsDetailPageState extends State<DealsDetailPage> {
  final DealsUsecase _usecase = DealsUsecase(DealsRepositoryImpl());
  late final Future<DealsDetailEntity> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _usecase.getDealDetail(widget.dealId);
  }

  String _priceLine(DealsDetailEntity detail) {
    return 'Sale \$${detail.salePrice} · Normal \$${detail.retailPrice}';
  }

  String _ratingLabelForStore(String storeId) {
    const Map<String, String> storeById = <String, String>{
      '1': 'Steam',
      '2': 'GamersGate',
      '3': 'GreenManGaming',
      '7': 'GOG',
      '8': 'Origin',
      '11': 'Humble Store',
      '13': 'Uplay',
      '15': 'Fanatical',
      '21': 'WinGameStore',
      '23': 'GameBillet',
      '24': 'Voidu',
      '25': 'Epic Games Store',
      '27': 'Gamesplanet',
      '28': 'Gamesload',
      '29': '2Game',
      '30': 'IndieGala',
      '31': 'Blizzard Shop',
      '33': 'DLGamer',
      '34': 'Noctre',
      '35': 'DreamGame',
    };
    final String? storeName = storeById[storeId];
    if (storeName == null || storeName.isEmpty) {
      return 'Rating';
    }
    return 'Rating $storeName';
  }

  Future<void> _openMetacritic(
    BuildContext context,
    String metacriticLink,
  ) async {
    if (metacriticLink.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link Metacritic tidak tersedia')),
      );
      return;
    }

    final Uri url = Uri.parse('https://www.metacritic.com$metacriticLink');
    final bool opened = await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka link Metacritic')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final WishlistController wishlistController =
        Get.find<WishlistController>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.title),
        actions: <Widget>[
          Obx(() {
            final bool isFav = wishlistController.items.any(
              (WishlistItemEntity e) => e.dealId == widget.dealId,
            );
            return IconButton(
              tooltip: isFav ? 'Hapus dari wishlist' : 'Tambah ke wishlist',
              onPressed: () async {
                try {
                  final DealsDetailEntity detail = await _detailFuture;
                  if (!context.mounted) return;
                  final bool wasFav = wishlistController.items.any(
                    (WishlistItemEntity e) => e.dealId == widget.dealId,
                  );
                  await wishlistController.toggle(
                    dealId: widget.dealId,
                    title: detail.title,
                    price: _priceLine(detail),
                    imageUrl: detail.thumb,
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        wasFav
                            ? 'Dihapus dari wishlist'
                            : 'Ditambahkan ke wishlist',
                      ),
                    ),
                  );
                } catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(supabaseUserMessage(error))),
                  );
                }
              },
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.redAccent : null,
              ),
            );
          }),
        ],
      ),
      body: FutureBuilder<DealsDetailEntity>(
        future: _detailFuture,
        builder:
            (BuildContext context, AsyncSnapshot<DealsDetailEntity> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Gagal memuat detail.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final DealsDetailEntity detail = snapshot.data!;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      detail.thumb,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (
                            BuildContext context,
                            Object error,
                            StackTrace? stackTrace,
                          ) => Container(
                            height: 180,
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    detail.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DetailTile(
                    label: 'Harga Sale',
                    value: '\$${detail.salePrice}',
                    valueColor: Colors.green.shade700,
                  ),
                  _DetailTile(
                    label: 'Harga Normal',
                    value: '\$${detail.retailPrice}',
                  ),
                  _DetailTile(
                    label: _ratingLabelForStore(detail.storeId),
                    value: detail.steamRatingText,
                  ),
                  _DetailTile(
                    label: 'Metacritic',
                    value: detail.metacriticScore,
                  ),
                  _DetailTile(
                    label: 'Harga Termurah Sepanjang Waktu',
                    value: '\$${detail.cheapestHistoricalPrice}',
                  ),
                  const SizedBox(height: 6),
                  detail.metacriticLink.isNotEmpty
                      ? FilledButton.icon(
                          onPressed: () =>
                              _openMetacritic(context, detail.metacriticLink),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Buka Halaman Metacritic'),
                        )
                      : const SizedBox.shrink(),
                ],
              );
            },
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w700, color: valueColor),
          ),
        ],
      ),
    );
  }
}
