import 'package:easy_scroll_pagination/easy_scroll_pagination.dart';
import 'package:flutter/material.dart';

/// PaginationController handles the pagination logic.
class PaginationController<T> extends ChangeNotifier {
  final Future<List<T>> Function(int page) onNextPage;
  final int itemsPerPage;

  PaginationState<T> _state = PaginationState<T>();

  PaginationState<T> get state => _state;

  PaginationController({
    required this.onNextPage,
    this.itemsPerPage = 10,
  }) {
    loadInitialData();
  }

  /// Loads the initial page of data.
  Future<void> loadInitialData() async {
    if (_state.items.isNotEmpty) {
      _updateState(
        isFirstPageLoading: false,
        firstPageFailed: false,
      );
      return;
    }

    _updateState(
      isFirstPageLoading: true,
      firstPageFailed: false,
      errorMessage: null,
    );

    try {
      final initialItems = await onNextPage(1);
      _updateState(
        items: initialItems,
        currentPage: 1,
        hasMoreData: initialItems.length >= itemsPerPage,
      );
    } on PaginationException catch (e) {
      _updateState(
        firstPageFailed: true,
        errorMessage: e.message,
      );
    } catch (e) {
      _updateState(
        firstPageFailed: true,
        errorMessage: e.toString(),
      );
    } finally {
      _updateState(isFirstPageLoading: false);
    }
  }

  /// Loads the next page of data.
  Future<void> loadNextPage() async {
    if (_state.isLoadingNextPage || !_state.hasMoreData) return;

    _updateState(
      isLoadingNextPage: true,
      nextPageFailed: false,
      errorMessage: null,
    );

    try {
      final nextPageItems = await onNextPage(_state.currentPage + 1);
      if (nextPageItems.isEmpty) {
        _updateState(hasMoreData: false);
      } else {
        _updateState(
          items: [..._state.items, ...nextPageItems],
          currentPage: _state.currentPage + 1,
          hasMoreData: nextPageItems.length >= itemsPerPage,
        );
      }
    } on PaginationException catch (e) {
      _updateState(
        nextPageFailed: true,
        errorMessage: e.message,
      );
    } catch (e) {
      _updateState(
        nextPageFailed: true,
        errorMessage: e.toString(),
      );
    } finally {
      _updateState(isLoadingNextPage: false);
    }
  }

  /// Retries the last failed page load.
  void retryLastFailedPage() {
    if (_state.firstPageFailed) {
      loadInitialData();
    } else if (_state.nextPageFailed) {
      loadNextPage();
    }
  }

  /// Refreshes items at a specific index.
  Future<void> refreshItemsAt(int index) async {
    final int targetPage = (index ~/ itemsPerPage) + 1;

    try {
      final updatedPageItems = await onNextPage(targetPage);

      final startIndex = (targetPage - 1) * itemsPerPage;
      final endIndex = startIndex + updatedPageItems.length;

      if (startIndex < _state.items.length) {
        final newItems = List<T>.from(_state.items);
        newItems.replaceRange(
          startIndex,
          endIndex > newItems.length ? newItems.length : endIndex,
          updatedPageItems,
        );
        _updateState(items: newItems);
      } else {
        debugPrint("Invalid range: start=$startIndex, end=$endIndex");
      }
    } catch (e) {
      debugPrint("Failed to refresh items at index $index: $e");
    }
  }

  /// Refreshes all data, resetting the pagination.
  Future<void> refreshAll() async {
    _updateState(
      isFirstPageLoading: true,
      hasMoreData: true,
      currentPage: 1,
      items: [],
      firstPageFailed: false,
      nextPageFailed: false,
      errorMessage: null,
    );
    await loadInitialData();
  }

  /// Updates the state and notifies listeners.
  void _updateState({
    List<T>? items,
    bool? isFirstPageLoading,
    bool? isLoadingNextPage,
    bool? hasMoreData,
    int? currentPage,
    bool? firstPageFailed,
    bool? nextPageFailed,
    String? errorMessage,
  }) {
    _state = _state.copyWith(
      items: items,
      isFirstPageLoading: isFirstPageLoading,
      isLoadingNextPage: isLoadingNextPage,
      hasMoreData: hasMoreData,
      currentPage: currentPage,
      firstPageFailed: firstPageFailed,
      nextPageFailed: nextPageFailed,
      errorMessage: errorMessage,
    );
    notifyListeners();
  }
}
