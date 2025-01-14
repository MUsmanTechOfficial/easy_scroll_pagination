import 'package:flutter/foundation.dart';

/// PaginationState manages the state of pagination.
@immutable
class PaginationState<T> {
  final List<T> items;
  final bool isFirstPageLoading;
  final bool isLoadingNextPage;
  final bool hasMoreData;
  final int currentPage;
  final bool firstPageFailed;
  final bool nextPageFailed;
  final String? errorMessage;

  const PaginationState({
    this.items = const [],
    this.isFirstPageLoading = false,
    this.isLoadingNextPage = false,
    this.hasMoreData = true,
    this.currentPage = 1,
    this.firstPageFailed = false,
    this.nextPageFailed = false,
    this.errorMessage,
  });

  PaginationState<T> copyWith({
    List<T>? items,
    bool? isFirstPageLoading,
    bool? isLoadingNextPage,
    bool? hasMoreData,
    int? currentPage,
    bool? firstPageFailed,
    bool? nextPageFailed,
    String? errorMessage,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      isFirstPageLoading: isFirstPageLoading ?? this.isFirstPageLoading,
      isLoadingNextPage: isLoadingNextPage ?? this.isLoadingNextPage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
      firstPageFailed: firstPageFailed ?? this.firstPageFailed,
      nextPageFailed: nextPageFailed ?? this.nextPageFailed,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return 'PaginationState(items: ${items
        .length}, isFirstPageLoading: $isFirstPageLoading, '
        'isLoadingNextPage: $isLoadingNextPage, hasMoreData: $hasMoreData, '
        'currentPage: $currentPage, firstPageFailed: $firstPageFailed, '
        'nextPageFailed: $nextPageFailed, errorMessage: $errorMessage)';
  }
}
