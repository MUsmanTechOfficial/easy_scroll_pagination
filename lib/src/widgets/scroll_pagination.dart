import 'package:easy_scroll_pagination/easy_scroll_pagination.dart';
import 'package:flutter/material.dart';

/// ScrollPagination widget displays a paginated list with scroll detection.
class ScrollPagination<T> extends StatefulWidget {
  final PaginationController<T> pagingController;
  final ScrollController? controller;
  final bool primary;
  final bool shrinkWrap;
  final ScrollPhysics physics;
  final EdgeInsets? padding;
  final Widget? firstPageLoadingIndicator;
  final Widget? nextPageLoadingIndicator;
  final bool keepState;
  final Widget Function(
          BuildContext context, String errorMessage, VoidCallback retry)?
      firstPageErrorIndicator;
  final Widget Function(
          BuildContext context, String errorMessage, VoidCallback retry)?
      nextPageErrorIndicator;
  final Widget? noMoreDataIndicator;
  final Widget? emptyDataIndicator;
  final double renderThreshold;
  final Widget? prototypeItem;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;

  const ScrollPagination({
    super.key,
    required this.pagingController,
    this.controller,
    this.primary = true,
    this.shrinkWrap = false,
    this.physics = const AlwaysScrollableScrollPhysics(),
    this.keepState = true,
    this.padding,
    this.firstPageLoadingIndicator,
    this.nextPageLoadingIndicator,
    this.firstPageErrorIndicator,
    this.nextPageErrorIndicator,
    this.noMoreDataIndicator,
    this.emptyDataIndicator,
    this.prototypeItem,
    this.renderThreshold = 100.0,
    required this.itemBuilder,
  }) : assert(!(primary == false && controller == null),
            "Controller is required when primary is 'false'");

  @override
  ScrollPaginationState<T> createState() => ScrollPaginationState<T>();
}

class ScrollPaginationState<T> extends State<ScrollPagination<T>> {
  late ScrollController _internalScrollController;

  @override
  void initState() {
    super.initState();
    _internalScrollController =
        widget.primary ? ScrollController() : widget.controller!;

    _internalScrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (!widget.keepState) {
      _internalScrollController.removeListener(_onScroll);
      _internalScrollController.dispose();
    }
    super.dispose();
  }

  /// Listener that triggers loading next page when near bottom.
  void _onScroll() {
    if (_isNearBottom()) {
      widget.pagingController.loadNextPage();
    }
  }

  /// Checks if the scroll is near the bottom based on the renderThreshold in pixels.
  bool _isNearBottom() {
    if (!_internalScrollController.hasClients) return false;
    final maxScroll = _internalScrollController.position.maxScrollExtent;
    final currentScroll = _internalScrollController.position.pixels;
    return currentScroll >= (maxScroll - widget.renderThreshold);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.pagingController,
      builder: (context, _) {
        final state = widget.pagingController.state;

        if (state.isFirstPageLoading) {
          return _buildLoading(widget.firstPageLoadingIndicator);
        }

        if (state.firstPageFailed) {
          return _buildError(
            widget.firstPageErrorIndicator,
            state.errorMessage,
            widget.pagingController.retryLastFailedPage,
          );
        }

        if (state.items.isEmpty) {
          return widget.emptyDataIndicator ??
              const Center(child: Text("No items available"));
        }

        return ListView.builder(
          padding: widget.padding,
          controller: widget.primary ? _internalScrollController : null,
          primary: widget.primary,
          shrinkWrap: widget.shrinkWrap,
          physics: widget.physics,
          itemCount: state.items.length + 1,
          prototypeItem: widget.prototypeItem,
          itemBuilder: (context, index) {
            if (index < state.items.length) {
              return widget.itemBuilder(context, index, state.items[index]);
            } else {
              return _buildPageIndicator(state);
            }
          },
        );
      },
    );
  }

  /// Builds the loading widget.
  Widget _buildLoading(Widget? customLoading) {
    return customLoading ??
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator.adaptive()),
        );
  }

  /// Builds the error widget with a retry mechanism.
  Widget _buildError(
      Widget Function(BuildContext, String, VoidCallback)? customError,
      String? errorMessage,
      VoidCallback onRetry) {
    if (customError != null) {
      return customError(context, errorMessage ?? "An error occurred", onRetry);
    }

    return GestureDetector(
      onTap: onRetry,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            errorMessage ?? "Failed to load data. Tap to retry.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  /// Builds the pagination indicator based on the current state.
  Widget _buildPageIndicator(PaginationState<T> state) {
    if (state.nextPageFailed) {
      return _buildError(
        widget.nextPageErrorIndicator,
        state.errorMessage,
        widget.pagingController.retryLastFailedPage,
      );
    } else if (state.isLoadingNextPage) {
      return widget.nextPageLoadingIndicator ??
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator.adaptive()),
          );
    } else {
      return widget.noMoreDataIndicator ??
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text("No more data available")),
          );
    }
  }
}
