abstract class FavoriteState {
  const FavoriteState();
}

class FavoriteUninitialized extends FavoriteState {}

class FavoriteLoaded extends FavoriteState {
  final List<int> topicIds;

  final int topicsCount;

  final int lastPage;
  final int maxPage;

  const FavoriteLoaded({
    this.topicIds,
    this.topicsCount,
    this.lastPage,
    this.maxPage,
  })  : assert(topicIds != null),
        assert(topicsCount >= 0),
        assert(maxPage >= lastPage);

  FavoriteLoaded copyWith({
    List<int> topicIds,
    int topicsCount,
    int lastPage,
    int maxPage,
  }) =>
      FavoriteLoaded(
        topicIds: topicIds ?? this.topicIds,
        topicsCount: topicsCount ?? this.topicsCount,
        lastPage: lastPage ?? this.lastPage,
        maxPage: maxPage ?? this.maxPage,
      );
}
