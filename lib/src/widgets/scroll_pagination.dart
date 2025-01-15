import 'package:easy_scroll_pagination/easy_scroll_pagination.dart';
import 'package:flutter/material.dart';

/// ScrollPagination widget displays a paginated list with scroll detection.
class ScrollPagination<T> extends StatefulWidget {
  final PaginationController<T> controller;
  final ScrollController? scrollController;
  final Widget? firstPageLoadingWidget;
  final Widget? nextPageLoadingWidget;
  final Widget Function(
          BuildContext context, String errorMessage, VoidCallback retry)?
      firstPageErrorWidget;
  final Widget Function(
          BuildContext context, String errorMessage, VoidCallback retry)?
      nextPageErrorWidget;
  final Widget? lastPageWidget;
  final double renderThreshold;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final bool enableRefresh;
  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ScrollPagination({
    super.key,
    required this.controller,
    this.scrollController,
    this.firstPageLoadingWidget,
    this.nextPageLoadingWidget,
    this.firstPageErrorWidget,
    this.nextPageErrorWidget,
    this.lastPageWidget,
    this.renderThreshold = 100.0,
    required this.itemBuilder,
    this.enableRefresh = true,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  ScrollPaginationState<T> createState() => ScrollPaginationState<T>();
}

class ScrollPaginationState<T> extends State<ScrollPagination<T>> {
  late final ScrollController _effectiveScrollController;

  @override
  void initState() {
    super.initState();
    _effectiveScrollController = widget.scrollController ?? ScrollController();
    _effectiveScrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _effectiveScrollController.removeListener(_onScroll);
    if (widget.scrollController == null) {
      _effectiveScrollController.dispose();
    }
    super.dispose();
  }

  /// Listener that triggers loading next page when near bottom.
  void _onScroll() {
    if (_isNearBottom()) {
      widget.controller.loadNextPage();
    }
  }

  /// Checks if the scroll is near the bottom based on the renderThreshold in pixels.
  bool _isNearBottom() {
    if (!_effectiveScrollController.hasClients) return false;
    final maxScroll = _effectiveScrollController.position.maxScrollExtent;
    final currentScroll = _effectiveScrollController.position.pixels;
    return currentScroll >= (maxScroll - widget.renderThreshold);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final state = widget.controller.state;

        if (state.isFirstPageLoading) {
          return _buildLoading(widget.firstPageLoadingWidget);
        }

        if (state.firstPageFailed) {
          return _buildError(
            widget.firstPageErrorWidget,
            state.errorMessage,
            widget.controller.retryLastFailedPage,
          );
        }

        if (state.items.isEmpty) {
          return widget.lastPageWidget ??
              const Center(child: Text("No items available"));
        }

        return RefreshIndicator(
          onRefresh:
              widget.enableRefresh ? widget.controller.refreshAll : () async {},
          child: ListView.builder(
            controller: _effectiveScrollController,
            shrinkWrap: widget.shrinkWrap,
            physics: widget.physics ?? AlwaysScrollableScrollPhysics(),
            scrollDirection: widget.scrollDirection,
            padding: widget.padding,
            itemCount: state.items.length + (state.hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < state.items.length) {
                return widget.itemBuilder(context, index, state.items[index]);
              } else {
                return _buildPageIndicator(state);
              }
            },
          ),
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
        widget.nextPageErrorWidget,
        state.errorMessage,
        widget.controller.retryLastFailedPage,
      );
    } else if (state.isLoadingNextPage) {
      return widget.nextPageLoadingWidget ??
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator.adaptive()),
          );
    } else {
      return widget.lastPageWidget ??
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text("No more data available")),
          );
    }
  }
}

/// ScrollPagination widget displays a paginated list with scroll detection.
/*
class ScrollPagination<T> extends StatefulWidget {
  final PaginationController<T> controller;
  final ScrollController scrollController;
  final Widget? firstPageLoadingWidget;
  final Widget? nextPageLoadingWidget;
  final Widget Function(
          BuildContext context, String errorMessage, VoidCallback retry)?
      firstPageErrorWidget;
  final Widget Function(
          BuildContext context, String errorMessage, VoidCallback retry)?
      nextPageErrorWidget;
  final Widget? lastPageWidget;
  final double renderThreshold;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final bool enableRefresh;

  const ScrollPagination({
    super.key,
    required this.controller,
    required this.scrollController,
    this.firstPageLoadingWidget,
    this.nextPageLoadingWidget,
    this.firstPageErrorWidget,
    this.nextPageErrorWidget,
    this.lastPageWidget,
    this.renderThreshold = 100.0,
    required this.itemBuilder,
    this.enableRefresh = true,
  });

  @override
  ScrollPaginationState<T> createState() => ScrollPaginationState<T>();
}

class ScrollPaginationState<T> extends State<ScrollPagination<T>> {
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  /// Listener that triggers loading next page when near bottom.
  void _onScroll() {
    if (_isNearBottom()) {
      widget.controller.loadNextPage();
    }
  }

  /// Checks if the scroll is near the bottom based on the renderThreshold in pixels.
  bool _isNearBottom() {
    if (!widget.scrollController.hasClients) return false;
    final maxScroll = widget.scrollController.position.maxScrollExtent;
    final currentScroll = widget.scrollController.position.pixels;
    return currentScroll >= (maxScroll - widget.renderThreshold);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final state = widget.controller.state;

        if (state.isFirstPageLoading) {
          return _buildLoading(widget.firstPageLoadingWidget);
        }

        if (state.firstPageFailed) {
          return _buildError(
            widget.firstPageErrorWidget,
            state.errorMessage,
            widget.controller.retryLastFailedPage,
          );
        }

        if (state.items.isEmpty) {
          return widget.lastPageWidget ??
              const Center(child: Text("No items available"));
        }

        return RefreshIndicator(
          onRefresh:
              widget.enableRefresh ? widget.controller.refreshAll : () async {},
          child: ListView.builder(
            // controller: widget.scrollController,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: state.items.length + (state.hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < state.items.length) {
                return widget.itemBuilder(context, index, state.items[index]);
              } else {
                return _buildPageIndicator(state);
              }
            },
          ),
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
        widget.nextPageErrorWidget,
        state.errorMessage,
        widget.controller.retryLastFailedPage,
      );
    } else if (state.isLoadingNextPage) {
      return widget.nextPageLoadingWidget ??
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator.adaptive()),
          );
    } else {
      return widget.lastPageWidget ??
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text("No more data available")),
          );
    }
  }
}
*/
