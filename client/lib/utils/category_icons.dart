String categoryIconUrl(int categoryId, {bool isSubcategory = false}) {
  if (isSubcategory) {
    if (_sIcons.containsKey(categoryId)) {
      return '$_imageStyle/f/s${_sIcons[categoryId]}.png';
    } else if (_usIcons.containsKey(categoryId)) {
      return '$_imageBase/proxy/cache_attach/ficon/${categoryId}v.png${_usIcons[categoryId]}';
    }
  } else {
    if (_ufIcons.containsKey(categoryId)) {
      return '$_imageBase/proxy/cache_attach/ficon/${categoryId}u.png${_ufIcons[categoryId]}';
    } else if (_fIcons.containsKey(categoryId)) {
      return '$_imageStyle/f/${_fIcons[categoryId]}.png';
    }
  }
  return '$_imageStyle/f/00.png';
}

// data below was obtained from https://img4.nga.178.com/proxy/cache_attach/js_combine_data.js
// and https://img4.nga.178.com/ngabbs/nga_classic/js_default.js

const _imageBase = 'https://img4.nga.178.com';
const _imageStyle = 'https://img4.nga.178.com/ngabbs/nga_classic';

const _fIcons = {
  320: '320',
  181: '181',
  182: '182',
  183: '183',
  184: '184',
  185: '185',
  186: '186',
  187: '187',
  188: '188',
  189: '189',
  255: '10',
  306: '10',
  336: '10',
  190: '190',
  213: '213',
  218: '218',
  258: '258',
  272: '272',
  191: '191',
  200: '200',
  240: '240',
  274: '274',
  315: '315',
  333: '333',
  327: '327',
  318: '318',
  332: '332',
  321: '321',
  7: '7',
  -7: '354',
  354: '354',
  310: '310',
  323: '323',
  264: '264',
  10: '10',
  335: '335',
  18: '18',
  13: '13',
  16: '16',
  12: '12',
  8: '8',
  102: '102',
  254: '254',
  355: '355',
  116: '116',
  193: '193',
  201: '201',
  230: '230',
  334: '334',
  29: '29',
  387: '387',
  388: '388',
  390: '390',
  391: '391',
  -46468: '-46468',
  393: '393',
  394: '394',
  395: '395',
  396: '396',
  397: '397',
  398: '398',
  399: '399',
  -152678: '-152678',
  403: '403',
  -447601: '-447601',
  -2371813: '-2371813',
  -65653: '-65653',
  411: '411',
  412: '412',
  414: '414',
  311: '414',
  420: '420',
  422: '422',
  -8725919: '-8725919',
  425: '425',
  428: '428',
  427: '427',
  -7861121: '-7861121',
  -6194253: '-6194253',
  -84: '-84',
  431: '431',
  430: '430',
  435: '435',
  432: '432',
  442: '442',
  444: '444',
  445: '445',
  426: '426',
  -362960: '-362960',
  452: '452',
  -187579: '-187579',
  -47218: '-47218',
  -51095: '-51095',
  -452227: '-452227',
  -532408: '-532408',
  459: '459',
  -7202235: '-7202235',
  464: '464',
  441: '441',
  -1437546: '-1437546',
  469: '469',
  463: '463',
  474: '474',
  406: '406',
  446: '446',
  -343809: '-343809',
  476: '476',
  477: '477',
  486: 's8702375',
  492: '492',
  -149110: '-149110',
  124: '124',
  494: '494',
  490: '490',
  501: '501',
  482: '482',
  480: '480',
  497: '497',
  -5080470: '-5080470',
  465: '465',
  526: '526',
  489: '489',
  -81981: '-81981',
  485: '485',
  529: '529',
  -547859: '-547859',
  537: '537',
  538: '538',
  540: '540',
  418: '418',
  479: '418',
  545: '418',
  550: '550',
  549: '549',
  555: '555',
  551: '551',
  484: '484',
  -4567100: '-4567100b',
  -353371: '-353371',
  -608808: '-608808',
  556: '556',
  559: '559',
  -15219445: '-15219445',
  560: '560',
  563: '563',
  -8180483: '-8180483',
  493: '493_1',
  564: '564',
  568: '568',
  0: '0',
};

const _ufIcons = {
  -10308342: '?928',
  -103330: '?386',
  -12509501: '?252',
  -131429: '?994',
  -1459709: '?635',
  -149110: '?393',
  -1509129: '?931',
  -1513130: '?324',
  -15219445: '?279',
  -152678: '?391',
  -1534666: '?846',
  -187628: '?862',
  -202020: '?427',
  -2068947: '?585',
  -20691707: '?026',
  -2081117: '?365',
  -219610: '?272',
  -2342912: '?500',
  -235147: '?529',
  -2371813: '?794',
  -2671: '?395',
  -343809: '?144',
  -34490385: '?117',
  -34587507: '?448',
  -349066: '?268',
  -353371: '?238',
  -362960: '?526',
  -373173: '?047',
  -38213667: '?279',
  -38223432: '?499',
  -40530437: '?482',
  -41038017: '?371',
  -42872216: '?587',
  -444012: '?472',
  -447601: '?627',
  -452227: '?355',
  -4567100: '?082',
  -46468: '?402',
  -47218: '?333',
  -4760591: '?657',
  -502093: '?276',
  -5080470: '?764',
  -534617: '?169',
  -54214: '?933',
  -5456663: '?115',
  -547859: '?411',
  -576177: '?793',
  -5951001: '?021',
  -60204499: '?197',
  -608808: '?085',
  -6194253: '?648',
  -668707: '?495',
  -7: '?519',
  -7202235: '?275',
  -7678526: '?879',
  -7861121: '?550',
  -8180483: '?658',
  -81981: '?478',
  -84: '?701',
  -8725919: '?186',
  10: '?446',
  102: '?657',
  124: '?673',
  181: '?862',
  182: '?887',
  183: '?275',
  184: '?782',
  185: '?150',
  186: '?277',
  187: '?623',
  188: '?962',
  189: '?570',
  191: '?486',
  200: '?305',
  213: '?921',
  218: '?758',
  230: '?036',
  254: '?982',
  255: '?183',
  264: '?342',
  272: '?962',
  274: '?503',
  306: '?189',
  310: '?683',
  318: '?663',
  320: '?577',
  321: '?155',
  323: '?749',
  327: '?576',
  332: '?125',
  334: '?945',
  335: '?670',
  353: '?011',
  388: '?816',
  390: '?011',
  395: '?970',
  396: '?890',
  397: '?908',
  398: '?810',
  399: '?932',
  406: '?471',
  409: '?408',
  411: '?706',
  414: '?211',
  416: '?745',
  418: '?549',
  422: '?586',
  425: '?968',
  426: '?408',
  427: '?842',
  428: '?476',
  431: '?258',
  432: '?154',
  435: '?862',
  436: '?220',
  441: '?990',
  442: '?866',
  443: '?198',
  444: '?869',
  446: '?864',
  447: '?207',
  452: '?043',
  453: '?811',
  454: '?324',
  455: '?033',
  459: '?448',
  463: '?377',
  467: '?456',
  469: '?529',
  470: '?489',
  471: '?526',
  477: '?203',
  479: '?517',
  480: '?256',
  481: '?412',
  482: '?910',
  485: '?018',
  486: '?908',
  489: '?813',
  490: '?128',
  492: '?112',
  494: '?216',
  495: '?106',
  498: '?830',
  513: '?674',
  514: '?994',
  515: '?607',
  516: '?423',
  519: '?921',
  523: '?090',
  524: '?230',
  536: '?305',
  537: '?236',
  538: '?704',
  540: '?548',
  543: '?610',
  546: '?984',
  547: '?840',
  549: '?147',
  550: '?584',
  551: '?204',
  552: '?950',
  555: '?758',
  556: '?285',
  557: '?626',
  558: '?467',
  559: '?018',
  560: '?978',
  561: '?981',
  562: '?054',
  563: '?650',
  564: '?851',
  565: '?166',
  568: '?493',
  569: '?500',
  570: '?157',
  571: '?322',
  572: '?073',
  575: '?930',
  586: '?825',
  587: '?905',
  591: '?950',
  593: '?217',
  594: '?587',
  595: '?198',
  598: '?570',
  599: '?499',
  600: '?609',
  601: '?578',
  603: '?934',
  604: '?818',
  605: '?554',
  607: '?318',
  609: '?319',
  611: '?728',
  614: '?782',
  615: '?907',
  616: '?884',
  617: '?025',
  618: '?949',
  622: '?270',
  623: '?340',
  624: '?978',
  625: '?536',
  626: '?423',
  627: '?567',
  628: '?092',
  629: '?365',
  630: '?720',
  631: '?042',
  632: '?814',
  633: '?218',
  634: '?645',
  636: '?747',
  638: '?922',
  639: '?487',
  640: '?857',
  641: '?739',
  642: '?125',
  643: '?461',
  644: '?027',
  645: '?941',
  647: '?053',
  649: '?915',
  650: '?422',
  659: '?164',
  660: '?353',
  661: '?390',
  662: '?421',
  664: '?533',
  678: '?110',
  679: '?834',
  685: '?739',
  686: '?003',
  687: '?484',
  688: '?897',
  689: '?583',
  691: '?974',
  692: '?041',
  693: '?239',
  694: '?476',
  695: '?794',
  696: '?967',
  7: '?153',
  9: '?669',
};

const _sIcons = {
  8702375: '8702375',
};

const _usIcons = {
  10027782: '?527',
  10050613: '?900',
  10126611: '?235',
  10140946: '?729',
  10293598: '?782',
  10436564: '?004',
  10457312: '?274',
  10990054: '?321',
  11105519: '?144',
  11114731: '?312',
  11200121: '?843',
  11291877: '?665',
  11489391: '?367',
  11597730: '?089',
  11642782: '?284',
  11734486: '?710',
  11768857: '?287',
  11866022: '?206',
  11924364: '?263',
  12007887: '?128',
  12067303: '?712',
  12093598: '?246',
  12107113: '?948',
  12290633: '?609',
  12367942: '?210',
  12419343: '?262',
  12466411: '?215',
  12679759: '?155',
  12717929: '?603',
  12743868: '?909',
  12776235: '?117',
  12838563: '?516',
  12858335: '?000',
  12882700: '?357',
  12990470: '?565',
  13011773: '?518',
  13043110: '?305',
  13086244: '?651',
  13196199: '?965',
  13225011: '?559',
  13309303: '?378',
  13361173: '?949',
  13382747: '?612',
  13383002: '?893',
  13401426: '?789',
  13699614: '?495',
  13702155: '?004',
  13737106: '?014',
  13899987: '?836',
  14073850: '?787',
  14274222: '?251',
  14355027: '?223',
  14539170: '?182',
  14906309: '?185',
  15173226: '?886',
  15521348: '?504',
  16440503: '?731',
  16667422: '?536',
  16907051: '?548',
  16907081: '?562',
  1714643: '?337',
  17146433: '?699',
  17197058: '?797',
  17233763: '?232',
  17340805: '?391',
  17435214: '?738',
  17612007: '?547',
  17648142: '?726',
  17798179: '?185',
  17855024: '?222',
  18079631: '?363',
  18133076: '?261',
  18343564: '?096',
  18739125: '?721',
  18828824: '?637',
  18828908: '?088',
  18844498: '?906',
  18855745: '?448',
  18889236: '?890',
  18920055: '?829',
  19067947: '?366',
  19304878: '?708',
  19317848: '?788',
  19415053: '?697',
  19456658: '?577',
  19537132: '?706',
  19539190: '?391',
  19659084: '?812',
  8918060: '?437',
  8961703: '?233',
  8962115: '?406',
  8977716: '?662',
  9079209: '?360',
  9481457: '?466',
  9605923: '?971',
  9821244: '?073',
  9823651: '?050',
  9957698: '?192',
};
