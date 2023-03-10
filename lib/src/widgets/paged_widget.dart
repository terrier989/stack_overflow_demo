import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:stack_overflow_users/data.dart';

class PagedWidget<T> extends StatefulWidget {
  /// For our header in the user list page.
  final Widget? headerSliver;

  /// Copy of query parameters for determining whether the query has changed.
  final Object? Function() queryParametersCopy;

  /// Fetches a response from the API.
  final Future<PagedOutput<T>> Function(int page) queryFunction;

  /// Displays a single item.
  final Widget Function(BuildContext context, int i, T item) builder;

  /// Displayed when the list is empty.
  final Widget Function(BuildContext context)? emptyBuilder;

  const PagedWidget({
    super.key,
    required this.queryParametersCopy,
    this.headerSliver,
    required this.queryFunction,
    required this.builder,
    this.emptyBuilder,
  });

  @override
  State createState() => _PagedWidgetState<T>();
}

class _PagedWidgetState<T> extends State<PagedWidget<T>> {
  Object? _lastQueryParameters;
  final List<T> _items = [];
  int? _nextPage = 0;
  Future? _currentFetchFuture;
  Widget? _errorWidget;

  @override
  Widget build(BuildContext context) {
    final delegate = SliverChildBuilderDelegate(
      childCount: _items.length + 1,
      (context, i) {
        // Don't display more than one widget after the last item.
        if (i > _items.length) {
          return null;
        }

        // Prefetch a bit before reaching end of the list
        final nextPage = _nextPage;
        if (i + 10 > _items.length &&
            _currentFetchFuture == null &&
            nextPage != null) {
          // Schedule a fetch which will call setState() once it's done.
          _currentFetchFuture = _fetchPage(nextPage);
        }

        // Do we have an item at this index?
        if (i < _items.length) {
          return widget.builder(context, i, _items[i]);
        }

        if (nextPage == null) {
          // Is this because of an error?
          final errorWidget = _errorWidget;
          if (errorWidget != null) {
            return Container(
              padding: const EdgeInsets.all(40),
              child: errorWidget,
            );
          }

          // Should we display "the list is empty" widget?
          if (_items.isEmpty) {
            final emptyBuilder = widget.emptyBuilder;
            if (emptyBuilder != null) {
              return emptyBuilder(context);
            }
          }

          // No more items.
          return null;
        }

        // Display loading indicator.
        return const Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: CupertinoActivityIndicator(),
          ),
        );
      },
    );
    final header = widget.headerSliver;
    return CustomScrollView(
      slivers: [
        if (header != null) header,
        SliverList(
          delegate: delegate,
        ),
      ],
    );
  }

  @override
  void didUpdateWidget(covariant PagedWidget<T> oldWidget) {
    final newQueryParameters = widget.queryParametersCopy();
    if (!const DeepCollectionEquality()
        .equals(_lastQueryParameters, newQueryParameters)) {
      _lastQueryParameters = newQueryParameters;
      _items.clear();
      _nextPage = 0;
      _currentFetchFuture = null;
      _errorWidget = null;
    }
    super.didUpdateWidget(oldWidget);
  }

  Future _fetchPage(int page) async {
    try {
      final result = await widget.queryFunction(page);

      // Did we run out of API request quota?
      if (result.items.isEmpty && result.quotaRemaining == 0) {
        setState(() {
          _currentFetchFuture = null;
          _nextPage = null;
          _errorWidget = const Text(
            'Sorry, you can\'t see any more profiles because the app has requested too much data from StackOverflow. :(\n',
            softWrap: true,
          );
        });
        return;
      }

      setState(() {
        _items.addAll(result.items);
        _currentFetchFuture = null;
        if (result.hasMore) {
          // There are more pages after this
          _nextPage = page + 1;
        } else {
          // No more pages
          _nextPage = null;
        }
      });
    } catch (error, stackTrace) {
      setState(() {
        _currentFetchFuture = null;
        _nextPage = null;
        _errorWidget = Column(
          children: [
            const Text(
              'Unfortunately more StackOverflow data can\'t be fetched at the moment. :(',
              softWrap: true,
            ),

            // Show details for developers
            if (kDebugMode)
              Text(
                'Error:\n$error\n\nStack trace:$stackTrace',
              )
          ],
        );
      });
    }
  }
}
