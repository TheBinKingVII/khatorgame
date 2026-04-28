import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khatorgame/core/utils/currency_price_formatter.dart';
import 'package:khatorgame/core/utils/input_validator.dart';
import 'package:khatorgame/features/deals/domain/entities/deals_entity.dart';
import 'package:khatorgame/features/deals/presentation/controllers/deals_controller.dart';
import 'package:khatorgame/features/deals/presentation/pages/deals_detail_page.dart';
import 'package:khatorgame/features/profile/presentation/controllers/profile_controller.dart';

class DealsPage extends StatefulWidget {
  const DealsPage({super.key});

  @override
  State<DealsPage> createState() => _DealsPageState();
}

class _DealsPageState extends State<DealsPage> {
  final DealsController _controller = Get.find<DealsController>();
  final ProfileController _profileController = Get.find<ProfileController>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _controller.initialize();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients ||
        _controller.isSearchMode ||
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Obx(_buildSearchField),
        Obx(_buildStoreFilterSection),
        Expanded(
          child: Obx(_buildDealsContent),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: TextField(
        controller: _searchController,
        inputFormatters: InputValidator.searchFormatters,
        onChanged: (String value) {
          final String? validationMessage = InputValidator.validateSearchQuery(
            value,
          );
          if (validationMessage != null) {
            _searchController.text = '';
            _searchController.selection = const TextSelection.collapsed(
              offset: 0,
            );
            _controller.clearSearch();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(validationMessage)));
            return;
          }
          _controller.onSearchChanged(value);
        },
        decoration: InputDecoration(
          hintText: 'Cari game...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.searchQuery.value.trim().isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _controller.clearSearch();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreFilterSection() {
    if (_controller.isSearchMode) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.fromLTRB(12, 2, 12, 6),
          child: Text(
            'Stores',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(
          height: 46,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('All'),
                  selected: _controller.selectedStoreId.value == null,
                  onSelected: (_) => _controller.changeStoreFilter(null),
                ),
              ),
              ..._controller.stores.map(
                (store) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(store.storeName),
                    selected: _controller.selectedStoreId.value == store.storeId,
                    onSelected: (_) =>
                        _controller.changeStoreFilter(store.storeId),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDealsContent() {
    final String currencyCode =
        _profileController.profile.value?.currencyCode ?? 'USD';

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

    if (_controller.isSearchMode) {
      return _buildSearchResult();
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
                  builder: (_) =>
                      DealsDetailPage(dealId: deal.dealId, title: deal.title),
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
                            errorBuilder:
                                (
                                  BuildContext context,
                                  Object error,
                                  StackTrace? stackTrace,
                                ) => Container(
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
                          _buildPriceText(
                            amountText: deal.salePrice,
                            currencyCode: currencyCode,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 2),
                          _buildPriceText(
                            amountText: deal.normalPrice,
                            currencyCode: currencyCode,
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
  }

  Widget _buildSearchResult() {
    if (_controller.isSearchLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.searchResults.isEmpty) {
      return const Center(child: Text('Game tidak ditemukan.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      itemCount: _controller.searchResults.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        final GameSearchEntity game = _controller.searchResults[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: game.cheapestDealId.trim().isEmpty
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => DealsDetailPage(
                          dealId: game.cheapestDealId,
                          title: game.external,
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
                      game.thumb,
                      width: 88,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (
                            BuildContext context,
                            Object error,
                            StackTrace? stackTrace,
                          ) => Container(
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
                          game.external,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        _buildPriceText(
                          amountText: game.cheapest,
                          currencyCode:
                              _profileController.profile.value?.currencyCode ??
                              'USD',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                          ),
                        ),
                        if (game.cheapestDealId.trim().isEmpty) ...<Widget>[
                          const SizedBox(height: 2),
                          const Text(
                            'Deal tidak tersedia',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceText({
    required String amountText,
    required String currencyCode,
    required TextStyle style,
  }) {
    return FutureBuilder<String>(
      future: CurrencyPriceFormatter.formatFromUsd(
        amountText: amountText,
        currencyCode: currencyCode,
      ),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return Text(snapshot.data ?? '\$$amountText', style: style);
      },
    );
  }
}
