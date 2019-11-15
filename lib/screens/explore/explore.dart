import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

import 'package:ngnga/const.dart';
import 'package:ngnga/models/category.dart';
import 'package:ngnga/store/router.dart';
import 'package:ngnga/store/state.dart';

class ExplorePage extends StatelessWidget {
  void Function(Category) navigateToCategory;

  ExplorePage({@required this.navigateToCategory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: Text(
          "Explore",
          style: Theme.of(context).textTheme.body2,
        ),
        titleSpacing: 0.0,
        backgroundColor: Colors.white,
      ),
      body: Scrollbar(
        child: CustomScrollView(
          slivers: [
            _buildList(context, "魔兽世界", wow0),
            _buildList(context, "魔兽世界 职业讨论区", wow1),
            _buildList(context, "魔兽世界 冒险心得", wow2),
            _buildList(context, "魔兽世界 历史背景 资料整理", wow3),
            _buildList(context, "网事杂谈", misc),
            _buildList(context, "IT 软硬件", tech),
            _buildList(context, "拳头游戏", lol),
            _buildList(context, "暴雪游戏", blizGame),
            _buildList(context, "手机/页游讨论", mobileGame),
            _buildList(context, "游戏综合讨论区", consoleGame),
            _buildList(context, "国家地理俱乐部", meta),
            _buildList(context, "个人版", personal),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    String name,
    List<Category> categories,
  ) {
    return SliverStickyHeader(
      header: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        color: Colors.white,
        child: Text(name, style: Theme.of(context).textTheme.caption),
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => ListTile(
            title: Text(categories[index].title),
            onTap: () => navigateToCategory(categories[index]),
            trailing: const Icon(Icons.keyboard_arrow_right),
          ),
          childCount: categories.length,
        ),
      ),
    );
  }
}

class ExplorePageConnector extends StatelessWidget {
  ExplorePageConnector();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(),
      builder: (context, vm) => ExplorePage(
        navigateToCategory: vm.navigateToCategory,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  void Function(Category) navigateToCategory;

  ViewModel();

  ViewModel.build({
    @required this.navigateToCategory,
  });

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      navigateToCategory: (category) =>
          dispatch(NavigateToCategoryAction(category)),
    );
  }
}
