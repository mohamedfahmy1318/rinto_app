import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/listings_provider.dart';
import '../widgets/listing_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ListingsProvider>(context, listen: false).fetchFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('favorites'))),
      body: Consumer<ListingsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingFavorites) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 64,
                    color: AppColors.darkTextSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('no_results'),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchFavorites(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.favorites.length,
              itemBuilder: (context, index) {
                return ListingCard(listing: provider.favorites[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
