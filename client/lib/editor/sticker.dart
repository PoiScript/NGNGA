import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

import 'package:business/bbcode/sticker.dart';

const pack0 = [
  'ac:blink',
  'ac:goodjob',
  'ac:上',
  'ac:中枪',
  'ac:偷笑',
  'ac:冷',
  'ac:凌乱',
  'ac:吓',
  'ac:吻',
  'ac:呆',
  'ac:咦',
  'ac:哦',
  'ac:哭',
  'ac:哭1',
  'ac:哭笑',
  'ac:喘',
  'ac:心',
  'ac:囧',
  'ac:晕',
  'ac:汗',
  'ac:瞎',
  'ac:羞',
  'ac:羡慕',
  'ac:委屈',
  'ac:忧伤',
  'ac:怒',
  'ac:怕',
  'ac:惊',
  'ac:愁',
  'ac:抓狂',
  'ac:哼',
  'ac:喷',
  'ac:嘲笑',
  'ac:嘲笑1',
  'ac:抠鼻',
  'ac:无语',
  'ac:衰',
  'ac:黑枪',
  'ac:花痴',
  'ac:闪光',
  'ac:擦汗',
  'ac:茶',
  'ac:计划通',
  'ac:反对',
  'ac:赞同',
];

const pack1 = [
  'a2:goodjob',
  'a2:诶嘿',
  'a2:偷笑',
  'a2:怒',
  'a2:笑',
  'a2:那个…',
  'a2:哦嗬嗬嗬',
  'a2:舔',
  'a2:鬼脸',
  'a2:冷',
  'a2:大哭',
  'a2:哭',
  'a2:恨',
  'a2:中枪',
  'a2:囧',
  'a2:你看看你',
  'a2:doge',
  'a2:自戳双目',
  'a2:偷吃',
  'a2:冷笑',
  'a2:壁咚',
  'a2:不活了',
  'a2:不明觉厉',
  'a2:是在下输了',
  'a2:你为猴这么',
  'a2:干杯',
  'a2:干杯2',
  'a2:异议',
  'a2:认真',
  'a2:你已经死了',
  'a2:你这种人…',
  'a2:妮可妮可妮',
  'a2:惊',
  'a2:抢镜头',
  'a2:yes',
  'a2:有何贵干',
  'a2:病娇',
  'a2:lucky',
  'a2:poi',
  'a2:囧2',
  'a2:威吓',
  'a2:jojo立',
  'a2:jojo立2',
  'a2:jojo立3',
  'a2:jojo立4',
  'a2:jojo立5',
];

const pack2 = [
  'pst:举手',
  'pst:亲',
  'pst:偷笑',
  'pst:偷笑2',
  'pst:偷笑3',
  'pst:傻眼',
  'pst:傻眼2',
  'pst:兔子',
  'pst:发光',
  'pst:呆',
  'pst:呆2',
  'pst:呆3',
  'pst:呕',
  'pst:呵欠',
  'pst:哭',
  'pst:哭2',
  'pst:哭3',
  'pst:嘲笑',
  'pst:基',
  'pst:宅',
  'pst:安慰',
  'pst:幸福',
  'pst:开心',
  'pst:开心2',
  'pst:开心3',
  'pst:怀疑',
  'pst:怒',
  'pst:怒2',
  'pst:怨',
  'pst:惊吓',
  'pst:惊吓2',
  'pst:惊呆',
  'pst:惊呆2',
  'pst:惊呆3',
  'pst:惨',
  'pst:斜眼',
  'pst:晕',
  'pst:汗',
  'pst:泪',
  'pst:泪2',
  'pst:泪3',
  'pst:泪4',
  'pst:满足',
  'pst:满足2',
  'pst:火星',
  'pst:牙疼',
  'pst:电击',
  'pst:看戏',
  'pst:眼袋',
  'pst:眼镜',
  'pst:笑而不语',
  'pst:紧张',
  'pst:美味',
  'pst:背',
  'pst:脸红',
  'pst:脸红2',
  'pst:腐',
  'pst:星星眼',
  'pst:谢',
  'pst:醉',
  'pst:闷',
  'pst:闷2',
  'pst:音乐',
  'pst:黑脸',
  'pst:鼻血',
];

const pack3 = [
  'dt:ROLL',
  'dt:上',
  'dt:傲娇',
  'dt:叉出去',
  'dt:发光',
  'dt:呵欠',
  'dt:哭',
  'dt:啃古头',
  'dt:嘲笑',
  'dt:心',
  'dt:怒',
  'dt:怒2',
  'dt:怨',
  'dt:惊',
  'dt:惊2',
  'dt:无语',
  'dt:星星眼',
  'dt:星星眼2',
  'dt:晕',
  'dt:注意',
  'dt:注意2',
  'dt:泪',
  'dt:泪2',
  'dt:烧',
  'dt:笑',
  'dt:笑2',
  'dt:笑3',
  'dt:脸红',
  'dt:药',
  'dt:衰',
  'dt:鄙视',
  'dt:闲',
  'dt:黑脸',
];

const pack4 = [
  'pg:战斗力',
  'pg:哈啤',
  'pg:满分',
  'pg:衰',
  'pg:拒绝',
  'pg:心',
  'pg:严肃',
  'pg:吃瓜',
  'pg:嘣',
  'pg:嘣2',
  'pg:冻',
  'pg:谢',
  'pg:哭',
  'pg:响指',
  'pg:转身',
];

class EditorSticker extends StatelessWidget {
  final void Function(String) insertSticker;

  EditorSticker({
    @required this.insertSticker,
  }) : assert(insertSticker != null);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        _StickyStickerHeader(
          packName: 'Package 0',
          stickerPack: pack0,
          insertSticker: insertSticker,
        ),
        _StickyStickerHeader(
          packName: 'Package 1',
          stickerPack: pack1,
          insertSticker: insertSticker,
        ),
        _StickyStickerHeader(
          packName: 'Package 2',
          stickerPack: pack2,
          insertSticker: insertSticker,
        ),
        _StickyStickerHeader(
          packName: 'Package 3',
          stickerPack: pack3,
          insertSticker: insertSticker,
        ),
        _StickyStickerHeader(
          packName: 'Package 4',
          stickerPack: pack4,
          insertSticker: insertSticker,
        ),
      ],
    );
  }
}

class _StickyStickerHeader extends StatelessWidget {
  final String packName;
  final List<String> stickerPack;
  final ValueChanged<String> insertSticker;

  const _StickyStickerHeader({
    Key key,
    @required this.stickerPack,
    @required this.insertSticker,
    @required this.packName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverStickyHeader(
      header: Container(
        padding: const EdgeInsets.all(2.0),
        constraints: const BoxConstraints(minWidth: double.infinity),
        color: Theme.of(context).cardColor,
        child: Text(
          packName,
          style: Theme.of(context).textTheme.caption,
        ),
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => GestureDetector(
            child:
                _Sticker(filename: stickerNameToFilename[stickerPack[index]]),
            onTap: () => insertSticker(stickerPack[index]),
          ),
          childCount: stickerPack.length,
        ),
      ),
    );
  }
}

class _Sticker extends StatelessWidget {
  final String filename;

  const _Sticker({
    Key key,
    this.filename,
  })  : assert(filename != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.all(2.0),
      child: Image.asset(
        'assets/stickers/${isDark ? 'dark' : 'light'}/$filename',
        width: 32.0,
      ),
    );
  }
}
