import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skanskin_app/app/routes.dart';
import 'package:skanskin_app/core/network/api_exception.dart';
import 'package:skanskin_app/core/theme/app_colors.dart';
import 'package:skanskin_app/core/theme/app_dimens.dart';
import 'package:skanskin_app/core/utils/formatters.dart';
import 'package:skanskin_app/features/consultations/data/models/consultation.dart';
import 'package:skanskin_app/features/consultations/data/models/consultation_status.dart';
import 'package:skanskin_app/features/consultations/presentation/widgets/consultation_tile.dart';
import 'package:skanskin_app/features/consultations/state/consultations_providers.dart';
import 'package:skanskin_app/shared/widgets/app_states.dart';
import 'package:skanskin_app/shared/widgets/mobile_top_bar.dart';

/// The patient's consultation history with the existing client-side search,
/// status filters, pull-to-refresh, and detail navigation.
class ConsultationsScreen extends ConsumerStatefulWidget {
  const ConsultationsScreen({super.key});

  @override
  ConsumerState<ConsultationsScreen> createState() =>
      _ConsultationsScreenState();
}

class _ConsultationsScreenState extends ConsumerState<ConsultationsScreen> {
  final _searchController = TextEditingController();
  bool _searchOpen = false;
  String _query = '';

  static const _filters = <(ConsultationStatus?, String)>[
    (null, 'الكل'),
    (ConsultationStatus.pending, 'قيد الانتظار'),
    (ConsultationStatus.inReview, 'قيد المراجعة'),
    (ConsultationStatus.diagnosed, 'تم التشخيص'),
    (ConsultationStatus.cancelled, 'ملغاة'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searchOpen = !_searchOpen;
      if (!_searchOpen) {
        _searchController.clear();
        _query = '';
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  bool _matchesQuery(ConsultationSummary consultation) {
    final query = _query.trim();
    if (query.isEmpty) return true;

    final lowerQuery = query.toLowerCase();
    final haystack =
        '${consultation.id} ${consultation.symptoms} ${consultation.doctorName ?? ''}'
            .toLowerCase();

    return haystack.contains(lowerQuery) ||
        Formatters.toArabicDigits('${consultation.id}').contains(query);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(consultationsListProvider);
    final filter = ref.watch(consultationFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.primarySoft,
      appBar: MobileTopBar(
        title: 'استشاراتي',
        actions: [
          IconButton(
            icon: Icon(
              _searchOpen ? Icons.close_rounded : Icons.search_rounded,
              size: 22,
            ),
            color: AppColors.textPrimary,
            onPressed: _toggleSearch,
            tooltip: _searchOpen ? 'إغلاق البحث' : 'بحث في الاستشارات',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_searchOpen) _buildSearchField(context),
          _buildFilterChips(context, filter),
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppDimens.brSheetTop,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.panelShadow,
                    blurRadius: 22,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => ref.refresh(consultationsListProvider.future),
                child: async.when(
                  loading: () => _buildLoadingList(context),
                  error: (error, _) => _FullHeightScroll(
                    child: AppError(
                      message: error is ApiException
                          ? error.message
                          : 'تعذّر تحميل الاستشارات.',
                      onRetry: () => ref.invalidate(consultationsListProvider),
                    ),
                  ),
                  data: (items) => _buildList(context, items, filter),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final gutter = AppDimens.pageGutterFor(context);

    return ColoredBox(
      color: AppColors.primarySoft,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppDimens.maxContentWidth,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              gutter,
              AppDimens.s12,
              gutter,
              AppDimens.s4,
            ),
            child: Semantics(
              textField: true,
              label: 'البحث في الاستشارات',
              child: TextField(
                controller: _searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: (value) => setState(() => _query = value),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'ابحث بالرقم أو الأعراض أو اسم الطبيب',
                  hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 21,
                    color: AppColors.textSecondary,
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.close_rounded, size: 20),
                          color: AppColors.textSecondary,
                          tooltip: 'مسح البحث',
                        ),
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.s16,
                    vertical: AppDimens.s16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, ConsultationStatus? active) {
    final gutter = AppDimens.pageGutterFor(context);

    return ColoredBox(
      color: AppColors.primarySoft,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppDimens.maxContentWidth,
          ),
          child: Semantics(
            container: true,
            label: 'تصفية الاستشارات حسب الحالة',
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.fromLTRB(
                gutter,
                AppDimens.s8,
                gutter,
                AppDimens.s12,
              ),
              child: Row(
                children: [
                  for (var index = 0; index < _filters.length; index++) ...[
                    if (index > 0) const SizedBox(width: AppDimens.s8),
                    _FilterChip(
                      label: _filters[index].$2,
                      selected: _filters[index].$1 == active,
                      onTap: () =>
                          ref.read(consultationFilterProvider.notifier).state =
                              _filters[index].$1,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingList(BuildContext context) {
    final inset = _listHorizontalInset(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(inset, AppDimens.s12, inset, AppDimens.s24),
      child: _ListSurface(
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: 4,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            indent: AppDimens.s16,
            endIndent: AppDimens.s16,
          ),
          itemBuilder: (_, __) => const ConsultationTileSkeleton(),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<ConsultationSummary> items,
    ConsultationStatus? filter,
  ) {
    final filtered = items
        .where(
          (consultation) => filter == null || consultation.status == filter,
        )
        .where(_matchesQuery)
        .toList(growable: false);

    if (items.isEmpty) {
      return _FullHeightScroll(
        child: AppEmpty(
          icon: Icons.assignment_outlined,
          title: 'لا توجد استشارات بعد',
          message:
              'ابدأ استشارتك الأولى برفع صورة للمنطقة المصابة ووصف الأعراض.',
          actionLabel: 'استشارة جديدة',
          actionIcon: Icons.add_rounded,
          onAction: () => context.push(Routes.createConsultation),
        ),
      );
    }

    if (filtered.isEmpty) {
      return const _FullHeightScroll(
        child: AppEmpty(
          icon: Icons.search_off_rounded,
          title: 'لا توجد نتائج مطابقة',
          message: 'جرّب تغيير الفلتر أو كلمة البحث.',
        ),
      );
    }

    final inset = _listHorizontalInset(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(inset, AppDimens.s12, inset, AppDimens.s24),
      child: _ListSurface(
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            indent: AppDimens.s16,
            endIndent: AppDimens.s16,
          ),
          itemBuilder: (context, index) {
            final consultation = filtered[index];
            return ConsultationTile(
              consultation: consultation,
              onTap: () =>
                  context.push(Routes.consultationDetailOf(consultation.id)),
            );
          },
        ),
      ),
    );
  }

  double _listHorizontalInset(BuildContext context) {
    final gutter = AppDimens.pageGutterFor(context);
    final centered =
        (MediaQuery.sizeOf(context).width - AppDimens.maxContentWidth) / 2;
    return centered > gutter ? centered : gutter;
  }
}

class _ListSurface extends StatelessWidget {
  const _ListSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimens.brCard,
        border: Border.all(color: AppColors.divider),
      ),
      child: ClipRRect(borderRadius: AppDimens.brCard, child: child),
    );
  }
}

/// Keeps pull-to-refresh available for empty and error states.
class _FullHeightScroll extends StatelessWidget {
  const _FullHeightScroll({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? AppColors.onPrimarySoft
        : AppColors.textSecondary;

    return Semantics(
      button: true,
      selected: selected,
      label: 'فلتر $label',
      onTap: onTap,
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: selected ? AppColors.primarySoft : AppColors.surface,
            borderRadius: AppDimens.brFull,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: AppDimens.brFull,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.s12,
                    vertical: AppDimens.s8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected) ...[
                        const Icon(
                          Icons.check_rounded,
                          size: 17,
                          color: AppColors.onPrimarySoft,
                        ),
                        const SizedBox(width: AppDimens.s4),
                      ],
                      Text(
                        label,
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: foreground),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
