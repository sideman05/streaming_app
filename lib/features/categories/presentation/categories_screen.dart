import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_states.dart';
import '../../channels/presentation/channel_providers.dart';
import '../../shared/models/category.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: AppBackground(
        child: categories.when(
          data: (items) {
            if (items.isEmpty) {
              return const EmptyView(message: 'No categories found');
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth >= 760 ? 3 : 2;
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _CategoriesHeader(total: items.length),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.35,
                        ),
                        delegate: SliverChildBuilderDelegate((context, i) {
                          final category = items[i];
                          return _CategoryTile(
                            category: category,
                            onTap: () => context.push(
                              '/channels?category=${Uri.encodeComponent(category.name)}',
                            ),
                          );
                        }, childCount: items.length),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          error: (e, stackTrace) => ErrorView(message: e.toString()),
          loading: () => const LoadingView(),
        ),
      ),
    );
  }
}

class _CategoriesHeader extends StatelessWidget {
  final int total;

  const _CategoriesHeader({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.grid_view_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Browse by category',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$total categories available',
                  style: const TextStyle(color: Color(0xFF646464)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const _CategoryTile({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE3E3E3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _iconFor(category.name),
                  color: const Color(0xFF111111),
                ),
              ),
              const Spacer(),
              Text(
                category.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111111),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              const Row(
                children: [
                  Text(
                    'View channels',
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 14, color: Color(0xFF666666)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _iconFor(String name) {
  final value = name.toLowerCase();
  if (value.contains('news')) return Icons.newspaper_rounded;
  if (value.contains('sport')) return Icons.sports_soccer_rounded;
  if (value.contains('movie') || value.contains('film')) {
    return Icons.movie_creation_outlined;
  }
  if (value.contains('music')) return Icons.music_note_rounded;
  if (value.contains('kids') || value.contains('cartoon')) {
    return Icons.child_care_rounded;
  }
  if (value.contains('documentary')) return Icons.menu_book_rounded;
  return Icons.category_rounded;
}
