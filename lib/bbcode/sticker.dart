import 'package:flutter/material.dart';

String urlToName(String url) {
  if (url.startsWith('http://')) {
    url = url.substring('http://'.length);
  } else if (url.startsWith('https://')) {
    url = url.substring('https://'.length);
  }

  url = url.replaceAll('img4.nga.178.com', 'img4.nga.cn');

  return _pathToName[url];
}

const _pathToName = {
  // https://github.com/ymback/NGA-CLIENT-VER-OPEN-SOURCE/blob/822b4236c65d077c0d61a8159498f7a610c51d49/nga_phone_base_3.0/src/main/java/sp/phone/util/EmoticonUtils.java
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bca81a77f.png':
      'ac:blink',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bd3b4b3bd.png':
      'ac:goodjob',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bcba15fcf.png': 'ac:中枪',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bcb6e96d1.png': 'ac:偷笑',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bd2a0d49a.png': 'ac:冷',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052c10aa0303.png': 'ac:凌乱',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bcaaacb45.png': 'ac:反对',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052c104b8e27.png': 'ac:吻',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bc587c6f9.png': 'ac:呆',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052c1076f119.png': 'ac:咦',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bd2497822.png': 'ac:哦',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bd2fa0790.png': 'ac:哭',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052c0f6da079.png': 'ac:哭1',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bc4cc6331.png': 'ac:哭笑',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bcf37c4c9.png': 'ac:哼',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bc4f51be7.png': 'ac:喷',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052c1101747c.png': 'ac:嘲笑',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052c10d1f08c.png':
      'ac:嘲笑1',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bcdd279bc.png': 'ac:囧',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bce27ab4d.png': 'ac:委屈',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bd35aec58.png': 'ac:心',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bcdfd9c69.png': 'ac:忧伤',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bc835856c.png': 'ac:怒',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bce4f2963.png': 'ac:怕',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bd330dfad.png': 'ac:惊',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bc7d91913.png': 'ac:愁',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052c112b3b1b.png': 'ac:抓狂',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bcf0ba2db.png': 'ac:抠鼻',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bc8638067.png': 'ac:擦汗',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bca55cb6e.png': 'ac:无语',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bc521c04b.png': 'ac:晕',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bca2a2f43.png': 'ac:汗',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bcad49530.png': 'ac:瞎',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bceb823da.png': 'ac:羞',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bc80140e3.png': 'ac:羡慕',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bcb3b8944.png': 'ac:花痴',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bcf68ddc2.png': 'ac:衰',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bd27520ef.png': 'ac:赞同',
  'img.nga.178.com/attachments/mon_201209/14/-47218_5052bcbe35760.png': 'ac:闪光',
  'img4.nga.cn/ngabbs/post/smile/ac0.png': 'ac:blink',
  'img4.nga.cn/ngabbs/post/smile/ac1.png': 'ac:goodjob',
  'img4.nga.cn/ngabbs/post/smile/ac2.png': 'ac:上',
  'img4.nga.cn/ngabbs/post/smile/ac3.png': 'ac:中枪',
  'img4.nga.cn/ngabbs/post/smile/ac4.png': 'ac:偷笑',
  'img4.nga.cn/ngabbs/post/smile/ac5.png': 'ac:冷',
  'img4.nga.cn/ngabbs/post/smile/ac6.png': 'ac:凌乱',
  'img4.nga.cn/ngabbs/post/smile/ac8.png': 'ac:吓',
  'img4.nga.cn/ngabbs/post/smile/ac9.png': 'ac:吻',
  'img4.nga.cn/ngabbs/post/smile/ac10.png': 'ac:呆',
  'img4.nga.cn/ngabbs/post/smile/ac11.png': 'ac:咦',
  'img4.nga.cn/ngabbs/post/smile/ac12.png': 'ac:哦',
  'img4.nga.cn/ngabbs/post/smile/ac13.png': 'ac:哭',
  'img4.nga.cn/ngabbs/post/smile/ac14.png': 'ac:哭1',
  'img4.nga.cn/ngabbs/post/smile/ac15.png': 'ac:哭笑',
  'img4.nga.cn/ngabbs/post/smile/ac17.png': 'ac:喘',
  'img4.nga.cn/ngabbs/post/smile/ac23.png': 'ac:心',
  'img4.nga.cn/ngabbs/post/smile/ac21.png': 'ac:囧',
  'img4.nga.cn/ngabbs/post/smile/ac33.png': 'ac:晕',
  'img4.nga.cn/ngabbs/post/smile/ac34.png': 'ac:汗',
  'img4.nga.cn/ngabbs/post/smile/ac35.png': 'ac:瞎',
  'img4.nga.cn/ngabbs/post/smile/ac36.png': 'ac:羞',
  'img4.nga.cn/ngabbs/post/smile/ac37.png': 'ac:羡慕',
  'img4.nga.cn/ngabbs/post/smile/ac22.png': 'ac:委屈',
  'img4.nga.cn/ngabbs/post/smile/ac24.png': 'ac:忧伤',
  'img4.nga.cn/ngabbs/post/smile/ac25.png': 'ac:怒',
  'img4.nga.cn/ngabbs/post/smile/ac26.png': 'ac:怕',
  'img4.nga.cn/ngabbs/post/smile/ac27.png': 'ac:惊',
  'img4.nga.cn/ngabbs/post/smile/ac28.png': 'ac:愁',
  'img4.nga.cn/ngabbs/post/smile/ac29.png': 'ac:抓狂',
  'img4.nga.cn/ngabbs/post/smile/ac16.png': 'ac:哼',
  'img4.nga.cn/ngabbs/post/smile/ac18.png': 'ac:喷',
  'img4.nga.cn/ngabbs/post/smile/ac19.png': 'ac:嘲笑',
  'img4.nga.cn/ngabbs/post/smile/ac20.png': 'ac:嘲笑1',
  'img4.nga.cn/ngabbs/post/smile/ac30.png': 'ac:抠鼻',
  'img4.nga.cn/ngabbs/post/smile/ac32.png': 'ac:无语',
  'img4.nga.cn/ngabbs/post/smile/ac40.png': 'ac:衰',
  'img4.nga.cn/ngabbs/post/smile/ac44.png': 'ac:黑枪',
  'img4.nga.cn/ngabbs/post/smile/ac38.png': 'ac:花痴',
  'img4.nga.cn/ngabbs/post/smile/ac43.png': 'ac:闪光',
  'img4.nga.cn/ngabbs/post/smile/ac31.png': 'ac:擦汗',
  'img4.nga.cn/ngabbs/post/smile/ac39.png': 'ac:茶',
  'img4.nga.cn/ngabbs/post/smile/ac41.png': 'ac:计划通',
  'img4.nga.cn/ngabbs/post/smile/ac7.png': 'ac:反对',
  'img4.nga.cn/ngabbs/post/smile/ac42.png': 'ac:赞同',
  'img4.nga.cn/ngabbs/post/smile/a2_02.png': 'a2:goodjob',
  'img4.nga.cn/ngabbs/post/smile/a2_05.png': 'a2:诶嘿',
  'img4.nga.cn/ngabbs/post/smile/a2_03.png': 'a2:偷笑',
  'img4.nga.cn/ngabbs/post/smile/a2_04.png': 'a2:怒',
  'img4.nga.cn/ngabbs/post/smile/a2_07.png': 'a2:笑',
  'img4.nga.cn/ngabbs/post/smile/a2_08.png': 'a2:那个…',
  'img4.nga.cn/ngabbs/post/smile/a2_09.png': 'a2:哦嗬嗬嗬',
  'img4.nga.cn/ngabbs/post/smile/a2_10.png': 'a2:舔',
  'img4.nga.cn/ngabbs/post/smile/a2_14.png': 'a2:鬼脸',
  'img4.nga.cn/ngabbs/post/smile/a2_16.png': 'a2:冷',
  'img4.nga.cn/ngabbs/post/smile/a2_15.png': 'a2:大哭',
  'img4.nga.cn/ngabbs/post/smile/a2_17.png': 'a2:哭',
  'img4.nga.cn/ngabbs/post/smile/a2_21.png': 'a2:恨',
  'img4.nga.cn/ngabbs/post/smile/a2_23.png': 'a2:中枪',
  'img4.nga.cn/ngabbs/post/smile/a2_24.png': 'a2:囧',
  'img4.nga.cn/ngabbs/post/smile/a2_25.png': 'a2:你看看你',
  'img4.nga.cn/ngabbs/post/smile/a2_27.png': 'a2:doge',
  'img4.nga.cn/ngabbs/post/smile/a2_28.png': 'a2:自戳双目',
  'img4.nga.cn/ngabbs/post/smile/a2_30.png': 'a2:偷吃',
  'img4.nga.cn/ngabbs/post/smile/a2_31.png': 'a2:冷笑',
  'img4.nga.cn/ngabbs/post/smile/a2_32.png': 'a2:壁咚',
  'img4.nga.cn/ngabbs/post/smile/a2_33.png': 'a2:不活了',
  'img4.nga.cn/ngabbs/post/smile/a2_36.png': 'a2:不明觉厉',
  'img4.nga.cn/ngabbs/post/smile/a2_51.png': 'a2:是在下输了',
  'img4.nga.cn/ngabbs/post/smile/a2_53.png': 'a2:你为猴这么',
  'img4.nga.cn/ngabbs/post/smile/a2_54.png': 'a2:干杯',
  'img4.nga.cn/ngabbs/post/smile/a2_55.png': 'a2:干杯2',
  'img4.nga.cn/ngabbs/post/smile/a2_47.png': 'a2:异议',
  'img4.nga.cn/ngabbs/post/smile/a2_48.png': 'a2:认真',
  'img4.nga.cn/ngabbs/post/smile/a2_45.png': 'a2:你已经死了',
  'img4.nga.cn/ngabbs/post/smile/a2_49.png': 'a2:你这种人…',
  'img4.nga.cn/ngabbs/post/smile/a2_18.png': 'a2:妮可妮可妮',
  'img4.nga.cn/ngabbs/post/smile/a2_19.png': 'a2:惊',
  'img4.nga.cn/ngabbs/post/smile/a2_52.png': 'a2:抢镜头',
  'img4.nga.cn/ngabbs/post/smile/a2_26.png': 'a2:yes',
  'img4.nga.cn/ngabbs/post/smile/a2_11.png': 'a2:有何贵干',
  'img4.nga.cn/ngabbs/post/smile/a2_12.png': 'a2:病娇',
  'img4.nga.cn/ngabbs/post/smile/a2_13.png': 'a2:lucky',
  'img4.nga.cn/ngabbs/post/smile/a2_20.png': 'a2:poi',
  'img4.nga.cn/ngabbs/post/smile/a2_22.png': 'a2:囧2',
  'img4.nga.cn/ngabbs/post/smile/a2_42.png': 'a2:威吓',
  'img4.nga.cn/ngabbs/post/smile/a2_37.png': 'a2:jojo立',
  'img4.nga.cn/ngabbs/post/smile/a2_38.png': 'a2:jojo立2',
  'img4.nga.cn/ngabbs/post/smile/a2_39.png': 'a2:jojo立3',
  'img4.nga.cn/ngabbs/post/smile/a2_41.png': 'a2:jojo立4',
  'img4.nga.cn/ngabbs/post/smile/a2_40.png': 'a2:jojo立5',
  'img4.nga.cn/ngabbs/post/smile/pt00.png': 'pst:举手',
  'img4.nga.cn/ngabbs/post/smile/pt01.png': 'pst:亲',
  'img4.nga.cn/ngabbs/post/smile/pt02.png': 'pst:偷笑',
  'img4.nga.cn/ngabbs/post/smile/pt03.png': 'pst:偷笑2',
  'img4.nga.cn/ngabbs/post/smile/pt04.png': 'pst:偷笑3',
  'img4.nga.cn/ngabbs/post/smile/pt05.png': 'pst:傻眼',
  'img4.nga.cn/ngabbs/post/smile/pt06.png': 'pst:傻眼2',
  'img4.nga.cn/ngabbs/post/smile/pt07.png': 'pst:兔子',
  'img4.nga.cn/ngabbs/post/smile/pt08.png': 'pst:发光',
  'img4.nga.cn/ngabbs/post/smile/pt09.png': 'pst:呆',
  'img4.nga.cn/ngabbs/post/smile/pt10.png': 'pst:呆2',
  'img4.nga.cn/ngabbs/post/smile/pt11.png': 'pst:呆3',
  'img4.nga.cn/ngabbs/post/smile/pt12.png': 'pst:呕',
  'img4.nga.cn/ngabbs/post/smile/pt13.png': 'pst:呵欠',
  'img4.nga.cn/ngabbs/post/smile/pt14.png': 'pst:哭',
  'img4.nga.cn/ngabbs/post/smile/pt15.png': 'pst:哭2',
  'img4.nga.cn/ngabbs/post/smile/pt16.png': 'pst:哭3',
  'img4.nga.cn/ngabbs/post/smile/pt17.png': 'pst:嘲笑',
  'img4.nga.cn/ngabbs/post/smile/pt18.png': 'pst:基',
  'img4.nga.cn/ngabbs/post/smile/pt19.png': 'pst:宅',
  'img4.nga.cn/ngabbs/post/smile/pt20.png': 'pst:安慰',
  'img4.nga.cn/ngabbs/post/smile/pt21.png': 'pst:幸福',
  'img4.nga.cn/ngabbs/post/smile/pt22.png': 'pst:开心',
  'img4.nga.cn/ngabbs/post/smile/pt23.png': 'pst:开心2',
  'img4.nga.cn/ngabbs/post/smile/pt24.png': 'pst:开心3',
  'img4.nga.cn/ngabbs/post/smile/pt25.png': 'pst:怀疑',
  'img4.nga.cn/ngabbs/post/smile/pt26.png': 'pst:怒',
  'img4.nga.cn/ngabbs/post/smile/pt27.png': 'pst:怒2',
  'img4.nga.cn/ngabbs/post/smile/pt28.png': 'pst:怨',
  'img4.nga.cn/ngabbs/post/smile/pt29.png': 'pst:惊吓',
  'img4.nga.cn/ngabbs/post/smile/pt30.png': 'pst:惊吓2',
  'img4.nga.cn/ngabbs/post/smile/pt31.png': 'pst:惊呆',
  'img4.nga.cn/ngabbs/post/smile/pt32.png': 'pst:惊呆2',
  'img4.nga.cn/ngabbs/post/smile/pt33.png': 'pst:惊呆3',
  'img4.nga.cn/ngabbs/post/smile/pt34.png': 'pst:惨',
  'img4.nga.cn/ngabbs/post/smile/pt35.png': 'pst:斜眼',
  'img4.nga.cn/ngabbs/post/smile/pt36.png': 'pst:晕',
  'img4.nga.cn/ngabbs/post/smile/pt37.png': 'pst:汗',
  'img4.nga.cn/ngabbs/post/smile/pt38.png': 'pst:泪',
  'img4.nga.cn/ngabbs/post/smile/pt39.png': 'pst:泪2',
  'img4.nga.cn/ngabbs/post/smile/pt40.png': 'pst:泪3',
  'img4.nga.cn/ngabbs/post/smile/pt41.png': 'pst:泪4',
  'img4.nga.cn/ngabbs/post/smile/pt42.png': 'pst:满足',
  'img4.nga.cn/ngabbs/post/smile/pt43.png': 'pst:满足2',
  'img4.nga.cn/ngabbs/post/smile/pt44.png': 'pst:火星',
  'img4.nga.cn/ngabbs/post/smile/pt45.png': 'pst:牙疼',
  'img4.nga.cn/ngabbs/post/smile/pt46.png': 'pst:电击',
  'img4.nga.cn/ngabbs/post/smile/pt47.png': 'pst:看戏',
  'img4.nga.cn/ngabbs/post/smile/pt48.png': 'pst:眼袋',
  'img4.nga.cn/ngabbs/post/smile/pt49.png': 'pst:眼镜',
  'img4.nga.cn/ngabbs/post/smile/pt50.png': 'pst:笑而不语',
  'img4.nga.cn/ngabbs/post/smile/pt51.png': 'pst:紧张',
  'img4.nga.cn/ngabbs/post/smile/pt52.png': 'pst:美味',
  'img4.nga.cn/ngabbs/post/smile/pt53.png': 'pst:背',
  'img4.nga.cn/ngabbs/post/smile/pt54.png': 'pst:脸红',
  'img4.nga.cn/ngabbs/post/smile/pt55.png': 'pst:脸红2',
  'img4.nga.cn/ngabbs/post/smile/pt56.png': 'pst:腐',
  'img4.nga.cn/ngabbs/post/smile/pt57.png': 'pst:星星眼',
  'img4.nga.cn/ngabbs/post/smile/pt58.png': 'pst:谢',
  'img4.nga.cn/ngabbs/post/smile/pt59.png': 'pst:醉',
  'img4.nga.cn/ngabbs/post/smile/pt60.png': 'pst:闷',
  'img4.nga.cn/ngabbs/post/smile/pt61.png': 'pst:闷2',
  'img4.nga.cn/ngabbs/post/smile/pt62.png': 'pst:音乐',
  'img4.nga.cn/ngabbs/post/smile/pt63.png': 'pst:黑脸',
  'img4.nga.cn/ngabbs/post/smile/pt64.png': 'pst:鼻血',
  'img4.nga.cn/ngabbs/post/smile/dt01.png': 'dt:ROLL',
  'img4.nga.cn/ngabbs/post/smile/dt02.png': 'dt:上',
  'img4.nga.cn/ngabbs/post/smile/dt03.png': 'dt:傲娇',
  'img4.nga.cn/ngabbs/post/smile/dt04.png': 'dt:叉出去',
  'img4.nga.cn/ngabbs/post/smile/dt05.png': 'dt:发光',
  'img4.nga.cn/ngabbs/post/smile/dt06.png': 'dt:呵欠',
  'img4.nga.cn/ngabbs/post/smile/dt07.png': 'dt:哭',
  'img4.nga.cn/ngabbs/post/smile/dt08.png': 'dt:啃古头',
  'img4.nga.cn/ngabbs/post/smile/dt09.png': 'dt:嘲笑',
  'img4.nga.cn/ngabbs/post/smile/dt10.png': 'dt:心',
  'img4.nga.cn/ngabbs/post/smile/dt11.png': 'dt:怒',
  'img4.nga.cn/ngabbs/post/smile/dt12.png': 'dt:怒2',
  'img4.nga.cn/ngabbs/post/smile/dt13.png': 'dt:怨',
  'img4.nga.cn/ngabbs/post/smile/dt14.png': 'dt:惊',
  'img4.nga.cn/ngabbs/post/smile/dt15.png': 'dt:惊2',
  'img4.nga.cn/ngabbs/post/smile/dt16.png': 'dt:无语',
  'img4.nga.cn/ngabbs/post/smile/dt17.png': 'dt:星星眼',
  'img4.nga.cn/ngabbs/post/smile/dt18.png': 'dt:星星眼2',
  'img4.nga.cn/ngabbs/post/smile/dt19.png': 'dt:晕',
  'img4.nga.cn/ngabbs/post/smile/dt20.png': 'dt:注意',
  'img4.nga.cn/ngabbs/post/smile/dt21.png': 'dt:注意2',
  'img4.nga.cn/ngabbs/post/smile/dt22.png': 'dt:泪',
  'img4.nga.cn/ngabbs/post/smile/dt23.png': 'dt:泪2',
  'img4.nga.cn/ngabbs/post/smile/dt24.png': 'dt:烧',
  'img4.nga.cn/ngabbs/post/smile/dt25.png': 'dt:笑',
  'img4.nga.cn/ngabbs/post/smile/dt26.png': 'dt:笑2',
  'img4.nga.cn/ngabbs/post/smile/dt27.png': 'dt:笑3',
  'img4.nga.cn/ngabbs/post/smile/dt28.png': 'dt:脸红',
  'img4.nga.cn/ngabbs/post/smile/dt29.png': 'dt:药',
  'img4.nga.cn/ngabbs/post/smile/dt30.png': 'dt:衰',
  'img4.nga.cn/ngabbs/post/smile/dt31.png': 'dt:鄙视',
  'img4.nga.cn/ngabbs/post/smile/dt32.png': 'dt:闲',
  'img4.nga.cn/ngabbs/post/smile/dt33.png': 'dt:黑脸',
  'img4.nga.cn/ngabbs/post/smile/pg01.png': 'pg:战斗力',
  'img4.nga.cn/ngabbs/post/smile/pg02.png': 'pg:哈啤',
  'img4.nga.cn/ngabbs/post/smile/pg03.png': 'pg:满分',
  'img4.nga.cn/ngabbs/post/smile/pg04.png': 'pg:衰',
  'img4.nga.cn/ngabbs/post/smile/pg05.png': 'pg:拒绝',
  'img4.nga.cn/ngabbs/post/smile/pg06.png': 'pg:心',
  'img4.nga.cn/ngabbs/post/smile/pg07.png': 'pg:严肃',
  'img4.nga.cn/ngabbs/post/smile/pg08.png': 'pg:吃瓜',
  'img4.nga.cn/ngabbs/post/smile/pg09.png': 'pg:嘣',
  'img4.nga.cn/ngabbs/post/smile/pg10.png': 'pg:嘣2',
  'img4.nga.cn/ngabbs/post/smile/pg11.png': 'pg:冻',
  'img4.nga.cn/ngabbs/post/smile/pg12.png': 'pg:谢',
  'img4.nga.cn/ngabbs/post/smile/pg13.png': 'pg:哭',
  'img4.nga.cn/ngabbs/post/smile/pg14.png': 'pg:响指',
  'img4.nga.cn/ngabbs/post/smile/pg15.png': 'pg:转身',
};

const stickerNames = [
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

const _stickerNameToLocalPath = {
  'ac:blink': 'ac0.png',
  'ac:goodjob': 'ac1.png',
  'ac:上': 'ac2.png',
  'ac:中枪': 'ac3.png',
  'ac:偷笑': 'ac4.png',
  'ac:冷': 'ac5.png',
  'ac:凌乱': 'ac6.png',
  'ac:吓': 'ac8.png',
  'ac:吻': 'ac9.png',
  'ac:呆': 'ac10.png',
  'ac:咦': 'ac11.png',
  'ac:哦': 'ac12.png',
  'ac:哭': 'ac13.png',
  'ac:哭1': 'ac14.png',
  'ac:哭笑': 'ac15.png',
  'ac:喘': 'ac17.png',
  'ac:心': 'ac23.png',
  'ac:囧': 'ac21.png',
  'ac:晕': 'ac33.png',
  'ac:汗': 'ac34.png',
  'ac:瞎': 'ac35.png',
  'ac:羞': 'ac36.png',
  'ac:羡慕': 'ac37.png',
  'ac:委屈': 'ac22.png',
  'ac:忧伤': 'ac24.png',
  'ac:怒': 'ac25.png',
  'ac:怕': 'ac26.png',
  'ac:惊': 'ac27.png',
  'ac:愁': 'ac28.png',
  'ac:抓狂': 'ac29.png',
  'ac:哼': 'ac16.png',
  'ac:喷': 'ac18.png',
  'ac:嘲笑': 'ac19.png',
  'ac:嘲笑1': 'ac20.png',
  'ac:抠鼻': 'ac30.png',
  'ac:无语': 'ac32.png',
  'ac:衰': 'ac40.png',
  'ac:黑枪': 'ac44.png',
  'ac:花痴': 'ac38.png',
  'ac:闪光': 'ac43.png',
  'ac:擦汗': 'ac31.png',
  'ac:茶': 'ac39.png',
  'ac:计划通': 'ac41.png',
  'ac:反对': 'ac7.png',
  'ac:赞同': 'ac42.png',
  'a2:goodjob': 'a2_02.png',
  'a2:诶嘿': 'a2_05.png',
  'a2:偷笑': 'a2_03.png',
  'a2:怒': 'a2_04.png',
  'a2:笑': 'a2_07.png',
  'a2:那个…': 'a2_08.png',
  'a2:哦嗬嗬嗬': 'a2_09.png',
  'a2:舔': 'a2_10.png',
  'a2:鬼脸': 'a2_14.png',
  'a2:冷': 'a2_16.png',
  'a2:大哭': 'a2_15.png',
  'a2:哭': 'a2_17.png',
  'a2:恨': 'a2_21.png',
  'a2:中枪': 'a2_23.png',
  'a2:囧': 'a2_24.png',
  'a2:你看看你': 'a2_25.png',
  'a2:doge': 'a2_27.png',
  'a2:自戳双目': 'a2_28.png',
  'a2:偷吃': 'a2_30.png',
  'a2:冷笑': 'a2_31.png',
  'a2:壁咚': 'a2_32.png',
  'a2:不活了': 'a2_33.png',
  'a2:不明觉厉': 'a2_36.png',
  'a2:是在下输了': 'a2_51.png',
  'a2:你为猴这么': 'a2_53.png',
  'a2:干杯': 'a2_54.png',
  'a2:干杯2': 'a2_55.png',
  'a2:异议': 'a2_47.png',
  'a2:认真': 'a2_48.png',
  'a2:你已经死了': 'a2_45.png',
  'a2:你这种人…': 'a2_49.png',
  'a2:妮可妮可妮': 'a2_18.png',
  'a2:惊': 'a2_19.png',
  'a2:抢镜头': 'a2_52.png',
  'a2:yes': 'a2_26.png',
  'a2:有何贵干': 'a2_11.png',
  'a2:病娇': 'a2_12.png',
  'a2:lucky': 'a2_13.png',
  'a2:poi': 'a2_20.png',
  'a2:囧2': 'a2_22.png',
  'a2:威吓': 'a2_42.png',
  'a2:jojo立': 'a2_37.png',
  'a2:jojo立2': 'a2_38.png',
  'a2:jojo立3': 'a2_39.png',
  'a2:jojo立4': 'a2_41.png',
  'a2:jojo立5': 'a2_40.png',
  'pst:举手': 'pt00.png',
  'pst:亲': 'pt01.png',
  'pst:偷笑': 'pt02.png',
  'pst:偷笑2': 'pt03.png',
  'pst:偷笑3': 'pt04.png',
  'pst:傻眼': 'pt05.png',
  'pst:傻眼2': 'pt06.png',
  'pst:兔子': 'pt07.png',
  'pst:发光': 'pt08.png',
  'pst:呆': 'pt09.png',
  'pst:呆2': 'pt10.png',
  'pst:呆3': 'pt11.png',
  'pst:呕': 'pt12.png',
  'pst:呵欠': 'pt13.png',
  'pst:哭': 'pt14.png',
  'pst:哭2': 'pt15.png',
  'pst:哭3': 'pt16.png',
  'pst:嘲笑': 'pt17.png',
  'pst:基': 'pt18.png',
  'pst:宅': 'pt19.png',
  'pst:安慰': 'pt20.png',
  'pst:幸福': 'pt21.png',
  'pst:开心': 'pt22.png',
  'pst:开心2': 'pt23.png',
  'pst:开心3': 'pt24.png',
  'pst:怀疑': 'pt25.png',
  'pst:怒': 'pt26.png',
  'pst:怒2': 'pt27.png',
  'pst:怨': 'pt28.png',
  'pst:惊吓': 'pt29.png',
  'pst:惊吓2': 'pt30.png',
  'pst:惊呆': 'pt31.png',
  'pst:惊呆2': 'pt32.png',
  'pst:惊呆3': 'pt33.png',
  'pst:惨': 'pt34.png',
  'pst:斜眼': 'pt35.png',
  'pst:晕': 'pt36.png',
  'pst:汗': 'pt37.png',
  'pst:泪': 'pt38.png',
  'pst:泪2': 'pt39.png',
  'pst:泪3': 'pt40.png',
  'pst:泪4': 'pt41.png',
  'pst:满足': 'pt42.png',
  'pst:满足2': 'pt43.png',
  'pst:火星': 'pt44.png',
  'pst:牙疼': 'pt45.png',
  'pst:电击': 'pt46.png',
  'pst:看戏': 'pt47.png',
  'pst:眼袋': 'pt48.png',
  'pst:眼镜': 'pt49.png',
  'pst:笑而不语': 'pt50.png',
  'pst:紧张': 'pt51.png',
  'pst:美味': 'pt52.png',
  'pst:背': 'pt53.png',
  'pst:脸红': 'pt54.png',
  'pst:脸红2': 'pt55.png',
  'pst:腐': 'pt56.png',
  'pst:星星眼': 'pt57.png',
  'pst:谢': 'pt58.png',
  'pst:醉': 'pt59.png',
  'pst:闷': 'pt60.png',
  'pst:闷2': 'pt61.png',
  'pst:音乐': 'pt62.png',
  'pst:黑脸': 'pt63.png',
  'pst:鼻血': 'pt64.png',
  'dt:ROLL': 'dt01.png',
  'dt:上': 'dt02.png',
  'dt:傲娇': 'dt03.png',
  'dt:叉出去': 'dt04.png',
  'dt:发光': 'dt05.png',
  'dt:呵欠': 'dt06.png',
  'dt:哭': 'dt07.png',
  'dt:啃古头': 'dt08.png',
  'dt:嘲笑': 'dt09.png',
  'dt:心': 'dt10.png',
  'dt:怒': 'dt11.png',
  'dt:怒2': 'dt12.png',
  'dt:怨': 'dt13.png',
  'dt:惊': 'dt14.png',
  'dt:惊2': 'dt15.png',
  'dt:无语': 'dt16.png',
  'dt:星星眼': 'dt17.png',
  'dt:星星眼2': 'dt18.png',
  'dt:晕': 'dt19.png',
  'dt:注意': 'dt20.png',
  'dt:注意2': 'dt21.png',
  'dt:泪': 'dt22.png',
  'dt:泪2': 'dt23.png',
  'dt:烧': 'dt24.png',
  'dt:笑': 'dt25.png',
  'dt:笑2': 'dt26.png',
  'dt:笑3': 'dt27.png',
  'dt:脸红': 'dt28.png',
  'dt:药': 'dt29.png',
  'dt:衰': 'dt30.png',
  'dt:鄙视': 'dt31.png',
  'dt:闲': 'dt32.png',
  'dt:黑脸': 'dt33.png',
  'pg:战斗力': 'pg01.png',
  'pg:哈啤': 'pg02.png',
  'pg:满分': 'pg03.png',
  'pg:衰': 'pg04.png',
  'pg:拒绝': 'pg05.png',
  'pg:心': 'pg06.png',
  'pg:严肃': 'pg07.png',
  'pg:吃瓜': 'pg08.png',
  'pg:嘣': 'pg09.png',
  'pg:嘣2': 'pg10.png',
  'pg:冻': 'pg11.png',
  'pg:谢': 'pg12.png',
  'pg:哭': 'pg13.png',
  'pg:响指': 'pg14.png',
  'pg:转身': 'pg15.png',
};

class Sticker extends StatelessWidget {
  final String name;

  const Sticker({
    Key key,
    this.name,
  })  : assert(name != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.all(2.0),
      child: Image.asset(
        'assets/stickers/${isDark ? 'dark' : 'light'}/${_stickerNameToLocalPath[name]}',
        width: 32.0,
      ),
    );
  }
}
