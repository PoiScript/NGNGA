import '../models/post.dart';
import '../models/user.dart';
import '../models/topic.dart';
import '../models/category.dart';

class CategoryState {
  final Category category;
  final List<int> topicIds;
  final int topicsCount;

  CategoryState({
    this.category,
    this.topicIds,
    this.topicsCount,
  });

  CategoryState copy({
    Category category,
    List<int> topicIds,
    int topicsCount,
  }) {
    return CategoryState(
      category: category ?? this.category,
      topicIds: topicIds ?? this.topicIds,
      topicsCount: topicsCount ?? this.topicsCount,
    );
  }
}

class TopicState {
  final Topic topic;
  final Map<int, List<Post>> pages;

  int get maxPage => topic.postsCount ~/ 20;

  TopicState({this.topic, this.pages});

  TopicState copy({
    Topic topic,
    Map<int, List<Post>> pages,
  }) {
    return TopicState(
      topic: topic ?? this.topic,
      pages: pages ?? this.pages,
    );
  }
}

class AppState {
  Map<int, User> users;

  Map<int, CategoryState> categories;

  Map<int, TopicState> topics;

  bool isLoading;

  Map<String, String> cookies;

  AppState({
    this.cookies,
    this.isLoading,
    this.users,
    this.topics,
    this.categories,
  });

  AppState copy({
    Map<int, CategoryState> categories,
    Map<int, TopicState> topics,
    Map<int, User> users,
    Map<String, String> cookies,
    bool isLoading,
  }) {
    return AppState(
      categories: categories ?? this.categories,
      topics: topics ?? this.topics,
      users: users ?? this.users,
      cookies: cookies ?? this.cookies,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppState &&
          users == other.users &&
          topics == other.topics &&
          categories == other.categories &&
          cookies == other.cookies;

  @override
  int get hashCode =>
      users.hashCode ^ topics.hashCode ^ categories.hashCode ^ cookies.hashCode;
}
