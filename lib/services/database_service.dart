import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  
  // Web平台的内存存储
  static List<Map<String, dynamic>> _webQuotes = [];
  static List<Map<String, dynamic>> _webFigures = [];
  static List<Map<String, dynamic>> _webFigureThoughts = [];
  static List<Map<String, dynamic>> _webFigureWorks = [];
  static List<Map<String, dynamic>> _webSects = [];
  static List<Map<String, dynamic>> _webSectInfo = [];
  static List<Map<String, dynamic>> _webSectRepresentatives = [];
  static bool _webDataInitialized = false;

  Future<Database> get database async {
    if (kIsWeb) {
      // 在web平台上，我们使用内存存储模拟数据库
      if (!_webDataInitialized) {
        _initializeWebData();
      }
      // 这里返回null，因为web平台不使用sqflite
      throw UnsupportedError('sqflite is not supported on web');
    }
    
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'dao_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }
  
  // 初始化web平台的内存数据
  void _initializeWebData() {
    if (_webDataInitialized) return;
    
    // 初始化名言数据
    _webQuotes = [
      {'id': 1, 'content': '道可道，非常道；名可名，非常名。无名天地之始，有名万物之母。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 2, 'content': '天下皆知美之为美，斯恶已；皆知善之为善，斯不善已。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 3, 'content': '有无相生，难易相成，长短相较，高下相倾，音声相和，前后相随。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 4, 'content': '是以圣人处无为之事，行不言之教。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 5, 'content': '万物作焉而不辞，生而不有，为而不恃，功成而弗居。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 6, 'content': '夫唯弗居，是以不去。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 7, 'content': '不尚贤，使民不争；不贵难得之货，使民不为盗；不见可欲，使民心不乱。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 8, 'content': '是以圣人之治，虚其心，实其腹，弱其志，强其骨。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 9, 'content': '常使民无知无欲，使夫智者不敢为也。为无为，则无不治。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 10, 'content': '道冲，而用之或不盈。渊兮，似万物之宗。', 'created_at': DateTime.now().toIso8601String()},
    ];
    
    // 初始化人物数据
    _webFigures = [
      {'id': 1, 'name': '老子', 'era': '春秋', 'era_order': 1, 'description': '道家学派创始人，著有《道德经》', 'bio': '老子，姓李名耳，字聃，春秋末期人。他是道家学派的创始人，被尊为道教始祖。老子主张无为而治，强调顺应自然，其思想对中国哲学产生了深远影响。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 2, 'name': '孔子', 'era': '春秋', 'era_order': 1, 'description': '儒家学派创始人，被尊为孔圣人', 'bio': '孔子，名丘，字仲尼，春秋时期鲁国人。他是儒家学派的创始人，提出了仁、义、礼、智、信等核心思想，对中国乃至东亚文化产生了深远影响。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 3, 'name': '墨子', 'era': '战国', 'era_order': 2, 'description': '墨家学派创始人，主张兼爱非攻', 'bio': '墨子，名翟，战国时期宋国人。他是墨家学派的创始人，主张兼爱、非攻、尚贤等思想，对中国古代哲学产生了重要影响。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 4, 'name': '孟子', 'era': '战国', 'era_order': 2, 'description': '儒家代表人物，被尊为亚圣', 'bio': '孟子，名轲，战国时期邹国人。他是儒家学派的重要代表人物，继承和发展了孔子的思想，提出了性善论、仁政等观点。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 5, 'name': '庄子', 'era': '战国', 'era_order': 2, 'description': '道家代表人物，著有《庄子》', 'bio': '庄子，名周，战国时期宋国人。他是道家学派的重要代表人物，继承和发展了老子的思想。庄子主张逍遥游，追求精神自由，其作品富有哲理和文学性。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 6, 'name': '列子', 'era': '战国', 'era_order': 2, 'description': '道家思想家，著有《列子》', 'bio': '列子，名御寇，战国时期郑国人。他是道家学派的重要代表人物，其思想强调虚静无为，顺应自然。《列子》一书包含了许多寓言故事，富有哲理。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 7, 'name': '荀子', 'era': '战国', 'era_order': 2, 'description': '儒家代表人物，主张性恶论', 'bio': '荀子，名况，战国时期赵国人。他是儒家学派的重要代表人物，主张性恶论，强调后天教育的重要性，对儒家思想的发展做出了重要贡献。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 8, 'name': '韩非子', 'era': '战国', 'era_order': 2, 'description': '法家代表人物，集法家思想之大成', 'bio': '韩非子，战国末期韩国人。他是法家学派的代表人物，集法家思想之大成，主张以法治国，对中国古代政治思想产生了深远影响。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 9, 'name': '董仲舒', 'era': '西汉', 'era_order': 3, 'description': '汉代儒家代表人物，提出天人感应学说', 'bio': '董仲舒，西汉时期广川人。他是汉代儒家的代表人物，提出了天人感应、大一统等学说，对汉代及后世的政治思想产生了重要影响。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 10, 'name': '王充', 'era': '东汉', 'era_order': 4, 'description': '东汉思想家，批判谶纬迷信', 'bio': '王充，东汉时期会稽上虞人。他是东汉时期的思想家，批判谶纬迷信，主张无神论，对中国古代唯物主义思想的发展做出了重要贡献。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 11, 'name': '郭象', 'era': '魏晋', 'era_order': 5, 'description': '魏晋玄学代表人物，注《庄子》', 'bio': '郭象，魏晋时期河南人。他是魏晋玄学的代表人物，注《庄子》，提出了独化论等思想，对魏晋玄学的发展做出了重要贡献。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 12, 'name': '韩愈', 'era': '唐代', 'era_order': 6, 'description': '唐代文学家、思想家，倡导古文运动', 'bio': '韩愈，唐代河南河阳人。他是唐代著名的文学家、思想家，倡导古文运动，提出了道统说，对宋明理学的产生有重要影响。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 13, 'name': '朱熹', 'era': '宋代', 'era_order': 7, 'description': '宋代理学集大成者，主张格物致知', 'bio': '朱熹，宋代徽州婺源人。他是宋代理学的集大成者，主张格物致知、存天理灭人欲，对中国后期封建社会的思想产生了深远影响。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 14, 'name': '王阳明', 'era': '明代', 'era_order': 8, 'description': '明代心学集大成者，主张知行合一', 'bio': '王阳明，明代浙江余姚人。他是明代心学的集大成者，主张心即理、知行合一、致良知，对中国后期封建社会的思想产生了重要影响。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 15, 'name': '王夫之', 'era': '明末清初', 'era_order': 9, 'description': '明末清初思想家，批判程朱理学', 'bio': '王夫之，明末清初湖南衡阳人。他是明末清初的思想家，批判程朱理学，主张气一元论、经世致用，对中国近代思想的发展产生了重要影响。', 'created_at': DateTime.now().toIso8601String()},
    ];
    
    // 初始化人物核心思想
    _webFigureThoughts = [
      {'id': 1, 'figure_id': 1, 'thought': '无为'},
      {'id': 2, 'figure_id': 1, 'thought': '道法自然'},
      {'id': 3, 'figure_id': 1, 'thought': '小国寡民'},
      {'id': 4, 'figure_id': 2, 'thought': '仁'},
      {'id': 5, 'figure_id': 2, 'thought': '义'},
      {'id': 6, 'figure_id': 2, 'thought': '礼'},
      {'id': 7, 'figure_id': 2, 'thought': '智'},
      {'id': 8, 'figure_id': 2, 'thought': '信'},
      {'id': 9, 'figure_id': 3, 'thought': '兼爱'},
      {'id': 10, 'figure_id': 3, 'thought': '非攻'},
      {'id': 11, 'figure_id': 3, 'thought': '尚贤'},
      {'id': 12, 'figure_id': 3, 'thought': '尚同'},
      {'id': 13, 'figure_id': 4, 'thought': '性善论'},
      {'id': 14, 'figure_id': 4, 'thought': '仁政'},
      {'id': 15, 'figure_id': 4, 'thought': '民贵君轻'},
      {'id': 16, 'figure_id': 5, 'thought': '逍遥游'},
      {'id': 17, 'figure_id': 5, 'thought': '齐物论'},
      {'id': 18, 'figure_id': 5, 'thought': '相对主义'},
      {'id': 19, 'figure_id': 6, 'thought': '虚静'},
      {'id': 20, 'figure_id': 6, 'thought': '无为'},
      {'id': 21, 'figure_id': 6, 'thought': '自然'},
      {'id': 22, 'figure_id': 7, 'thought': '性恶论'},
      {'id': 23, 'figure_id': 7, 'thought': '隆礼重法'},
      {'id': 24, 'figure_id': 7, 'thought': '天人相分'},
      {'id': 25, 'figure_id': 8, 'thought': '法治'},
      {'id': 26, 'figure_id': 8, 'thought': '术治'},
      {'id': 27, 'figure_id': 8, 'thought': '势治'},
      {'id': 28, 'figure_id': 9, 'thought': '天人感应'},
      {'id': 29, 'figure_id': 9, 'thought': '大一统'},
      {'id': 30, 'figure_id': 9, 'thought': '罢黜百家，独尊儒术'},
      {'id': 31, 'figure_id': 10, 'thought': '无神论'},
      {'id': 32, 'figure_id': 10, 'thought': '唯物主义'},
      {'id': 33, 'figure_id': 10, 'thought': '疾虚妄'},
      {'id': 34, 'figure_id': 11, 'thought': '独化论'},
      {'id': 35, 'figure_id': 11, 'thought': '玄冥'},
      {'id': 36, 'figure_id': 11, 'thought': '自然'},
      {'id': 37, 'figure_id': 12, 'thought': '道统说'},
      {'id': 38, 'figure_id': 12, 'thought': '文以载道'},
      {'id': 39, 'figure_id': 12, 'thought': '复古'},
      {'id': 40, 'figure_id': 13, 'thought': '格物致知'},
      {'id': 41, 'figure_id': 13, 'thought': '存天理灭人欲'},
      {'id': 42, 'figure_id': 13, 'thought': '理气论'},
      {'id': 43, 'figure_id': 14, 'thought': '心即理'},
      {'id': 44, 'figure_id': 14, 'thought': '知行合一'},
      {'id': 45, 'figure_id': 14, 'thought': '致良知'},
      {'id': 46, 'figure_id': 15, 'thought': '气一元论'},
      {'id': 47, 'figure_id': 15, 'thought': '经世致用'},
      {'id': 48, 'figure_id': 15, 'thought': '动静观'},
    ];
    
    // 初始化人物著作
    _webFigureWorks = [
      {'id': 1, 'figure_id': 1, 'work': '道德经'},
      {'id': 2, 'figure_id': 2, 'work': '论语'},
      {'id': 3, 'figure_id': 3, 'work': '墨子'},
      {'id': 4, 'figure_id': 4, 'work': '孟子'},
      {'id': 5, 'figure_id': 5, 'work': '庄子'},
      {'id': 6, 'figure_id': 6, 'work': '列子'},
      {'id': 7, 'figure_id': 7, 'work': '荀子'},
      {'id': 8, 'figure_id': 8, 'work': '韩非子'},
      {'id': 9, 'figure_id': 9, 'work': '春秋繁露'},
      {'id': 10, 'figure_id': 10, 'work': '论衡'},
      {'id': 11, 'figure_id': 11, 'work': '庄子注'},
      {'id': 12, 'figure_id': 12, 'work': '韩昌黎集'},
      {'id': 13, 'figure_id': 13, 'work': '四书章句集注'},
      {'id': 14, 'figure_id': 14, 'work': '传习录'},
      {'id': 15, 'figure_id': 15, 'work': '船山遗书'},
    ];
    
    // 初始化派系数据
    _webSects = [
      {'id': 1, 'name': '正一道', 'dynasty': '东汉', 'practice': '符箓', 'description': '正一道是道教的主要派别之一，由张道陵创立于东汉末年。注重符箓法术，强调通过仪式和法术来达到修仙的目的。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 2, 'name': '上清派', 'dynasty': '魏晋', 'practice': '存思', 'description': '上清派是道教的重要派别之一，以《上清经》为主要经典，强调存思守一的修炼方法。由魏华存创立。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 3, 'name': '灵宝派', 'dynasty': '魏晋', 'practice': '斋醮', 'description': '灵宝派是道教的重要派别之一，以《灵宝经》为主要经典，强调斋醮科仪的重要性。由葛玄创立。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 4, 'name': '茅山派', 'dynasty': '隋唐', 'practice': '符箓', 'description': '茅山派是道教的重要派别之一，以茅山为圣地，注重符箓法术和内丹修炼。由陶弘景发展壮大。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 5, 'name': '全真派', 'dynasty': '北宋', 'practice': '清修', 'description': '全真派是道教的重要派别之一，由王重阳创立，主张性命双修，强调内心的修炼和精神的超越。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 6, 'name': '净明道', 'dynasty': '南宋', 'practice': '忠孝', 'description': '净明道是道教的重要派别之一，强调忠孝伦理，融合儒家思想与道教修炼。由许逊创立。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 7, 'name': '龙门派', 'dynasty': '元', 'practice': '清修', 'description': '龙门派是全真派的重要支派，由丘处机创立，强调严格的清修戒律和内丹修炼。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 8, 'name': '正一派', 'dynasty': '明', 'practice': '符箓', 'description': '正一派是道教的主要派别之一，由张道陵后裔传承，注重符箓法术和斋醮科仪。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 9, 'name': '青城派', 'dynasty': '清', 'practice': '内丹', 'description': '青城派是道教的重要派别之一，以青城山为圣地，注重内丹修炼和武术。', 'created_at': DateTime.now().toIso8601String()},
    ];
    
    // 初始化派系信息
    _webSectInfo = [
      {'id': 1, 'sect_id': 1, 'key': '修行方式', 'value': '符箓、斋醮、科仪'},
      {'id': 2, 'sect_id': 1, 'key': '理念', 'value': '驱邪避凶、祈福禳灾'},
      {'id': 3, 'sect_id': 1, 'key': '经典', 'value': '《道德经》、《太平经》'},
      {'id': 4, 'sect_id': 1, 'key': '圣地', 'value': '龙虎山、青城山'},
      {'id': 5, 'sect_id': 2, 'key': '修行方式', 'value': '存思、服气、内丹'},
      {'id': 6, 'sect_id': 2, 'key': '理念', 'value': '上清道妙、存思成仙'},
      {'id': 7, 'sect_id': 2, 'key': '经典', 'value': '《上清大洞真经》'},
      {'id': 8, 'sect_id': 2, 'key': '圣地', 'value': '茅山、天台山'},
      {'id': 9, 'sect_id': 3, 'key': '修行方式', 'value': '斋醮、符箓、诵经'},
      {'id': 10, 'sect_id': 3, 'key': '理念', 'value': '超度亡灵、积累功德'},
      {'id': 11, 'sect_id': 3, 'key': '经典', 'value': '《灵宝无量度人上品妙经》'},
      {'id': 12, 'sect_id': 3, 'key': '圣地', 'value': '阁皂山'},
      {'id': 13, 'sect_id': 4, 'key': '修行方式', 'value': '符箓、内丹、斋醮'},
      {'id': 14, 'sect_id': 4, 'key': '理念', 'value': '济世度人、修道成仙'},
      {'id': 15, 'sect_id': 4, 'key': '经典', 'value': '《真诰》、《登真隐诀》'},
      {'id': 16, 'sect_id': 4, 'key': '圣地', 'value': '茅山'},
      {'id': 17, 'sect_id': 5, 'key': '修行方式', 'value': '内丹修炼、清修、戒律'},
      {'id': 18, 'sect_id': 5, 'key': '理念', 'value': '全真而仙、三教合一'},
      {'id': 19, 'sect_id': 5, 'key': '经典', 'value': '《道德经》、《清静经》'},
      {'id': 20, 'sect_id': 5, 'key': '圣地', 'value': '终南山、昆嵛山'},
      {'id': 21, 'sect_id': 6, 'key': '修行方式', 'value': '忠孝伦理、内丹修炼'},
      {'id': 22, 'sect_id': 6, 'key': '理念', 'value': '净明忠孝、仙道合一'},
      {'id': 23, 'sect_id': 6, 'key': '经典', 'value': '《净明忠孝全书》'},
      {'id': 24, 'sect_id': 6, 'key': '圣地', 'value': '西山万寿宫'},
      {'id': 25, 'sect_id': 7, 'key': '修行方式', 'value': '内丹修炼、清修戒律'},
      {'id': 26, 'sect_id': 7, 'key': '理念', 'value': '龙门心法、全真传承'},
      {'id': 27, 'sect_id': 7, 'key': '经典', 'value': '《邱祖全书》'},
      {'id': 28, 'sect_id': 7, 'key': '圣地', 'value': '白云观、崂山'},
      {'id': 29, 'sect_id': 8, 'key': '修行方式', 'value': '符箓、斋醮、科仪'},
      {'id': 30, 'sect_id': 8, 'key': '理念', 'value': '驱邪避凶、祈福禳灾'},
      {'id': 31, 'sect_id': 8, 'key': '经典', 'value': '《正统道藏》'},
      {'id': 32, 'sect_id': 8, 'key': '圣地', 'value': '龙虎山'},
      {'id': 33, 'sect_id': 9, 'key': '修行方式', 'value': '内丹修炼、武术'},
      {'id': 34, 'sect_id': 9, 'key': '理念', 'value': '青城仙道、内外兼修'},
      {'id': 35, 'sect_id': 9, 'key': '经典', 'value': '《青城秘录》'},
      {'id': 36, 'sect_id': 9, 'key': '圣地', 'value': '青城山'},
    ];
    
    // 初始化派系代表人物
    _webSectRepresentatives = [
      {'id': 1, 'sect_id': 1, 'figure_name': '张道陵'},
      {'id': 2, 'sect_id': 1, 'figure_name': '张衡'},
      {'id': 3, 'sect_id': 1, 'figure_name': '张鲁'},
      {'id': 4, 'sect_id': 2, 'figure_name': '魏华存'},
      {'id': 5, 'sect_id': 2, 'figure_name': '杨羲'},
      {'id': 6, 'sect_id': 2, 'figure_name': '许谧'},
      {'id': 7, 'sect_id': 3, 'figure_name': '葛玄'},
      {'id': 8, 'sect_id': 3, 'figure_name': '葛洪'},
      {'id': 9, 'sect_id': 3, 'figure_name': '陆修静'},
      {'id': 10, 'sect_id': 4, 'figure_name': '陶弘景'},
      {'id': 11, 'sect_id': 4, 'figure_name': '司马承祯'},
      {'id': 12, 'sect_id': 4, 'figure_name': '吴筠'},
      {'id': 13, 'sect_id': 5, 'figure_name': '王重阳'},
      {'id': 14, 'sect_id': 5, 'figure_name': '丘处机'},
      {'id': 15, 'sect_id': 5, 'figure_name': '马钰'},
      {'id': 16, 'sect_id': 6, 'figure_name': '许逊'},
      {'id': 17, 'sect_id': 6, 'figure_name': '刘玉'},
      {'id': 18, 'sect_id': 6, 'figure_name': '黄元吉'},
      {'id': 19, 'sect_id': 7, 'figure_name': '丘处机'},
      {'id': 20, 'sect_id': 7, 'figure_name': '尹志平'},
      {'id': 21, 'sect_id': 7, 'figure_name': '李志常'},
      {'id': 22, 'sect_id': 8, 'figure_name': '张正常'},
      {'id': 23, 'sect_id': 8, 'figure_name': '张宇初'},
      {'id': 24, 'sect_id': 8, 'figure_name': '张继禹'},
      {'id': 25, 'sect_id': 9, 'figure_name': '杜光庭'},
      {'id': 26, 'sect_id': 9, 'figure_name': '陈清觉'},
      {'id': 27, 'sect_id': 9, 'figure_name': '刘沅'},
    ];
    
    _webDataInitialized = true;
  }

  Future<void> _createTables(Database db, int version) async {
    // 创建名言表
    await db.execute('''
      CREATE TABLE quotes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    // 创建人物表
    await db.execute('''
      CREATE TABLE figures (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        era TEXT,
        era_order INTEGER DEFAULT 999,
        description TEXT,
        bio TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    // 创建人物核心思想表
    await db.execute('''
      CREATE TABLE figure_thoughts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        figure_id INTEGER,
        thought TEXT NOT NULL,
        FOREIGN KEY (figure_id) REFERENCES figures(id) ON DELETE CASCADE
      );
    ''');

    // 创建人物著作表
    await db.execute('''
      CREATE TABLE figure_works (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        figure_id INTEGER,
        work TEXT NOT NULL,
        FOREIGN KEY (figure_id) REFERENCES figures(id) ON DELETE CASCADE
      );
    ''');

    // 创建派系表
    await db.execute('''
      CREATE TABLE sects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        dynasty TEXT,
        practice TEXT,
        description TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    // 创建派系信息表
    await db.execute('''
      CREATE TABLE sect_info (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sect_id INTEGER,
        key TEXT NOT NULL,
        value TEXT NOT NULL,
        FOREIGN KEY (sect_id) REFERENCES sects(id) ON DELETE CASCADE
      );
    ''');

    // 创建派系代表人物关联表
    await db.execute('''
      CREATE TABLE sect_representatives (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sect_id INTEGER,
        figure_name TEXT NOT NULL,
        FOREIGN KEY (sect_id) REFERENCES sects(id) ON DELETE CASCADE
      );
    ''');

    // 插入默认名言数据
    await _insertDefaultQuotes(db);

    // 插入默认人物数据
    await _insertDefaultFigures(db);

    // 插入默认派系数据
    await _insertDefaultSects(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 数据库升级逻辑
  }

  // 插入默认名言数据
  Future<void> _insertDefaultQuotes(Database db) async {
    final defaultQuotes = [
      '道可道，非常道；名可名，非常名。无名天地之始，有名万物之母。',
      '天下皆知美之为美，斯恶已；皆知善之为善，斯不善已。',
      '有无相生，难易相成，长短相较，高下相倾，音声相和，前后相随。',
      '是以圣人处无为之事，行不言之教。',
      '万物作焉而不辞，生而不有，为而不恃，功成而弗居。',
      '夫唯弗居，是以不去。',
      '不尚贤，使民不争；不贵难得之货，使民不为盗；不见可欲，使民心不乱。',
      '是以圣人之治，虚其心，实其腹，弱其志，强其骨。',
      '常使民无知无欲，使夫智者不敢为也。为无为，则无不治。',
      '道冲，而用之或不盈。渊兮，似万物之宗。',
    ];

    for (var quote in defaultQuotes) {
      await db.insert('quotes', {'content': quote});
    }
  }

  // 插入默认人物数据
  Future<void> _insertDefaultFigures(Database db) async {
    final defaultFigures = [
      {
        'name': '老子',
        'era': '春秋',
        'era_order': 1,
        'description': '道家学派创始人，著有《道德经》',
        'bio': '老子，姓李名耳，字聃，春秋末期人。他是道家学派的创始人，被尊为道教始祖。老子主张无为而治，强调顺应自然，其思想对中国哲学产生了深远影响。',
        'coreThoughts': ['无为', '道法自然', '小国寡民'],
        'works': ['道德经']
      },
      {
        'name': '孔子',
        'era': '春秋',
        'era_order': 1,
        'description': '儒家学派创始人，被尊为孔圣人',
        'bio': '孔子，名丘，字仲尼，春秋时期鲁国人。他是儒家学派的创始人，提出了仁、义、礼、智、信等核心思想，对中国乃至东亚文化产生了深远影响。',
        'coreThoughts': ['仁', '义', '礼', '智', '信'],
        'works': ['论语']
      },
      {
        'name': '墨子',
        'era': '战国',
        'era_order': 2,
        'description': '墨家学派创始人，主张兼爱非攻',
        'bio': '墨子，名翟，战国时期宋国人。他是墨家学派的创始人，主张兼爱、非攻、尚贤等思想，对中国古代哲学产生了重要影响。',
        'coreThoughts': ['兼爱', '非攻', '尚贤', '尚同'],
        'works': ['墨子']
      },
      {
        'name': '孟子',
        'era': '战国',
        'era_order': 2,
        'description': '儒家代表人物，被尊为亚圣',
        'bio': '孟子，名轲，战国时期邹国人。他是儒家学派的重要代表人物，继承和发展了孔子的思想，提出了性善论、仁政等观点。',
        'coreThoughts': ['性善论', '仁政', '民贵君轻'],
        'works': ['孟子']
      },
      {
        'name': '庄子',
        'era': '战国',
        'era_order': 2,
        'description': '道家代表人物，著有《庄子》',
        'bio': '庄子，名周，战国时期宋国人。他是道家学派的重要代表人物，继承和发展了老子的思想。庄子主张逍遥游，追求精神自由，其作品富有哲理和文学性。',
        'coreThoughts': ['逍遥游', '齐物论', '相对主义'],
        'works': ['庄子']
      },
      {
        'name': '列子',
        'era': '战国',
        'era_order': 2,
        'description': '道家思想家，著有《列子》',
        'bio': '列子，名御寇，战国时期郑国人。他是道家学派的重要代表人物，其思想强调虚静无为，顺应自然。《列子》一书包含了许多寓言故事，富有哲理。',
        'coreThoughts': ['虚静', '无为', '自然'],
        'works': ['列子']
      },
      {
        'name': '荀子',
        'era': '战国',
        'era_order': 2,
        'description': '儒家代表人物，主张性恶论',
        'bio': '荀子，名况，战国时期赵国人。他是儒家学派的重要代表人物，主张性恶论，强调后天教育的重要性，对儒家思想的发展做出了重要贡献。',
        'coreThoughts': ['性恶论', '隆礼重法', '天人相分'],
        'works': ['荀子']
      },
      {
        'name': '韩非子',
        'era': '战国',
        'era_order': 2,
        'description': '法家代表人物，集法家思想之大成',
        'bio': '韩非子，战国末期韩国人。他是法家学派的代表人物，集法家思想之大成，主张以法治国，对中国古代政治思想产生了深远影响。',
        'coreThoughts': ['法治', '术治', '势治'],
        'works': ['韩非子']
      },
      {
        'name': '董仲舒',
        'era': '西汉',
        'era_order': 3,
        'description': '汉代儒家代表人物，提出天人感应学说',
        'bio': '董仲舒，西汉时期广川人。他是汉代儒家的代表人物，提出了天人感应、大一统等学说，对汉代及后世的政治思想产生了重要影响。',
        'coreThoughts': ['天人感应', '大一统', '罢黜百家，独尊儒术'],
        'works': ['春秋繁露']
      },
      {
        'name': '王充',
        'era': '东汉',
        'era_order': 4,
        'description': '东汉思想家，批判谶纬迷信',
        'bio': '王充，东汉时期会稽上虞人。他是东汉时期的思想家，批判谶纬迷信，主张无神论，对中国古代唯物主义思想的发展做出了重要贡献。',
        'coreThoughts': ['无神论', '唯物主义', '疾虚妄'],
        'works': ['论衡']
      },
      {
        'name': '郭象',
        'era': '魏晋',
        'era_order': 5,
        'description': '魏晋玄学代表人物，注《庄子》',
        'bio': '郭象，魏晋时期河南人。他是魏晋玄学的代表人物，注《庄子》，提出了独化论等思想，对魏晋玄学的发展做出了重要贡献。',
        'coreThoughts': ['独化论', '玄冥', '自然'],
        'works': ['庄子注']
      },
      {
        'name': '韩愈',
        'era': '唐代',
        'era_order': 6,
        'description': '唐代文学家、思想家，倡导古文运动',
        'bio': '韩愈，唐代河南河阳人。他是唐代著名的文学家、思想家，倡导古文运动，提出了道统说，对宋明理学的产生有重要影响。',
        'coreThoughts': ['道统说', '文以载道', '复古'],
        'works': ['韩昌黎集']
      },
      {
        'name': '朱熹',
        'era': '宋代',
        'era_order': 7,
        'description': '宋代理学集大成者，主张格物致知',
        'bio': '朱熹，宋代徽州婺源人。他是宋代理学的集大成者，主张格物致知、存天理灭人欲，对中国后期封建社会的思想产生了深远影响。',
        'coreThoughts': ['格物致知', '存天理灭人欲', '理气论'],
        'works': ['四书章句集注']
      },
      {
        'name': '王阳明',
        'era': '明代',
        'era_order': 8,
        'description': '明代心学集大成者，主张知行合一',
        'bio': '王阳明，明代浙江余姚人。他是明代心学的集大成者，主张心即理、知行合一、致良知，对中国后期封建社会的思想产生了重要影响。',
        'coreThoughts': ['心即理', '知行合一', '致良知'],
        'works': ['传习录']
      },
      {
        'name': '王夫之',
        'era': '明末清初',
        'era_order': 9,
        'description': '明末清初思想家，批判程朱理学',
        'bio': '王夫之，明末清初湖南衡阳人。他是明末清初的思想家，批判程朱理学，主张气一元论、经世致用，对中国近代思想的发展产生了重要影响。',
        'coreThoughts': ['气一元论', '经世致用', '动静观'],
        'works': ['船山遗书']
      },
    ];

    for (var figure in defaultFigures) {
      final figureId = await db.insert('figures', {
        'name': figure['name'],
        'era': figure['era'],
        'era_order': figure['era_order'],
        'description': figure['description'],
        'bio': figure['bio'],
      });

      // 插入核心思想
      final coreThoughts = figure['coreThoughts'] as List<dynamic>;
      for (var thought in coreThoughts) {
        await db.insert('figure_thoughts', {
          'figure_id': figureId,
          'thought': thought,
        });
      }

      // 插入著作
      final works = figure['works'] as List<dynamic>;
      for (var work in works) {
        await db.insert('figure_works', {
          'figure_id': figureId,
          'work': work,
        });
      }
    }
  }

  // 插入默认派系数据
  Future<void> _insertDefaultSects(Database db) async {
    final defaultSects = [
      {
        'name': '正一道',
        'dynasty': '东汉',
        'practice': '符箓',
        'description': '正一道是道教的主要派别之一，由张道陵创立于东汉末年。注重符箓法术，强调通过仪式和法术来达到修仙的目的。',
        'info': {
          '修行方式': '符箓、斋醮、科仪',
          '理念': '驱邪避凶、祈福禳灾',
          '经典': '《道德经》、《太平经》',
          '圣地': '龙虎山、青城山'
        },
        'representatives': ['张道陵', '张衡', '张鲁']
      },
      {
        'name': '上清派',
        'dynasty': '魏晋',
        'practice': '存思',
        'description': '上清派是道教的重要派别之一，以《上清经》为主要经典，强调存思守一的修炼方法。由魏华存创立。',
        'info': {
          '修行方式': '存思、服气、内丹',
          '理念': '上清道妙、存思成仙',
          '经典': '《上清大洞真经》',
          '圣地': '茅山、天台山'
        },
        'representatives': ['魏华存', '杨羲', '许谧']
      },
      {
        'name': '灵宝派',
        'dynasty': '魏晋',
        'practice': '斋醮',
        'description': '灵宝派是道教的重要派别之一，以《灵宝经》为主要经典，强调斋醮科仪的重要性。由葛玄创立。',
        'info': {
          '修行方式': '斋醮、符箓、诵经',
          '理念': '超度亡灵、积累功德',
          '经典': '《灵宝无量度人上品妙经》',
          '圣地': '阁皂山'
        },
        'representatives': ['葛玄', '葛洪', '陆修静']
      },
      {
        'name': '茅山派',
        'dynasty': '隋唐',
        'practice': '符箓',
        'description': '茅山派是道教的重要派别之一，以茅山为圣地，注重符箓法术和内丹修炼。由陶弘景发展壮大。',
        'info': {
          '修行方式': '符箓、内丹、斋醮',
          '理念': '济世度人、修道成仙',
          '经典': '《真诰》、《登真隐诀》',
          '圣地': '茅山'
        },
        'representatives': ['陶弘景', '司马承祯', '吴筠']
      },
      {
        'name': '全真派',
        'dynasty': '北宋',
        'practice': '清修',
        'description': '全真派是道教的重要派别之一，由王重阳创立，主张性命双修，强调内心的修炼和精神的超越。',
        'info': {
          '修行方式': '内丹修炼、清修、戒律',
          '理念': '全真而仙、三教合一',
          '经典': '《道德经》、《清静经》',
          '圣地': '终南山、昆嵛山'
        },
        'representatives': ['王重阳', '丘处机', '马钰']
      },
      {
        'name': '净明道',
        'dynasty': '南宋',
        'practice': '忠孝',
        'description': '净明道是道教的重要派别之一，强调忠孝伦理，融合儒家思想与道教修炼。由许逊创立。',
        'info': {
          '修行方式': '忠孝伦理、内丹修炼',
          '理念': '净明忠孝、仙道合一',
          '经典': '《净明忠孝全书》',
          '圣地': '西山万寿宫'
        },
        'representatives': ['许逊', '刘玉', '黄元吉']
      },
      {
        'name': '龙门派',
        'dynasty': '元',
        'practice': '清修',
        'description': '龙门派是全真派的重要支派，由丘处机创立，强调严格的清修戒律和内丹修炼。',
        'info': {
          '修行方式': '内丹修炼、清修戒律',
          '理念': '龙门心法、全真传承',
          '经典': '《邱祖全书》',
          '圣地': '白云观、崂山'
        },
        'representatives': ['丘处机', '尹志平', '李志常']
      },
      {
        'name': '正一派',
        'dynasty': '明',
        'practice': '符箓',
        'description': '正一派是道教的主要派别之一，由张道陵后裔传承，注重符箓法术和斋醮科仪。',
        'info': {
          '修行方式': '符箓、斋醮、科仪',
          '理念': '驱邪避凶、祈福禳灾',
          '经典': '《正统道藏》',
          '圣地': '龙虎山'
        },
        'representatives': ['张正常', '张宇初', '张继禹']
      },
      {
        'name': '青城派',
        'dynasty': '清',
        'practice': '内丹',
        'description': '青城派是道教的重要派别之一，以青城山为圣地，注重内丹修炼和武术。',
        'info': {
          '修行方式': '内丹修炼、武术',
          '理念': '青城仙道、内外兼修',
          '经典': '《青城秘录》',
          '圣地': '青城山'
        },
        'representatives': ['杜光庭', '陈清觉', '刘沅']
      },
    ];

    for (var sect in defaultSects) {
      final sectId = await db.insert('sects', {
        'name': sect['name'],
        'dynasty': sect['dynasty'],
        'practice': sect['practice'],
        'description': sect['description'],
      });

      // 插入派系信息
      final info = sect['info'] as Map<String, dynamic>;
      for (var entry in info.entries) {
        await db.insert('sect_info', {
          'sect_id': sectId,
          'key': entry.key,
          'value': entry.value,
        });
      }

      // 插入代表人物
      final representatives = sect['representatives'] as List<dynamic>;
      for (var representative in representatives) {
        await db.insert('sect_representatives', {
          'sect_id': sectId,
          'figure_name': representative,
        });
      }
    }
  }

  // 名言相关操作
  Future<int> insertQuote(String content) async {
    if (kIsWeb) {
      // 在web平台上使用内存存储
      final newQuote = {
        'id': _webQuotes.length + 1,
        'content': content,
        'created_at': DateTime.now().toIso8601String(),
      };
      _webQuotes.add(newQuote);
      return newQuote['id'] as int;
    }
    
    final db = await database;
    return await db.insert('quotes', {'content': content});
  }

  Future<List<Map<String, dynamic>>> getAllQuotes() async {
    if (kIsWeb) {
      // 在web平台上使用内存存储
      return _webQuotes;
    }
    
    final db = await database;
    return await db.query('quotes');
  }

  Future<Map<String, dynamic>?> getRandomQuote() async {
    if (kIsWeb) {
      // 在web平台上使用内存存储
      if (_webQuotes.isEmpty) return null;
      final randomIndex = DateTime.now().millisecondsSinceEpoch % _webQuotes.length;
      return _webQuotes[randomIndex];
    }
    
    final db = await database;
    final result = await db.rawQuery('SELECT * FROM quotes ORDER BY RANDOM() LIMIT 1');
    return result.isNotEmpty ? result.first : null;
  }

  // 人物相关操作
  Future<int> insertFigure(Map<String, dynamic> figure) async {
    if (kIsWeb) {
      // 在web平台上使用内存存储
      final newFigure = {
        'id': _webFigures.length + 1,
        'name': figure['name'],
        'era': figure['era'],
        'era_order': figure['era_order'] ?? 999,
        'description': figure['description'],
        'bio': figure['bio'],
        'created_at': DateTime.now().toIso8601String(),
      };
      _webFigures.add(newFigure);
      return newFigure['id'] as int;
    }
    
    final db = await database;
    return await db.insert('figures', figure);
  }

  Future<int> updateFigure(int id, Map<String, dynamic> figure) async {
    if (kIsWeb) {
      // 在web平台上使用内存存储
      final index = _webFigures.indexWhere((f) => f['id'] == id);
      if (index >= 0) {
        _webFigures[index] = {
          ..._webFigures[index],
          ...figure,
        };
        return 1;
      }
      return 0;
    }
    
    final db = await database;
    return await db.update('figures', figure, where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> getFigureByName(String name) async {
    if (kIsWeb) {
      // 在web平台上使用内存存储
      final figure = _webFigures.firstWhere((f) => f['name'] == name, orElse: () => {});
      if (figure.isEmpty) return null;
      
      // 获取核心思想
      final thoughts = _webFigureThoughts.where((t) => t['figure_id'] == figure['id']).map((t) => t['thought']).toList();
      figure['coreThoughts'] = thoughts;
      // 获取著作
      final works = _webFigureWorks.where((w) => w['figure_id'] == figure['id']).map((w) => w['work']).toList();
      figure['works'] = works;
      
      return figure;
    }
    
    final db = await database;
    final result = await db.query('figures', where: 'name = ?', whereArgs: [name]);
    if (result.isEmpty) return null;
    
    final figure = result.first;
    // 获取核心思想
    final thoughts = await db.query('figure_thoughts', where: 'figure_id = ?', whereArgs: [figure['id']]);
    figure['coreThoughts'] = thoughts.map((t) => t['thought']).toList();
    // 获取著作
    final works = await db.query('figure_works', where: 'figure_id = ?', whereArgs: [figure['id']]);
    figure['works'] = works.map((w) => w['work']).toList();
    
    return figure;
  }

  Future<List<Map<String, dynamic>>> getAllFigures() async {
    if (kIsWeb) {
      // 在web平台上使用内存存储
      final figures = List<Map<String, dynamic>>.from(_webFigures);
      
      for (var figure in figures) {
        // 获取核心思想
        final thoughts = _webFigureThoughts.where((t) => t['figure_id'] == figure['id']).map((t) => t['thought']).toList();
        figure['coreThoughts'] = thoughts;
        // 获取著作
        final works = _webFigureWorks.where((w) => w['figure_id'] == figure['id']).map((w) => w['work']).toList();
        figure['works'] = works;
      }
      
      // 按时代顺序排序
      figures.sort((a, b) => (a['era_order'] ?? 999).compareTo(b['era_order'] ?? 999));
      
      return figures;
    }
    
    final db = await database;
    final figures = await db.query('figures', orderBy: 'era_order ASC');
    
    for (var figure in figures) {
      // 获取核心思想
      final thoughts = await db.query('figure_thoughts', where: 'figure_id = ?', whereArgs: [figure['id']]);
      figure['coreThoughts'] = thoughts.map((t) => t['thought']).toList();
      // 获取著作
      final works = await db.query('figure_works', where: 'figure_id = ?', whereArgs: [figure['id']]);
      figure['works'] = works.map((w) => w['work']).toList();
    }
    
    return figures;
  }

  Future<void> saveFigureWithDetails(String name, String bio, List<dynamic> coreThoughts, List<dynamic> works) async {
    if (kIsWeb) {
      // 在web平台上使用内存存储
      // 检查人物是否存在
      final existingFigure = _webFigures.firstWhere((f) => f['name'] == name, orElse: () => {});
      int figureId;
      
      if (existingFigure.isNotEmpty) {
        // 更新现有人物
        existingFigure['bio'] = bio;
        figureId = existingFigure['id'] as int;
        
        // 删除旧的核心思想和著作
        _webFigureThoughts.removeWhere((t) => t['figure_id'] == figureId);
        _webFigureWorks.removeWhere((w) => w['figure_id'] == figureId);
      } else {
        // 插入新人物
        figureId = _webFigures.length + 1;
        final newFigure = {
          'id': figureId,
          'name': name,
          'era': '',
          'era_order': 999,
          'description': '',
          'bio': bio,
          'created_at': DateTime.now().toIso8601String(),
        };
        _webFigures.add(newFigure);
      }
      
      // 插入核心思想
      for (var thought in coreThoughts) {
        _webFigureThoughts.add({
          'id': _webFigureThoughts.length + 1,
          'figure_id': figureId,
          'thought': thought,
        });
      }
      
      // 插入著作
      for (var work in works) {
        _webFigureWorks.add({
          'id': _webFigureWorks.length + 1,
          'figure_id': figureId,
          'work': work,
        });
      }
      
      return;
    }
    
    final db = await database;
    final transaction = await db.transaction((txn) async {
      // 检查人物是否存在
      final existingFigures = await txn.query('figures', where: 'name = ?', whereArgs: [name]);
      int figureId;
      
      if (existingFigures.isNotEmpty) {
        // 更新现有人物
        await txn.update('figures', {
          'bio': bio,
        }, where: 'id = ?', whereArgs: [existingFigures.first['id']]);
        figureId = existingFigures.first['id'] as int;
        
        // 删除旧的核心思想和著作
        await txn.delete('figure_thoughts', where: 'figure_id = ?', whereArgs: [figureId]);
        await txn.delete('figure_works', where: 'figure_id = ?', whereArgs: [figureId]);
      } else {
        // 插入新人物
        figureId = await txn.insert('figures', {
          'name': name,
          'era': '',
          'era_order': 999,
          'description': '',
          'bio': bio,
        });
      }
      
      // 插入核心思想
      for (var thought in coreThoughts) {
        await txn.insert('figure_thoughts', {
          'figure_id': figureId,
          'thought': thought,
        });
      }
      
      // 插入著作
      for (var work in works) {
        await txn.insert('figure_works', {
          'figure_id': figureId,
          'work': work,
        });
      }
    });
  }

  // 派系相关操作
  Future<List<Map<String, dynamic>>> getAllSects() async {
    if (kIsWeb) {
      // 在web平台上使用内存存储
      final sects = List<Map<String, dynamic>>.from(_webSects);
      
      for (var sect in sects) {
        // 获取派系信息
        final info = _webSectInfo.where((i) => i['sect_id'] == sect['id']).toList();
        final infoMap = <String, String>{};
        for (var item in info) {
          infoMap[item['key'] as String] = item['value'] as String;
        }
        sect['info'] = infoMap;
        
        // 获取代表人物
        final representatives = _webSectRepresentatives.where((r) => r['sect_id'] == sect['id']).map((r) => r['figure_name']).toList();
        sect['representatives'] = representatives;
      }
      
      return sects;
    }
    
    final db = await database;
    final sects = await db.query('sects', orderBy: 'id ASC');
    
    for (var sect in sects) {
      // 获取派系信息
      final info = await db.query('sect_info', where: 'sect_id = ?', whereArgs: [sect['id']]);
      final infoMap = <String, String>{};
      for (var item in info) {
        infoMap[item['key'] as String] = item['value'] as String;
      }
      sect['info'] = infoMap;
      
      // 获取代表人物
      final representatives = await db.query('sect_representatives', where: 'sect_id = ?', whereArgs: [sect['id']]);
      sect['representatives'] = representatives.map((r) => r['figure_name']).toList();
    }
    
    return sects;
  }

  Future<Map<String, dynamic>?> getSectById(int id) async {
    if (kIsWeb) {
      // 在web平台上使用内存存储
      final sect = _webSects.firstWhere((s) => s['id'] == id, orElse: () => {});
      if (sect.isEmpty) return null;
      
      // 获取派系信息
      final info = _webSectInfo.where((i) => i['sect_id'] == sect['id']).toList();
      final infoMap = <String, String>{};
      for (var item in info) {
        infoMap[item['key'] as String] = item['value'] as String;
      }
      sect['info'] = infoMap;
      
      // 获取代表人物
      final representatives = _webSectRepresentatives.where((r) => r['sect_id'] == sect['id']).map((r) => r['figure_name']).toList();
      sect['representatives'] = representatives;
      
      return sect;
    }
    
    final db = await database;
    final result = await db.query('sects', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    
    final sect = result.first;
    // 获取派系信息
    final info = await db.query('sect_info', where: 'sect_id = ?', whereArgs: [sect['id']]);
    final infoMap = <String, String>{};
    for (var item in info) {
      infoMap[item['key'] as String] = item['value'] as String;
    }
    sect['info'] = infoMap;
    
    // 获取代表人物
    final representatives = await db.query('sect_representatives', where: 'sect_id = ?', whereArgs: [sect['id']]);
    sect['representatives'] = representatives.map((r) => r['figure_name']).toList();
    
    return sect;
  }
}
