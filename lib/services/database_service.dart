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
    
    if (_database != null) {
      // 检查数据库中是否有数据，如果没有，插入初始数据
      await _checkAndInsertInitialData(_database!);
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }
  
  // 检查并插入初始数据
  Future<void> _checkAndInsertInitialData(Database db) async {
    // 先删除现有的数据，确保插入完整的初始数据
    await db.delete('figure_works');
    await db.delete('figure_thoughts');
    await db.delete('figures');
    
    await db.delete('sect_representatives');
    await db.delete('sect_info');
    await db.delete('sects');
    
    // 插入完整的初始数据
    await _insertDefaultFigures(db);
    await _insertDefaultSects(db);
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
      // 先秦时期
      {'id': 1, 'name': '老子', 'era': '春秋', 'era_order': 1, 'description': '道家学派创始人，著有《道德经》', 'bio': '老子，姓李名耳，字聃，春秋末期人。他是道家学派的创始人，被尊为道教始祖。老子主张无为而治，强调顺应自然，其思想对中国哲学产生了深远影响。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 2, 'name': '文子', 'era': '春秋', 'era_order': 1, 'description': '道家思想家，老子弟子', 'bio': '文子，姓辛名钘，字文子，春秋时期宋国人，老子的弟子。著有《文子》，以"道生法"为核心，将《道德经》的"无为"转化为治国方略，主张"循道而治""以德辅法"，为汉初"黄老之治"提供理论支撑。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 3, 'name': '关尹子', 'era': '春秋', 'era_order': 1, 'description': '道家思想家，文始派创始人', 'bio': '关尹子，名喜，字公度，春秋时期函谷关令。他是老子的弟子，著有《关尹子》，主张"贵清""贵虚"，强调精神的自由和超越，是文始派的创始人。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 4, 'name': '庄子', 'era': '战国', 'era_order': 2, 'description': '道家代表人物，著有《庄子》', 'bio': '庄子，名周，战国时期宋国人。他是道家学派的重要代表人物，继承和发展了老子的思想。庄子主张逍遥游，追求精神自由，其作品富有哲理和文学性。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 5, 'name': '列子', 'era': '战国', 'era_order': 2, 'description': '道家思想家，著有《列子》', 'bio': '列子，名御寇，战国时期郑国人。他是道家学派的重要代表人物，其思想强调虚静无为，顺应自然。《列子》一书包含了许多寓言故事，富有哲理。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 6, 'name': '杨朱', 'era': '战国', 'era_order': 2, 'description': '道家思想家，主张贵己', 'bio': '杨朱，战国时期魏国人。他是道家学派的重要代表人物，主张"贵己""重生"，强调个人的生命价值和自由，对后世道教的个人修炼思想有重要影响。', 'created_at': DateTime.now().toIso8601String()},
      
      // 秦汉时期
      {'id': 7, 'name': '张道陵', 'era': '东汉', 'era_order': 3, 'description': '道教创始人，五斗米道祖师', 'bio': '张道陵，字辅汉，东汉时期沛国人。他在四川鹤鸣山创立五斗米道，被尊为"张天师"，是道教的创始人。他以《老子想尔注》将"道"神格化，确立"守戒积善""符箓治病"传教模式。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 8, 'name': '张衡', 'era': '东汉', 'era_order': 3, 'description': '五斗米道第二代天师', 'bio': '张衡，字灵真，张道陵之子。他继承父业，继续传播五斗米道，是五斗米道的第二代天师。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 9, 'name': '张鲁', 'era': '东汉', 'era_order': 3, 'description': '五斗米道第三代天师', 'bio': '张鲁，字公祺，张衡之子。他在汉中建立政教合一政权，推行"宽刑、义舍、禁酒"政策，使汉中成为乱世中的稳定区域，扩大了五斗米道的影响力。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 10, 'name': '张角', 'era': '东汉', 'era_order': 3, 'description': '太平道创始人', 'bio': '张角，东汉末年钜鹿人。他以《太平经》为理论基础，创立太平道，提出"苍天已死，黄天当立"口号，组织黄巾起义，扩大了道教在底层社会的影响力。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 11, 'name': '于吉', 'era': '东汉', 'era_order': 3, 'description': '太平道思想传播者', 'bio': '于吉，东汉末年琅琊人。他整理编纂《太平经》，融合道家无为、儒家伦理与民间信仰，主张"太平世"理想，强调"积善成仙""财物共养"。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 12, 'name': '魏伯阳', 'era': '东汉', 'era_order': 3, 'description': '丹道理论奠基人', 'bio': '魏伯阳，东汉末年会稽上虞人。他著有《周易参同契》，融合《周易》阴阳学说、黄老思想与炼丹术，首次系统阐述"内丹"与"外丹"理论，为后世丹道学提供核心框架。', 'created_at': DateTime.now().toIso8601String()},
      
      // 魏晋南北朝时期
      {'id': 13, 'name': '葛玄', 'era': '三国', 'era_order': 4, 'description': '灵宝派祖师', 'bio': '葛玄，字孝先，三国时期吴国人。他传习"灵宝经法"，擅长符箓驱邪、炼丹养生，整理道教法术文献，是灵宝派的祖师。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 14, 'name': '葛洪', 'era': '东晋', 'era_order': 4, 'description': '道教理论家、炼丹家', 'bio': '葛洪，字稚川，东晋时期丹阳句容人。他著有《抱朴子》，系统阐述金丹修炼理论，为丹道奠定基础，同时也是著名的医药学家。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 15, 'name': '魏华存', 'era': '东晋', 'era_order': 4, 'description': '上清派祖师', 'bio': '魏华存，字贤安，东晋时期任城人。她是上清派的创始人，传《上清经》，主张存思守一的修炼方法，被尊为"紫虚元君"。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 16, 'name': '杨羲', 'era': '东晋', 'era_order': 4, 'description': '上清派重要传人', 'bio': '杨羲，东晋时期吴国人。他是上清派的重要传人，传习《上清经》，整理上清派经典，对上清派的发展做出了重要贡献。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 17, 'name': '许谧', 'era': '东晋', 'era_order': 4, 'description': '上清派重要传人', 'bio': '许谧，东晋时期丹阳句容人。他是上清派的重要传人，与杨羲一起整理上清派经典，对上清派的发展做出了重要贡献。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 18, 'name': '陶弘景', 'era': '南朝', 'era_order': 4, 'description': '茅山宗创始人', 'bio': '陶弘景，字通明，南朝时期丹阳秣陵人。他整理上清派典籍，构建道教神仙体系，撰写《真灵位业图》，使茅山成为道教上清派的中心，被尊为"华阳真人"。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 19, 'name': '寇谦之', 'era': '北魏', 'era_order': 4, 'description': '新天师道创始人', 'bio': '寇谦之，字辅真，北魏时期冯翊万年人。他改革天师道，清整戒律，创立新天师道，获得北魏统治者的正式承认，成为官方宗教。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 20, 'name': '陆修静', 'era': '南朝', 'era_order': 4, 'description': '道教经典整理者', 'bio': '陆修静，字元德，南朝时期吴兴东迁人。他整理道教经典，总括三洞，撰写《三洞经书目录》，建立了完善的经典教义与科戒仪式，极大地推进了灵宝派的发展。', 'created_at': DateTime.now().toIso8601String()},
      
      // 隋唐时期
      {'id': 21, 'name': '孙思邈', 'era': '唐代', 'era_order': 5, 'description': '道医、丹道大师', 'bio': '孙思邈，唐代京兆华原人。他融道医与丹道，著《千金方》，被誉为"药王"，对道教医学的发展做出了重要贡献。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 22, 'name': '司马承祯', 'era': '唐代', 'era_order': 5, 'description': '上清派传人', 'bio': '司马承祯，字子微，唐代河内温人。他弘扬上清派修炼法门，著《坐忘论》，主张"坐忘""主静"的修炼方法，对道教内丹学的发展做出了重要贡献。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 23, 'name': '吴筠', 'era': '唐代', 'era_order': 5, 'description': '上清派传人', 'bio': '吴筠，字贞节，唐代华州华阴人。他弘扬上清派修炼法门，著《玄纲论》，主张"守静""坐忘"的修炼方法，对道教内丹学的发展做出了重要贡献。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 24, 'name': '王玄甫', 'era': '唐代', 'era_order': 5, 'description': '少阳派始祖', 'bio': '王玄甫，唐代人，号东华帝君。他传承金丹道脉，为少阳派始祖，开启钟吕金丹道传承，奠定后世丹道主流基础。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 25, 'name': '钟离权', 'era': '唐代', 'era_order': 5, 'description': '少阳派传人', 'bio': '钟离权，唐代咸阳人，号正阳子。他传承金丹道脉，与吕洞宾一起创立钟吕金丹道，对后世丹道学的发展做出了重要贡献。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 26, 'name': '吕洞宾', 'era': '唐代', 'era_order': 5, 'description': '纯阳派创始人', 'bio': '吕洞宾，唐代河中府永乐县人，号纯阳子。他传承金丹道脉，创立纯阳派，主张性命双修，对后世丹道学的发展做出了重要贡献。', 'created_at': DateTime.now().toIso8601String()},
      
      // 宋辽金时期
      {'id': 27, 'name': '陈抟', 'era': '北宋', 'era_order': 6, 'description': '文始派传人', 'bio': '陈抟，字图南，北宋时期亳州真源人。他传承文始派脉，融文始、少阳二派精髓，著《指玄篇》，影响张三丰丹法，被尊为"希夷先生"。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 28, 'name': '张伯端', 'era': '北宋', 'era_order': 6, 'description': '南宗创始人', 'bio': '张伯端，字平叔，北宋时期天台人。他创立金丹派南宗，主先命后性，著《悟真篇》，对后世丹道学的发展做出了重要贡献。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 29, 'name': '王重阳', 'era': '金代', 'era_order': 6, 'description': '全真道创始人', 'bio': '王重阳，字知明，金代咸阳人。他创立全真道，主张三教合一、先性后命，传北七真，对道教的发展做出了重要贡献。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 30, 'name': '丘处机', 'era': '金代', 'era_order': 6, 'description': '龙门派创始人', 'bio': '丘处机，字通密，金代登州栖霞人。他是全真七子之一，创立龙门派，主张"功行双全"，对全真道的发展做出了重要贡献。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 31, 'name': '马钰', 'era': '金代', 'era_order': 6, 'description': '遇仙派创始人', 'bio': '马钰，字玄宝，金代宁海人。他是全真七子之一，创立遇仙派，主张"清净无为"，对全真道的发展做出了重要贡献。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 32, 'name': '谭处端', 'era': '金代', 'era_order': 6, 'description': '南无派创始人', 'bio': '谭处端，字通正，金代宁海人。他是全真七子之一，创立南无派，主张"清静无为"，对全真道的发展做出了重要贡献。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 33, 'name': '刘处玄', 'era': '金代', 'era_order': 6, 'description': '随山派创始人', 'bio': '刘处玄，字通妙，金代东莱人。他是全真七子之一，创立随山派，主张"无为而治"，对全真道的发展做出了重要贡献。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 34, 'name': '王处一', 'era': '金代', 'era_order': 6, 'description': '嵛山派创始人', 'bio': '王处一，字通叟，金代宁海人。他是全真七子之一，创立嵛山派，主张"清静无为"，对全真道的发展做出了重要贡献。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 35, 'name': '郝大通', 'era': '金代', 'era_order': 6, 'description': '华山派创始人', 'bio': '郝大通，字太古，金代宁海人。他是全真七子之一，创立华山派，主张"清静无为"，对全真道的发展做出了重要贡献。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 36, 'name': '孙不二', 'era': '金代', 'era_order': 6, 'description': '清静派创始人', 'bio': '孙不二，号清静散人，金代宁海人。她是全真七子之一，创立清静派，主张"清静无为"，是唯一的女性创始人。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 37, 'name': '白玉蟾', 'era': '南宋', 'era_order': 6, 'description': '南宗重要传人', 'bio': '白玉蟾，字如晦，南宋时期琼州人。他是金丹派南宗的重要传人，主张性命双修，对南宗的发展做出了重要贡献。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 38, 'name': '萧抱珍', 'era': '金代', 'era_order': 6, 'description': '太一道创始人', 'bio': '萧抱珍，金代卫州人。他创立太一道，重符箓斋醮，规定道士必须出家，七传以后逐渐与正一道相融合。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 39, 'name': '刘德仁', 'era': '金代', 'era_order': 6, 'description': '真大道创始人', 'bio': '刘德仁，金代沧州乐陵人。他创立真大道，以清心寡欲、谦卑自守、力作而食为教旨，元以后逐渐衰落并消失。', 'created_at': DateTime.now().toIso8601String()},
      
      // 元明清时期
      {'id': 40, 'name': '张三丰', 'era': '明代', 'era_order': 7, 'description': '三丰派创始人', 'bio': '张三丰，明代辽东懿州人。他创立三丰派，融文始、少阳二派，主张性命双修，对道教的发展做出了重要贡献。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 41, 'name': '张正常', 'era': '明代', 'era_order': 7, 'description': '正一道天师', 'bio': '张正常，明代龙虎山道士。他是正一道的天师，受朝廷认可，延续天师道的传承。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 42, 'name': '张宇初', 'era': '明代', 'era_order': 7, 'description': '正一道天师', 'bio': '张宇初，明代龙虎山道士。他是正一道的天师，著《道门十规》，对正一道的发展做出了重要贡献。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 43, 'name': '伍冲虚', 'era': '明代', 'era_order': 7, 'description': '伍柳派创始人', 'bio': '伍冲虚，明代江西南昌人。他创立伍柳派，简化丹道修炼法门，对丹道学的发展做出了重要贡献。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 44, 'name': '柳华阳', 'era': '清代', 'era_order': 8, 'description': '伍柳派创始人', 'bio': '柳华阳，清代江西南昌人。他与伍冲虚一起创立伍柳派，简化丹道修炼法门，对丹道学的发展做出了重要贡献。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 45, 'name': '赵避尘', 'era': '清代', 'era_order': 8, 'description': '千峰派创始人', 'bio': '赵避尘，清代北京人。他创立千峰派，改丹道单传为普传，对丹道学的发展做出了重要贡献。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 46, 'name': '张恩溥', 'era': '清代', 'era_order': 8, 'description': '正一道天师', 'bio': '张恩溥，清代龙虎山道士。他是正一道的天师，第六十三代天师，赴台延续道统。', 'created_at': DateTime.now().toIso8601String()},
    ];
    
    // 初始化人物核心思想
    _webFigureThoughts = [
      // 先秦时期
      {'id': 1, 'figure_id': 1, 'thought': '无为'},
      {'id': 2, 'figure_id': 1, 'thought': '道法自然'},
      {'id': 3, 'figure_id': 1, 'thought': '小国寡民'},
      {'id': 4, 'figure_id': 1, 'thought': '柔弱胜刚强'},
      {'id': 5, 'figure_id': 1, 'thought': '玄之又玄'},
      {'id': 6, 'figure_id': 2, 'thought': '道生法'},
      {'id': 7, 'figure_id': 2, 'thought': '循道而治'},
      {'id': 8, 'figure_id': 2, 'thought': '以德辅法'},
      {'id': 9, 'figure_id': 3, 'thought': '贵清'},
      {'id': 10, 'figure_id': 3, 'thought': '贵虚'},
      {'id': 11, 'figure_id': 3, 'thought': '精神自由'},
      {'id': 12, 'figure_id': 4, 'thought': '逍遥游'},
      {'id': 13, 'figure_id': 4, 'thought': '齐物论'},
      {'id': 14, 'figure_id': 4, 'thought': '相对主义'},
      {'id': 15, 'figure_id': 4, 'thought': '坐忘'},
      {'id': 16, 'figure_id': 5, 'thought': '虚静'},
      {'id': 17, 'figure_id': 5, 'thought': '无为'},
      {'id': 18, 'figure_id': 5, 'thought': '自然'},
      {'id': 19, 'figure_id': 6, 'thought': '贵己'},
      {'id': 20, 'figure_id': 6, 'thought': '重生'},
      {'id': 21, 'figure_id': 6, 'thought': '为我'},
      
      // 秦汉时期
      {'id': 22, 'figure_id': 7, 'thought': '守戒积善'},
      {'id': 23, 'figure_id': 7, 'thought': '符箓治病'},
      {'id': 24, 'figure_id': 7, 'thought': '道即太上老君'},
      {'id': 25, 'figure_id': 10, 'thought': '太平世'},
      {'id': 26, 'figure_id': 10, 'thought': '积善成仙'},
      {'id': 27, 'figure_id': 10, 'thought': '财物共养'},
      {'id': 28, 'figure_id': 12, 'thought': '内丹'},
      {'id': 29, 'figure_id': 12, 'thought': '外丹'},
      {'id': 30, 'figure_id': 12, 'thought': '周易参同'},
      
      // 魏晋南北朝时期
      {'id': 31, 'figure_id': 13, 'thought': '灵宝经法'},
      {'id': 32, 'figure_id': 13, 'thought': '符箓驱邪'},
      {'id': 33, 'figure_id': 13, 'thought': '炼丹养生'},
      {'id': 34, 'figure_id': 14, 'thought': '金丹修炼'},
      {'id': 35, 'figure_id': 14, 'thought': '神仙方术'},
      {'id': 36, 'figure_id': 14, 'thought': '医药养生'},
      {'id': 37, 'figure_id': 15, 'thought': '存思守一'},
      {'id': 38, 'figure_id': 15, 'thought': '上清经法'},
      {'id': 39, 'figure_id': 18, 'thought': '神仙体系'},
      {'id': 40, 'figure_id': 18, 'thought': '三教合一'},
      {'id': 41, 'figure_id': 18, 'thought': '内丹修炼'},
      {'id': 42, 'figure_id': 19, 'thought': '清整戒律'},
      {'id': 43, 'figure_id': 19, 'thought': '新天师道'},
      {'id': 44, 'figure_id': 20, 'thought': '三洞经书'},
      {'id': 45, 'figure_id': 20, 'thought': '科戒仪式'},
      
      // 隋唐时期
      {'id': 46, 'figure_id': 21, 'thought': '道医结合'},
      {'id': 47, 'figure_id': 21, 'thought': '养生保健'},
      {'id': 48, 'figure_id': 22, 'thought': '坐忘'},
      {'id': 49, 'figure_id': 22, 'thought': '主静'},
      {'id': 50, 'figure_id': 23, 'thought': '守静'},
      {'id': 51, 'figure_id': 23, 'thought': '坐忘'},
      {'id': 52, 'figure_id': 25, 'thought': '金丹道'},
      {'id': 53, 'figure_id': 25, 'thought': '性命双修'},
      {'id': 54, 'figure_id': 26, 'thought': '纯阳道'},
      {'id': 55, 'figure_id': 26, 'thought': '性命双修'},
      
      // 宋辽金时期
      {'id': 56, 'figure_id': 27, 'thought': '指玄'},
      {'id': 57, 'figure_id': 27, 'thought': '内丹修炼'},
      {'id': 58, 'figure_id': 28, 'thought': '先命后性'},
      {'id': 59, 'figure_id': 28, 'thought': '内丹修炼'},
      {'id': 60, 'figure_id': 29, 'thought': '三教合一'},
      {'id': 61, 'figure_id': 29, 'thought': '先性后命'},
      {'id': 62, 'figure_id': 29, 'thought': '出家清修'},
      {'id': 63, 'figure_id': 30, 'thought': '功行双全'},
      {'id': 64, 'figure_id': 30, 'thought': '龙门心法'},
      {'id': 65, 'figure_id': 31, 'thought': '清净无为'},
      {'id': 66, 'figure_id': 32, 'thought': '清静无为'},
      {'id': 67, 'figure_id': 33, 'thought': '无为而治'},
      {'id': 68, 'figure_id': 34, 'thought': '清静无为'},
      {'id': 69, 'figure_id': 35, 'thought': '清静无为'},
      {'id': 70, 'figure_id': 36, 'thought': '清静无为'},
      {'id': 71, 'figure_id': 37, 'thought': '性命双修'},
      {'id': 72, 'figure_id': 37, 'thought': '内丹修炼'},
      {'id': 73, 'figure_id': 38, 'thought': '太一三元法箓'},
      {'id': 74, 'figure_id': 38, 'thought': '符箓斋醮'},
      {'id': 75, 'figure_id': 39, 'thought': '清心寡欲'},
      {'id': 76, 'figure_id': 39, 'thought': '谦卑自守'},
      {'id': 77, 'figure_id': 39, 'thought': '力作而食'},
      
      // 元明清时期
      {'id': 78, 'figure_id': 40, 'thought': '性命双修'},
      {'id': 79, 'figure_id': 40, 'thought': '三教合一'},
      {'id': 80, 'figure_id': 40, 'thought': '内丹修炼'},
      {'id': 81, 'figure_id': 42, 'thought': '道门十规'},
      {'id': 82, 'figure_id': 42, 'thought': '正一道规'},
      {'id': 83, 'figure_id': 43, 'thought': '内丹简化'},
      {'id': 84, 'figure_id': 44, 'thought': '内丹简化'},
      {'id': 85, 'figure_id': 45, 'thought': '丹道普传'},
      {'id': 86, 'figure_id': 45, 'thought': '内丹修炼'},
    ];
    
    // 初始化人物著作
    _webFigureWorks = [
      // 先秦时期
      {'id': 1, 'figure_id': 1, 'work': '道德经'},
      {'id': 2, 'figure_id': 2, 'work': '文子'},
      {'id': 3, 'figure_id': 3, 'work': '关尹子'},
      {'id': 4, 'figure_id': 4, 'work': '庄子'},
      {'id': 5, 'figure_id': 5, 'work': '列子'},
      {'id': 6, 'figure_id': 6, 'work': '杨朱篇'},
      
      // 秦汉时期
      {'id': 7, 'figure_id': 7, 'work': '老子想尔注'},
      {'id': 8, 'figure_id': 10, 'work': '太平经'},
      {'id': 9, 'figure_id': 11, 'work': '太平经'},
      {'id': 10, 'figure_id': 12, 'work': '周易参同契'},
      
      // 魏晋南北朝时期
      {'id': 11, 'figure_id': 14, 'work': '抱朴子'},
      {'id': 12, 'figure_id': 14, 'work': '肘后备急方'},
      {'id': 13, 'figure_id': 15, 'work': '黄庭经'},
      {'id': 14, 'figure_id': 18, 'work': '真诰'},
      {'id': 15, 'figure_id': 18, 'work': '登真隐诀'},
      {'id': 16, 'figure_id': 18, 'work': '真灵位业图'},
      {'id': 17, 'figure_id': 20, 'work': '三洞经书目录'},
      
      // 隋唐时期
      {'id': 18, 'figure_id': 21, 'work': '千金方'},
      {'id': 19, 'figure_id': 21, 'work': '千金翼方'},
      {'id': 20, 'figure_id': 22, 'work': '坐忘论'},
      {'id': 21, 'figure_id': 23, 'work': '玄纲论'},
      
      // 宋辽金时期
      {'id': 22, 'figure_id': 27, 'work': '指玄篇'},
      {'id': 23, 'figure_id': 27, 'work': '无极图'},
      {'id': 24, 'figure_id': 28, 'work': '悟真篇'},
      {'id': 25, 'figure_id': 29, 'work': '重阳立教十五论'},
      {'id': 26, 'figure_id': 30, 'work': '大丹直指'},
      {'id': 27, 'figure_id': 37, 'work': '海琼玉蟾先生文集'},
      
      // 元明清时期
      {'id': 28, 'figure_id': 40, 'work': '张三丰全集'},
      {'id': 29, 'figure_id': 42, 'work': '道门十规'},
      {'id': 30, 'figure_id': 43, 'work': '伍柳仙宗'},
      {'id': 31, 'figure_id': 45, 'work': '性命法诀明指'},
    ];
    
    // 初始化派系数据
    _webSects = [
      // 早期道教
      {'id': 1, 'name': '五斗米道', 'dynasty': '东汉', 'practice': '符箓', 'description': '五斗米道是道教的早期派别之一，由张道陵创立于东汉末年。入教者需缴纳五斗米，故得名五斗米道。教内设二十四治，以符水治病、靖室思过、劝善修道为主要活动。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 2, 'name': '太平道', 'dynasty': '东汉', 'practice': '符箓', 'description': '太平道是道教的早期派别之一，由张角创立于东汉末年。以《太平经》为理论基础，以符水咒说治病，发动黄巾起义，扩大了道教在底层社会的影响力。', 'created_at': DateTime.now().toIso8601String()},
      
      // 魏晋南北朝时期
      {'id': 3, 'name': '上清派', 'dynasty': '魏晋', 'practice': '存思', 'description': '上清派是道教的重要派别之一，以《上清经》为主要经典，强调存思守一的修炼方法。由魏华存创立，陶弘景发展壮大。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 4, 'name': '灵宝派', 'dynasty': '魏晋', 'practice': '斋醮', 'description': '灵宝派是道教的重要派别之一，以《灵宝经》为主要经典，强调斋醮科仪的重要性。由葛玄创立，陆修静发展壮大。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 5, 'name': '三皇派', 'dynasty': '魏晋', 'practice': '符箓', 'description': '三皇派是道教的重要派别之一，以《三皇经》为主要经典，注重符箓法术和炼丹修炼。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 6, 'name': '楼观道', 'dynasty': '魏晋', 'practice': '内丹', 'description': '楼观道是道教的重要派别之一，以终南山为中心，奉老君和关令尹喜为祖师，传习《道德》《西升》等经典。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 7, 'name': '茅山派', 'dynasty': '南北朝', 'practice': '符箓', 'description': '茅山派是道教的重要派别之一，以茅山为圣地，注重符箓法术和内丹修炼。由陶弘景发展壮大，是上清派的重要支派。', 'created_at': DateTime.now().toIso8601String()},
      
      // 隋唐时期
      {'id': 8, 'name': '天师道', 'dynasty': '隋唐', 'practice': '符箓', 'description': '天师道是道教的重要派别之一，由张道陵后裔传承，注重符箓法术和斋醮科仪。唐代得到统治者的尊崇，地位显赫。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 9, 'name': '钟吕金丹派', 'dynasty': '唐代', 'practice': '内丹', 'description': '钟吕金丹派是道教的重要派别之一，由钟离权和吕洞宾创立，主张内丹修炼，强调性命双修。', 'created_at': DateTime.now().toIso8601String()},
      
      // 宋辽金时期
      {'id': 10, 'name': '金丹派南宗', 'dynasty': '北宋', 'practice': '内丹', 'description': '金丹派南宗是道教的重要派别之一，由张伯端创立，主张先命后性的内丹修炼方法，著有《悟真篇》。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 11, 'name': '全真道', 'dynasty': '金代', 'practice': '清修', 'description': '全真道是道教的重要派别之一，由王重阳创立，主张三教合一、先性后命、出家清修，传北七真。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 12, 'name': '太一道', 'dynasty': '金代', 'practice': '符箓', 'description': '太一道是道教的重要派别之一，由萧抱珍创立，重符箓斋醮，规定道士必须出家，七传以后逐渐与正一道相融合。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 13, 'name': '真大道', 'dynasty': '金代', 'practice': '清修', 'description': '真大道是道教的重要派别之一，由刘德仁创立，以清心寡欲、谦卑自守、力作而食为教旨，元以后逐渐衰落并消失。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 14, 'name': '净明道', 'dynasty': '南宋', 'practice': '忠孝', 'description': '净明道是道教的重要派别之一，强调忠孝伦理，融合儒家思想与道教修炼。由许逊创立，刘玉发展壮大。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 15, 'name': '神霄派', 'dynasty': '宋代', 'practice': '雷法', 'description': '神霄派是道教的重要派别之一，以内丹修炼为基础，结合雷法（呼召雷电之术），影响广泛。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 16, 'name': '清微派', 'dynasty': '宋代', 'practice': '雷法', 'description': '清微派是道教的重要派别之一，也以内丹为本，结合符箓雷法，强调"清微天"之炁。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 17, 'name': '天心派', 'dynasty': '宋代', 'practice': '符箓', 'description': '天心派是道教的重要派别之一，以传"天心正法"著称，注重符箓法术和斋醮科仪。', 'created_at': DateTime.now().toIso8601String()},
      
      // 元明清时期
      {'id': 18, 'name': '龙门派', 'dynasty': '元代', 'practice': '清修', 'description': '龙门派是全真道的重要支派，由丘处机创立，强调严格的清修戒律和内丹修炼，是全真道中传承最广、影响最大的一派。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 19, 'name': '遇仙派', 'dynasty': '元代', 'practice': '清修', 'description': '遇仙派是全真道的重要支派，由马钰创立，主张"清净无为"。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 20, 'name': '南无派', 'dynasty': '元代', 'practice': '清修', 'description': '南无派是全真道的重要支派，由谭处端创立，主张"清静无为"。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 21, 'name': '随山派', 'dynasty': '元代', 'practice': '清修', 'description': '随山派是全真道的重要支派，由刘处玄创立，主张"无为而治"。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 22, 'name': '嵛山派', 'dynasty': '元代', 'practice': '清修', 'description': '嵛山派是全真道的重要支派，由王处一创立，主张"清静无为"。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 23, 'name': '华山派', 'dynasty': '元代', 'practice': '清修', 'description': '华山派是全真道的重要支派，由郝大通创立，主张"清静无为"。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 24, 'name': '清静派', 'dynasty': '元代', 'practice': '清修', 'description': '清静派是全真道的重要支派，由孙不二创立，主张"清静无为"，是唯一的女性创始人。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 25, 'name': '正一道', 'dynasty': '元代', 'practice': '符箓', 'description': '正一道是道教的主要派别之一，由天师道长期演变并与上清、灵宝等派逐渐融合而成。元大德八年（1304），第三十八代天师张与材为正一教主，主领三山符。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 26, 'name': '三丰派', 'dynasty': '明代', 'practice': '内丹', 'description': '三丰派是道教的重要派别之一，由张三丰创立，融文始、少阳二派，主张性命双修，对道教的发展做出了重要贡献。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 27, 'name': '伍柳派', 'dynasty': '明代', 'practice': '内丹', 'description': '伍柳派是道教的重要派别之一，由伍冲虚和柳华阳创立，简化丹道修炼法门，对丹道学的发展做出了重要贡献。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 28, 'name': '千峰派', 'dynasty': '清代', 'practice': '内丹', 'description': '千峰派是道教的重要派别之一，由赵避尘创立，改丹道单传为普传，对丹道学的发展做出了重要贡献。', 'created_at': DateTime.now().toIso8601String()},
      {'id': 29, 'name': '青城派', 'dynasty': '清代', 'practice': '内丹', 'description': '青城派是道教的重要派别之一，以青城山为圣地，注重内丹修炼和武术。', 'created_at': DateTime.now().toIso8601String()},
    ];
    
    // 初始化派系信息
    _webSectInfo = [
      // 早期道教
      {'id': 1, 'sect_id': 1, 'key': '修行方式', 'value': '符水治病、靖室思过、劝善修道'},
      {'id': 2, 'sect_id': 1, 'key': '理念', 'value': '守戒积善、道即太上老君'},
      {'id': 3, 'sect_id': 1, 'key': '经典', 'value': '《老子想尔注》'},
      {'id': 4, 'sect_id': 1, 'key': '圣地', 'value': '鹤鸣山、龙虎山'},
      {'id': 5, 'sect_id': 2, 'key': '修行方式', 'value': '符水咒说、治病救人'},
      {'id': 6, 'sect_id': 2, 'key': '理念', 'value': '太平世、积善成仙、财物共养'},
      {'id': 7, 'sect_id': 2, 'key': '经典', 'value': '《太平经》'},
      {'id': 8, 'sect_id': 2, 'key': '圣地', 'value': '钜鹿'},
      
      // 魏晋南北朝时期
      {'id': 9, 'sect_id': 3, 'key': '修行方式', 'value': '存思守一、服气内丹'},
      {'id': 10, 'sect_id': 3, 'key': '理念', 'value': '上清道妙、存思成仙'},
      {'id': 11, 'sect_id': 3, 'key': '经典', 'value': '《上清大洞真经》、《黄庭经》'},
      {'id': 12, 'sect_id': 3, 'key': '圣地', 'value': '茅山、天台山'},
      {'id': 13, 'sect_id': 4, 'key': '修行方式', 'value': '斋醮科仪、符箓诵经'},
      {'id': 14, 'sect_id': 4, 'key': '理念', 'value': '超度亡灵、积累功德'},
      {'id': 15, 'sect_id': 4, 'key': '经典', 'value': '《灵宝无量度人上品妙经》'},
      {'id': 16, 'sect_id': 4, 'key': '圣地', 'value': '阁皂山'},
      {'id': 17, 'sect_id': 5, 'key': '修行方式', 'value': '符箓法术、炼丹修炼'},
      {'id': 18, 'sect_id': 5, 'key': '理念', 'value': '驱邪避凶、修道成仙'},
      {'id': 19, 'sect_id': 5, 'key': '经典', 'value': '《三皇经》'},
      {'id': 20, 'sect_id': 5, 'key': '圣地', 'value': '龙虎山'},
      {'id': 21, 'sect_id': 6, 'key': '修行方式', 'value': '内丹修炼、符箓法术'},
      {'id': 22, 'sect_id': 6, 'key': '理念', 'value': '清静无为、道法自然'},
      {'id': 23, 'sect_id': 6, 'key': '经典', 'value': '《道德经》、《西升经》'},
      {'id': 24, 'sect_id': 6, 'key': '圣地', 'value': '终南山楼观台'},
      {'id': 25, 'sect_id': 7, 'key': '修行方式', 'value': '符箓法术、内丹修炼'},
      {'id': 26, 'sect_id': 7, 'key': '理念', 'value': '济世度人、修道成仙'},
      {'id': 27, 'sect_id': 7, 'key': '经典', 'value': '《真诰》、《登真隐诀》'},
      {'id': 28, 'sect_id': 7, 'key': '圣地', 'value': '茅山'},
      
      // 隋唐时期
      {'id': 29, 'sect_id': 8, 'key': '修行方式', 'value': '符箓法术、斋醮科仪'},
      {'id': 30, 'sect_id': 8, 'key': '理念', 'value': '守戒积善、道即太上老君'},
      {'id': 31, 'sect_id': 8, 'key': '经典', 'value': '《老子想尔注》'},
      {'id': 32, 'sect_id': 8, 'key': '圣地', 'value': '龙虎山'},
      {'id': 33, 'sect_id': 9, 'key': '修行方式', 'value': '内丹修炼、性命双修'},
      {'id': 34, 'sect_id': 9, 'key': '理念', 'value': '金丹大道、得道成仙'},
      {'id': 35, 'sect_id': 9, 'key': '经典', 'value': '《钟吕传道集》'},
      {'id': 36, 'sect_id': 9, 'key': '圣地', 'value': '终南山'},
      
      // 宋辽金时期
      {'id': 37, 'sect_id': 10, 'key': '修行方式', 'value': '内丹修炼、先命后性'},
      {'id': 38, 'sect_id': 10, 'key': '理念', 'value': '性命双修、得道成仙'},
      {'id': 39, 'sect_id': 10, 'key': '经典', 'value': '《悟真篇》'},
      {'id': 40, 'sect_id': 10, 'key': '圣地', 'value': '天台'},
      {'id': 41, 'sect_id': 11, 'key': '修行方式', 'value': '内丹修炼、出家清修'},
      {'id': 42, 'sect_id': 11, 'key': '理念', 'value': '三教合一、先性后命、全真而仙'},
      {'id': 43, 'sect_id': 11, 'key': '经典', 'value': '《道德经》、《般若心经》、《孝经》'},
      {'id': 44, 'sect_id': 11, 'key': '圣地', 'value': '终南山、昆嵛山'},
      {'id': 45, 'sect_id': 12, 'key': '修行方式', 'value': '符箓斋醮、祈祷诃禁'},
      {'id': 46, 'sect_id': 12, 'key': '理念', 'value': '太一三元、笃人伦、翊世教'},
      {'id': 47, 'sect_id': 12, 'key': '经典', 'value': '《太一三元法箓》'},
      {'id': 48, 'sect_id': 12, 'key': '圣地', 'value': '卫州'},
      {'id': 49, 'sect_id': 13, 'key': '修行方式', 'value': '清心寡欲、谦卑自守、力作而食'},
      {'id': 50, 'sect_id': 13, 'key': '理念', 'value': '无为保正性命、无相驱役鬼神'},
      {'id': 51, 'sect_id': 13, 'key': '经典', 'value': '《道德经》'},
      {'id': 52, 'sect_id': 13, 'key': '圣地', 'value': '沧州'},
      {'id': 53, 'sect_id': 14, 'key': '修行方式', 'value': '忠孝伦理、内丹修炼'},
      {'id': 54, 'sect_id': 14, 'key': '理念', 'value': '净明忠孝、仙道合一'},
      {'id': 55, 'sect_id': 14, 'key': '经典', 'value': '《净明忠孝全书》'},
      {'id': 56, 'sect_id': 14, 'key': '圣地', 'value': '西山万寿宫'},
      {'id': 57, 'sect_id': 15, 'key': '修行方式', 'value': '内丹修炼、雷法'},
      {'id': 58, 'sect_id': 15, 'key': '理念', 'value': '呼召雷电、驱邪治病'},
      {'id': 59, 'sect_id': 15, 'key': '经典', 'value': '《神霄雷法》'},
      {'id': 60, 'sect_id': 15, 'key': '圣地', 'value': '龙虎山'},
      {'id': 61, 'sect_id': 16, 'key': '修行方式', 'value': '内丹修炼、雷法'},
      {'id': 62, 'sect_id': 16, 'key': '理念', 'value': '清微天炁、驱邪治病'},
      {'id': 63, 'sect_id': 16, 'key': '经典', 'value': '《清微雷法》'},
      {'id': 64, 'sect_id': 16, 'key': '圣地', 'value': '青城山'},
      {'id': 65, 'sect_id': 17, 'key': '修行方式', 'value': '符箓法术、斋醮科仪'},
      {'id': 66, 'sect_id': 17, 'key': '理念', 'value': '天心正法、驱邪治病'},
      {'id': 67, 'sect_id': 17, 'key': '经典', 'value': '《天心正法》'},
      {'id': 68, 'sect_id': 17, 'key': '圣地', 'value': '龙虎山'},
      
      // 元明清时期
      {'id': 69, 'sect_id': 18, 'key': '修行方式', 'value': '内丹修炼、清修戒律'},
      {'id': 70, 'sect_id': 18, 'key': '理念', 'value': '功行双全、龙门心法'},
      {'id': 71, 'sect_id': 18, 'key': '经典', 'value': '《邱祖全书》'},
      {'id': 72, 'sect_id': 18, 'key': '圣地', 'value': '白云观、崂山'},
      {'id': 73, 'sect_id': 19, 'key': '修行方式', 'value': '清净无为、内丹修炼'},
      {'id': 74, 'sect_id': 19, 'key': '理念', 'value': '遇仙得道、清净无为'},
      {'id': 75, 'sect_id': 19, 'key': '经典', 'value': '《丹阳真人语录》'},
      {'id': 76, 'sect_id': 19, 'key': '圣地', 'value': '宁海'},
      {'id': 77, 'sect_id': 20, 'key': '修行方式', 'value': '清静无为、内丹修炼'},
      {'id': 78, 'sect_id': 20, 'key': '理念', 'value': '南无清静、得道成仙'},
      {'id': 79, 'sect_id': 20, 'key': '经典', 'value': '《长真真人语录》'},
      {'id': 80, 'sect_id': 20, 'key': '圣地', 'value': '宁海'},
      {'id': 81, 'sect_id': 21, 'key': '修行方式', 'value': '无为而治、内丹修炼'},
      {'id': 82, 'sect_id': 21, 'key': '理念', 'value': '随山得道、无为而治'},
      {'id': 83, 'sect_id': 21, 'key': '经典', 'value': '《长生子语录》'},
      {'id': 84, 'sect_id': 21, 'key': '圣地', 'value': '东莱'},
      {'id': 85, 'sect_id': 22, 'key': '修行方式', 'value': '清静无为、内丹修炼'},
      {'id': 86, 'sect_id': 22, 'key': '理念', 'value': '嵛山得道、清静无为'},
      {'id': 87, 'sect_id': 22, 'key': '经典', 'value': '《玉阳真人语录》'},
      {'id': 88, 'sect_id': 22, 'key': '圣地', 'value': '宁海'},
      {'id': 89, 'sect_id': 23, 'key': '修行方式', 'value': '清静无为、内丹修炼'},
      {'id': 90, 'sect_id': 23, 'key': '理念', 'value': '华山得道、清静无为'},
      {'id': 91, 'sect_id': 23, 'key': '经典', 'value': '《太古真人语录》'},
      {'id': 92, 'sect_id': 23, 'key': '圣地', 'value': '华山'},
      {'id': 93, 'sect_id': 24, 'key': '修行方式', 'value': '清静无为、内丹修炼'},
      {'id': 94, 'sect_id': 24, 'key': '理念', 'value': '清静得道、女性修炼'},
      {'id': 95, 'sect_id': 24, 'key': '经典', 'value': '《孙不二女丹诗》'},
      {'id': 96, 'sect_id': 24, 'key': '圣地', 'value': '宁海'},
      {'id': 97, 'sect_id': 25, 'key': '修行方式', 'value': '符箓法术、斋醮科仪'},
      {'id': 98, 'sect_id': 25, 'key': '理念', 'value': '驱邪避凶、祈福禳灾'},
      {'id': 99, 'sect_id': 25, 'key': '经典', 'value': '《正一经》、《正统道藏》'},
      {'id': 100, 'sect_id': 25, 'key': '圣地', 'value': '龙虎山、茅山、阁皂山'},
      {'id': 101, 'sect_id': 26, 'key': '修行方式', 'value': '内丹修炼、三教合一'},
      {'id': 102, 'sect_id': 26, 'key': '理念', 'value': '性命双修、得道成仙'},
      {'id': 103, 'sect_id': 26, 'key': '经典', 'value': '《张三丰全集》'},
      {'id': 104, 'sect_id': 26, 'key': '圣地', 'value': '武当山'},
      {'id': 105, 'sect_id': 27, 'key': '修行方式', 'value': '内丹修炼、简化法门'},
      {'id': 106, 'sect_id': 27, 'key': '理念', 'value': '内丹简化、得道成仙'},
      {'id': 107, 'sect_id': 27, 'key': '经典', 'value': '《伍柳仙宗》'},
      {'id': 108, 'sect_id': 27, 'key': '圣地', 'value': '南昌'},
      {'id': 109, 'sect_id': 28, 'key': '修行方式', 'value': '内丹修炼、丹道普传'},
      {'id': 110, 'sect_id': 28, 'key': '理念', 'value': '丹道普传、得道成仙'},
      {'id': 111, 'sect_id': 28, 'key': '经典', 'value': '《性命法诀明指》'},
      {'id': 112, 'sect_id': 28, 'key': '圣地', 'value': '北京'},
      {'id': 113, 'sect_id': 29, 'key': '修行方式', 'value': '内丹修炼、武术'},
      {'id': 114, 'sect_id': 29, 'key': '理念', 'value': '青城仙道、内外兼修'},
      {'id': 115, 'sect_id': 29, 'key': '经典', 'value': '《青城秘录》'},
      {'id': 116, 'sect_id': 29, 'key': '圣地', 'value': '青城山'},
    ];
    
    // 初始化派系代表人物
    _webSectRepresentatives = [
      // 早期道教
      {'id': 1, 'sect_id': 1, 'figure_name': '张道陵'},
      {'id': 2, 'sect_id': 1, 'figure_name': '张衡'},
      {'id': 3, 'sect_id': 1, 'figure_name': '张鲁'},
      {'id': 4, 'sect_id': 2, 'figure_name': '张角'},
      {'id': 5, 'sect_id': 2, 'figure_name': '于吉'},
      
      // 魏晋南北朝时期
      {'id': 6, 'sect_id': 3, 'figure_name': '魏华存'},
      {'id': 7, 'sect_id': 3, 'figure_name': '杨羲'},
      {'id': 8, 'sect_id': 3, 'figure_name': '许谧'},
      {'id': 9, 'sect_id': 3, 'figure_name': '陶弘景'},
      {'id': 10, 'sect_id': 4, 'figure_name': '葛玄'},
      {'id': 11, 'sect_id': 4, 'figure_name': '葛洪'},
      {'id': 12, 'sect_id': 4, 'figure_name': '陆修静'},
      {'id': 13, 'sect_id': 5, 'figure_name': '葛巢甫'},
      {'id': 14, 'sect_id': 6, 'figure_name': '尹喜'},
      {'id': 15, 'sect_id': 6, 'figure_name': '梁谌'},
      {'id': 16, 'sect_id': 7, 'figure_name': '陶弘景'},
      {'id': 17, 'sect_id': 7, 'figure_name': '王远知'},
      
      // 隋唐时期
      {'id': 18, 'sect_id': 8, 'figure_name': '张道陵'},
      {'id': 19, 'sect_id': 8, 'figure_name': '张衡'},
      {'id': 20, 'sect_id': 8, 'figure_name': '张鲁'},
      {'id': 21, 'sect_id': 9, 'figure_name': '钟离权'},
      {'id': 22, 'sect_id': 9, 'figure_name': '吕洞宾'},
      
      // 宋辽金时期
      {'id': 23, 'sect_id': 10, 'figure_name': '张伯端'},
      {'id': 24, 'sect_id': 10, 'figure_name': '石泰'},
      {'id': 25, 'sect_id': 10, 'figure_name': '薛道光'},
      {'id': 26, 'sect_id': 10, 'figure_name': '陈楠'},
      {'id': 27, 'sect_id': 10, 'figure_name': '白玉蟾'},
      {'id': 28, 'sect_id': 11, 'figure_name': '王重阳'},
      {'id': 29, 'sect_id': 11, 'figure_name': '丘处机'},
      {'id': 30, 'sect_id': 11, 'figure_name': '马钰'},
      {'id': 31, 'sect_id': 11, 'figure_name': '谭处端'},
      {'id': 32, 'sect_id': 11, 'figure_name': '刘处玄'},
      {'id': 33, 'sect_id': 11, 'figure_name': '王处一'},
      {'id': 34, 'sect_id': 11, 'figure_name': '郝大通'},
      {'id': 35, 'sect_id': 11, 'figure_name': '孙不二'},
      {'id': 36, 'sect_id': 12, 'figure_name': '萧抱珍'},
      {'id': 37, 'sect_id': 12, 'figure_name': '萧道熙'},
      {'id': 38, 'sect_id': 13, 'figure_name': '刘德仁'},
      {'id': 39, 'sect_id': 13, 'figure_name': '陈师正'},
      {'id': 40, 'sect_id': 14, 'figure_name': '许逊'},
      {'id': 41, 'sect_id': 14, 'figure_name': '刘玉'},
      {'id': 42, 'sect_id': 14, 'figure_name': '黄元吉'},
      {'id': 43, 'sect_id': 15, 'figure_name': '王文卿'},
      {'id': 44, 'sect_id': 15, 'figure_name': '林灵素'},
      {'id': 45, 'sect_id': 16, 'figure_name': '黄舜申'},
      {'id': 46, 'sect_id': 16, 'figure_name': '李少微'},
      {'id': 47, 'sect_id': 17, 'figure_name': '饶洞天'},
      {'id': 48, 'sect_id': 17, 'figure_name': '路时中'},
      
      // 元明清时期
      {'id': 49, 'sect_id': 18, 'figure_name': '丘处机'},
      {'id': 50, 'sect_id': 18, 'figure_name': '尹志平'},
      {'id': 51, 'sect_id': 18, 'figure_name': '李志常'},
      {'id': 52, 'sect_id': 19, 'figure_name': '马钰'},
      {'id': 53, 'sect_id': 19, 'figure_name': '马丹阳'},
      {'id': 54, 'sect_id': 20, 'figure_name': '谭处端'},
      {'id': 55, 'sect_id': 20, 'figure_name': '长真子'},
      {'id': 56, 'sect_id': 21, 'figure_name': '刘处玄'},
      {'id': 57, 'sect_id': 21, 'figure_name': '长生子'},
      {'id': 58, 'sect_id': 22, 'figure_name': '王处一'},
      {'id': 59, 'sect_id': 22, 'figure_name': '玉阳子'},
      {'id': 60, 'sect_id': 23, 'figure_name': '郝大通'},
      {'id': 61, 'sect_id': 23, 'figure_name': '太古子'},
      {'id': 62, 'sect_id': 24, 'figure_name': '孙不二'},
      {'id': 63, 'sect_id': 24, 'figure_name': '清静散人'},
      {'id': 64, 'sect_id': 25, 'figure_name': '张正常'},
      {'id': 65, 'sect_id': 25, 'figure_name': '张宇初'},
      {'id': 66, 'sect_id': 25, 'figure_name': '张继禹'},
      {'id': 67, 'sect_id': 26, 'figure_name': '张三丰'},
      {'id': 68, 'sect_id': 26, 'figure_name': '张全一'},
      {'id': 69, 'sect_id': 27, 'figure_name': '伍冲虚'},
      {'id': 70, 'sect_id': 27, 'figure_name': '柳华阳'},
      {'id': 71, 'sect_id': 28, 'figure_name': '赵避尘'},
      {'id': 72, 'sect_id': 28, 'figure_name': '千峰老人'},
      {'id': 73, 'sect_id': 29, 'figure_name': '杜光庭'},
      {'id': 74, 'sect_id': 29, 'figure_name': '陈清觉'},
      {'id': 75, 'sect_id': 29, 'figure_name': '刘沅'},
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
      // 先秦时期
      {
        'name': '老子',
        'era': '春秋',
        'era_order': 1,
        'description': '道家学派创始人，著有《道德经》',
        'bio': '老子，姓李名耳，字聃，春秋末期人。他是道家学派的创始人，被尊为道教始祖。老子主张无为而治，强调顺应自然，其思想对中国哲学产生了深远影响。',
        'coreThoughts': ['无为', '道法自然', '小国寡民', '柔弱胜刚强', '玄之又玄'],
        'works': ['道德经']
      },
      {
        'name': '文子',
        'era': '春秋',
        'era_order': 1,
        'description': '道家思想家，老子弟子',
        'bio': '文子，姓辛名钘，字文子，春秋时期宋国人，老子的弟子。著有《文子》，以"道生法"为核心，将《道德经》的"无为"转化为治国方略，主张"循道而治""以德辅法"，为汉初"黄老之治"提供理论支撑。',
        'coreThoughts': ['道生法', '循道而治', '以德辅法'],
        'works': ['文子']
      },
      {
        'name': '关尹子',
        'era': '春秋',
        'era_order': 1,
        'description': '道家思想家，文始派创始人',
        'bio': '关尹子，名喜，字公度，春秋时期函谷关令。他是老子的弟子，著有《关尹子》，主张"贵清""贵虚"，强调精神的自由和超越，是文始派的创始人。',
        'coreThoughts': ['贵清', '贵虚', '精神自由'],
        'works': ['关尹子']
      },
      {
        'name': '庄子',
        'era': '战国',
        'era_order': 2,
        'description': '道家代表人物，著有《庄子》',
        'bio': '庄子，名周，战国时期宋国人。他是道家学派的重要代表人物，继承和发展了老子的思想。庄子主张逍遥游，追求精神自由，其作品富有哲理和文学性。',
        'coreThoughts': ['逍遥游', '齐物论', '相对主义', '坐忘'],
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
        'name': '杨朱',
        'era': '战国',
        'era_order': 2,
        'description': '道家思想家，主张贵己',
        'bio': '杨朱，战国时期魏国人。他是道家学派的重要代表人物，主张"贵己""重生"，强调个人的生命价值和自由，对后世道教的个人修炼思想有重要影响。',
        'coreThoughts': ['贵己', '重生', '为我'],
        'works': ['杨朱篇']
      },
      
      // 秦汉时期
      {
        'name': '张道陵',
        'era': '东汉',
        'era_order': 3,
        'description': '道教创始人，五斗米道祖师',
        'bio': '张道陵，字辅汉，东汉时期沛国人。他在四川鹤鸣山创立五斗米道，被尊为"张天师"，是道教的创始人。他以《老子想尔注》将"道"神格化，确立"守戒积善""符箓治病"传教模式。',
        'coreThoughts': ['守戒积善', '符箓治病', '道即太上老君'],
        'works': ['老子想尔注']
      },
      {
        'name': '张衡',
        'era': '东汉',
        'era_order': 3,
        'description': '五斗米道第二代天师',
        'bio': '张衡，字灵真，张道陵之子。他继承父业，继续传播五斗米道，是五斗米道的第二代天师。',
        'coreThoughts': ['守戒积善', '符箓治病'],
        'works': []
      },
      {
        'name': '张鲁',
        'era': '东汉',
        'era_order': 3,
        'description': '五斗米道第三代天师',
        'bio': '张鲁，字公祺，张衡之子。他在汉中建立政教合一政权，推行"宽刑、义舍、禁酒"政策，使汉中成为乱世中的稳定区域，扩大了五斗米道的影响力。',
        'coreThoughts': ['守戒积善', '符箓治病', '政教合一'],
        'works': []
      },
      {
        'name': '张角',
        'era': '东汉',
        'era_order': 3,
        'description': '太平道创始人',
        'bio': '张角，东汉末年钜鹿人。他以《太平经》为理论基础，创立太平道，提出"苍天已死，黄天当立"口号，组织黄巾起义，扩大了道教在底层社会的影响力。',
        'coreThoughts': ['太平世', '积善成仙', '财物共养'],
        'works': ['太平经']
      },
      {
        'name': '于吉',
        'era': '东汉',
        'era_order': 3,
        'description': '太平道思想传播者',
        'bio': '于吉，东汉末年琅琊人。他整理编纂《太平经》，融合道家无为、儒家伦理与民间信仰，主张"太平世"理想，强调"积善成仙""财物共养"。',
        'coreThoughts': ['太平世', '积善成仙', '财物共养'],
        'works': ['太平经']
      },
      {
        'name': '魏伯阳',
        'era': '东汉',
        'era_order': 3,
        'description': '丹道理论奠基人',
        'bio': '魏伯阳，东汉末年会稽上虞人。他著有《周易参同契》，融合《周易》阴阳学说、黄老思想与炼丹术，首次系统阐述"内丹"与"外丹"理论，为后世丹道学提供核心框架。',
        'coreThoughts': ['内丹', '外丹', '周易参同'],
        'works': ['周易参同契']
      },
      
      // 魏晋南北朝时期
      {
        'name': '葛玄',
        'era': '三国',
        'era_order': 4,
        'description': '灵宝派祖师',
        'bio': '葛玄，字孝先，三国时期吴国人。他传习"灵宝经法"，擅长符箓驱邪、炼丹养生，整理道教法术文献，是灵宝派的祖师。',
        'coreThoughts': ['灵宝经法', '符箓驱邪', '炼丹养生'],
        'works': []
      },
      {
        'name': '葛洪',
        'era': '东晋',
        'era_order': 4,
        'description': '道教理论家、炼丹家',
        'bio': '葛洪，字稚川，东晋时期丹阳句容人。他著有《抱朴子》，系统阐述金丹修炼理论，为丹道奠定基础，同时也是著名的医药学家。',
        'coreThoughts': ['金丹修炼', '神仙方术', '医药养生'],
        'works': ['抱朴子', '肘后备急方']
      },
      {
        'name': '魏华存',
        'era': '东晋',
        'era_order': 4,
        'description': '上清派祖师',
        'bio': '魏华存，字贤安，东晋时期任城人。她是上清派的创始人，传《上清经》，主张存思守一的修炼方法，被尊为"紫虚元君"。',
        'coreThoughts': ['存思守一', '上清经法'],
        'works': ['黄庭经']
      },
      {
        'name': '杨羲',
        'era': '东晋',
        'era_order': 4,
        'description': '上清派重要传人',
        'bio': '杨羲，东晋时期吴国人。他是上清派的重要传人，传习《上清经》，整理上清派经典，对上清派的发展做出了重要贡献。',
        'coreThoughts': ['存思守一', '上清经法'],
        'works': []
      },
      {
        'name': '许谧',
        'era': '东晋',
        'era_order': 4,
        'description': '上清派重要传人',
        'bio': '许谧，东晋时期丹阳句容人。他是上清派的重要传人，与杨羲一起整理上清派经典，对上清派的发展做出了重要贡献。',
        'coreThoughts': ['存思守一', '上清经法'],
        'works': []
      },
      {
        'name': '陶弘景',
        'era': '南朝',
        'era_order': 4,
        'description': '茅山宗创始人',
        'bio': '陶弘景，字通明，南朝时期丹阳秣陵人。他整理上清派典籍，构建道教神仙体系，撰写《真灵位业图》，使茅山成为道教上清派的中心，被尊为"华阳真人"。',
        'coreThoughts': ['神仙体系', '三教合一', '内丹修炼'],
        'works': ['真诰', '登真隐诀', '真灵位业图']
      },
      {
        'name': '寇谦之',
        'era': '北魏',
        'era_order': 4,
        'description': '新天师道创始人',
        'bio': '寇谦之，字辅真，北魏时期冯翊万年人。他改革天师道，清整戒律，创立新天师道，获得北魏统治者的正式承认，成为官方宗教。',
        'coreThoughts': ['清整戒律', '新天师道'],
        'works': []
      },
      {
        'name': '陆修静',
        'era': '南朝',
        'era_order': 4,
        'description': '道教经典整理者',
        'bio': '陆修静，字元德，南朝时期吴兴东迁人。他整理道教经典，总括三洞，撰写《三洞经书目录》，建立了完善的经典教义与科戒仪式，极大地推进了灵宝派的发展。',
        'coreThoughts': ['三洞经书', '科戒仪式'],
        'works': ['三洞经书目录']
      },
      
      // 隋唐时期
      {
        'name': '孙思邈',
        'era': '唐代',
        'era_order': 5,
        'description': '道医、丹道大师',
        'bio': '孙思邈，唐代京兆华原人。他融道医与丹道，著《千金方》，被誉为"药王"，对道教医学的发展做出了重要贡献。',
        'coreThoughts': ['道医结合', '养生保健'],
        'works': ['千金方', '千金翼方']
      },
      {
        'name': '司马承祯',
        'era': '唐代',
        'era_order': 5,
        'description': '上清派传人',
        'bio': '司马承祯，字子微，唐代河内温人。他弘扬上清派修炼法门，著《坐忘论》，主张"坐忘""主静"的修炼方法，对道教内丹学的发展做出了重要贡献。',
        'coreThoughts': ['坐忘', '主静'],
        'works': ['坐忘论']
      },
      {
        'name': '吴筠',
        'era': '唐代',
        'era_order': 5,
        'description': '上清派传人',
        'bio': '吴筠，字贞节，唐代华州华阴人。他弘扬上清派修炼法门，著《玄纲论》，主张"守静""坐忘"的修炼方法，对道教内丹学的发展做出了重要贡献。',
        'coreThoughts': ['守静', '坐忘'],
        'works': ['玄纲论']
      },
      {
        'name': '王玄甫',
        'era': '唐代',
        'era_order': 5,
        'description': '少阳派始祖',
        'bio': '王玄甫，唐代人，号东华帝君。他传承金丹道脉，为少阳派始祖，开启钟吕金丹道传承，奠定后世丹道主流基础。',
        'coreThoughts': ['金丹道', '内丹修炼'],
        'works': []
      },
      {
        'name': '钟离权',
        'era': '唐代',
        'era_order': 5,
        'description': '少阳派传人',
        'bio': '钟离权，唐代咸阳人，号正阳子。他传承金丹道脉，与吕洞宾一起创立钟吕金丹道，对后世丹道学的发展做出了重要贡献。',
        'coreThoughts': ['金丹道', '性命双修'],
        'works': []
      },
      {
        'name': '吕洞宾',
        'era': '唐代',
        'era_order': 5,
        'description': '纯阳派创始人',
        'bio': '吕洞宾，唐代河中府永乐县人，号纯阳子。他传承金丹道脉，创立纯阳派，主张性命双修，对后世丹道学的发展做出了重要贡献。',
        'coreThoughts': ['纯阳道', '性命双修'],
        'works': []
      },
      
      // 宋辽金时期
      {
        'name': '陈抟',
        'era': '北宋',
        'era_order': 6,
        'description': '文始派传人',
        'bio': '陈抟，字图南，北宋时期亳州真源人。他传承文始派脉，融文始、少阳二派精髓，著《指玄篇》，影响张三丰丹法，被尊为"希夷先生"。',
        'coreThoughts': ['指玄', '内丹修炼'],
        'works': ['指玄篇', '无极图']
      },
      {
        'name': '张伯端',
        'era': '北宋',
        'era_order': 6,
        'description': '南宗创始人',
        'bio': '张伯端，字平叔，北宋时期天台人。他创立金丹派南宗，主先命后性，著《悟真篇》，对后世丹道学的发展做出了重要贡献。',
        'coreThoughts': ['先命后性', '内丹修炼'],
        'works': ['悟真篇']
      },
      {
        'name': '王重阳',
        'era': '金代',
        'era_order': 6,
        'description': '全真道创始人',
        'bio': '王重阳，字知明，金代咸阳人。他创立全真道，主张三教合一、先性后命，传北七真，对道教的发展做出了重要贡献。',
        'coreThoughts': ['三教合一', '先性后命', '出家清修'],
        'works': ['重阳立教十五论']
      },
      {
        'name': '丘处机',
        'era': '金代',
        'era_order': 6,
        'description': '龙门派创始人',
        'bio': '丘处机，字通密，金代登州栖霞人。他是全真七子之一，创立龙门派，主张"功行双全"，对全真道的发展做出了重要贡献。',
        'coreThoughts': ['功行双全', '龙门心法'],
        'works': ['大丹直指']
      },
      {
        'name': '马钰',
        'era': '金代',
        'era_order': 6,
        'description': '遇仙派创始人',
        'bio': '马钰，字玄宝，金代宁海人。他是全真七子之一，创立遇仙派，主张"清净无为"，对全真道的发展做出了重要贡献。',
        'coreThoughts': ['清净无为'],
        'works': []
      },
      {
        'name': '谭处端',
        'era': '金代',
        'era_order': 6,
        'description': '南无派创始人',
        'bio': '谭处端，字通正，金代宁海人。他是全真七子之一，创立南无派，主张"清静无为"，对全真道的发展做出了重要贡献。',
        'coreThoughts': ['清静无为'],
        'works': []
      },
      {
        'name': '刘处玄',
        'era': '金代',
        'era_order': 6,
        'description': '随山派创始人',
        'bio': '刘处玄，字通妙，金代东莱人。他是全真七子之一，创立随山派，主张"无为而治"，对全真道的发展做出了重要贡献。',
        'coreThoughts': ['无为而治'],
        'works': []
      },
      {
        'name': '王处一',
        'era': '金代',
        'era_order': 6,
        'description': '嵛山派创始人',
        'bio': '王处一，字通叟，金代宁海人。他是全真七子之一，创立嵛山派，主张"清静无为"，对全真道的发展做出了重要贡献。',
        'coreThoughts': ['清静无为'],
        'works': []
      },
      {
        'name': '郝大通',
        'era': '金代',
        'era_order': 6,
        'description': '华山派创始人',
        'bio': '郝大通，字太古，金代宁海人。他是全真七子之一，创立华山派，主张"清静无为"，对全真道的发展做出了重要贡献。',
        'coreThoughts': ['清静无为'],
        'works': []
      },
      {
        'name': '孙不二',
        'era': '金代',
        'era_order': 6,
        'description': '清静派创始人',
        'bio': '孙不二，号清静散人，金代宁海人。她是全真七子之一，创立清静派，主张"清静无为"，是唯一的女性创始人。',
        'coreThoughts': ['清静无为'],
        'works': []
      },
      {
        'name': '白玉蟾',
        'era': '南宋',
        'era_order': 6,
        'description': '南宗重要传人',
        'bio': '白玉蟾，字如晦，南宋时期琼州人。他是金丹派南宗的重要传人，主张性命双修，对南宗的发展做出了重要贡献。',
        'coreThoughts': ['性命双修', '内丹修炼'],
        'works': ['海琼玉蟾先生文集']
      },
      {
        'name': '萧抱珍',
        'era': '金代',
        'era_order': 6,
        'description': '太一道创始人',
        'bio': '萧抱珍，金代卫州人。他创立太一道，重符箓斋醮，规定道士必须出家，七传以后逐渐与正一道相融合。',
        'coreThoughts': ['太一三元法箓', '符箓斋醮'],
        'works': []
      },
      {
        'name': '刘德仁',
        'era': '金代',
        'era_order': 6,
        'description': '真大道创始人',
        'bio': '刘德仁，金代沧州乐陵人。他创立真大道，以清心寡欲、谦卑自守、力作而食为教旨，元以后逐渐衰落并消失。',
        'coreThoughts': ['清心寡欲', '谦卑自守', '力作而食'],
        'works': []
      },
      
      // 元明清时期
      {
        'name': '张三丰',
        'era': '明代',
        'era_order': 7,
        'description': '三丰派创始人',
        'bio': '张三丰，明代辽东懿州人。他创立三丰派，融文始、少阳二派，主张性命双修，对道教的发展做出了重要贡献。',
        'coreThoughts': ['性命双修', '三教合一', '内丹修炼'],
        'works': ['张三丰全集']
      },
      {
        'name': '张正常',
        'era': '明代',
        'era_order': 7,
        'description': '正一道天师',
        'bio': '张正常，明代龙虎山道士。他是正一道的天师，受朝廷认可，延续天师道的传承。',
        'coreThoughts': ['正一道规'],
        'works': []
      },
      {
        'name': '张宇初',
        'era': '明代',
        'era_order': 7,
        'description': '正一道天师',
        'bio': '张宇初，明代龙虎山道士。他是正一道的天师，著《道门十规》，对正一道的发展做出了重要贡献。',
        'coreThoughts': ['道门十规', '正一道规'],
        'works': ['道门十规']
      },
      {
        'name': '伍冲虚',
        'era': '明代',
        'era_order': 7,
        'description': '伍柳派创始人',
        'bio': '伍冲虚，明代江西南昌人。他创立伍柳派，简化丹道修炼法门，对丹道学的发展做出了重要贡献。',
        'coreThoughts': ['内丹简化'],
        'works': ['伍柳仙宗']
      },
      {
        'name': '柳华阳',
        'era': '清代',
        'era_order': 8,
        'description': '伍柳派创始人',
        'bio': '柳华阳，清代江西南昌人。他与伍冲虚一起创立伍柳派，简化丹道修炼法门，对丹道学的发展做出了重要贡献。',
        'coreThoughts': ['内丹简化'],
        'works': ['伍柳仙宗']
      },
      {
        'name': '赵避尘',
        'era': '清代',
        'era_order': 8,
        'description': '千峰派创始人',
        'bio': '赵避尘，清代北京人。他创立千峰派，改丹道单传为普传，对丹道学的发展做出了重要贡献。',
        'coreThoughts': ['丹道普传', '内丹修炼'],
        'works': ['性命法诀明指']
      },
      {
        'name': '张恩溥',
        'era': '清代',
        'era_order': 8,
        'description': '正一道天师',
        'bio': '张恩溥，清代龙虎山道士。他是正一道的天师，第六十三代天师，赴台延续道统。',
        'coreThoughts': ['正一道规'],
        'works': []
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
      // 早期道教
      {
        'name': '五斗米道',
        'dynasty': '东汉',
        'practice': '符箓、斋醮',
        'description': '五斗米道是道教的早期派别之一，由张道陵创立于东汉末年。因入道者需缴纳五斗米而得名，后发展为正一道。',
        'info': {
          '修行方式': '符箓治病、斋醮科仪、守戒积善',
          '理念': '道即太上老君、长生久视、济世度人',
          '经典': '《老子想尔注》、《道德经》',
          '圣地': '龙虎山、鹤鸣山'
        },
        'representatives': ['张道陵', '张衡', '张鲁']
      },
      {
        'name': '太平道',
        'dynasty': '东汉',
        'practice': '符箓、祝祷',
        'description': '太平道是道教的早期派别之一，由张角创立于东汉末年。以《太平经》为主要经典，发动了黄巾起义。',
        'info': {
          '修行方式': '符箓治病、祝祷祈福、积善成仙',
          '理念': '太平世、财物共养、天人合一',
          '经典': '《太平经》',
          '圣地': '钜鹿'
        },
        'representatives': ['张角', '于吉']
      },
      
      // 魏晋南北朝时期
      {
        'name': '上清派',
        'dynasty': '东晋',
        'practice': '存思、服气',
        'description': '上清派是道教的重要派别之一，以《上清经》为主要经典，强调存思守一的修炼方法。由魏华存创立。',
        'info': {
          '修行方式': '存思守一、服气辟谷、内丹修炼',
          '理念': '上清道妙、存思成仙、重个人修炼',
          '经典': '《上清大洞真经》、《黄庭经》',
          '圣地': '茅山、天台山'
        },
        'representatives': ['魏华存', '杨羲', '许谧']
      },
      {
        'name': '灵宝派',
        'dynasty': '东晋',
        'practice': '斋醮、诵经',
        'description': '灵宝派是道教的重要派别之一，以《灵宝经》为主要经典，强调斋醮科仪的重要性。由葛玄创立。',
        'info': {
          '修行方式': '斋醮科仪、诵经祈福、超度亡灵',
          '理念': '积累功德、超度亡灵、仙道合一',
          '经典': '《灵宝无量度人上品妙经》',
          '圣地': '阁皂山'
        },
        'representatives': ['葛玄', '葛洪', '陆修静']
      },
      {
        'name': '三皇派',
        'dynasty': '东晋',
        'practice': '符箓、辟谷',
        'description': '三皇派是道教的重要派别之一，以《三皇经》为主要经典，注重符箓法术和辟谷修炼。',
        'info': {
          '修行方式': '符箓驱邪、辟谷养生、存思修炼',
          '理念': '三皇之道、长生久视、济世度人',
          '经典': '《三皇经》',
          '圣地': '罗浮山'
        },
        'representatives': ['鲍靓', '葛洪']
      },
      {
        'name': '楼观道',
        'dynasty': '南北朝',
        'practice': '诵经、炼丹',
        'description': '楼观道是道教的重要派别之一，以陕西楼观台为中心，注重诵经和炼丹。',
        'info': {
          '修行方式': '诵经祈福、炼丹养生、符箓驱邪',
          '理念': '老子之道、长生久视、济世度人',
          '经典': '《道德经》、《西升经》',
          '圣地': '楼观台'
        },
        'representatives': ['尹喜', '梁谌']
      },
      {
        'name': '茅山派',
        'dynasty': '南朝',
        'practice': '符箓、内丹',
        'description': '茅山派是道教的重要派别之一，以茅山为圣地，注重符箓法术和内丹修炼。由陶弘景发展壮大。',
        'info': {
          '修行方式': '符箓驱邪、内丹修炼、斋醮科仪',
          '理念': '济世度人、修道成仙、三教合一',
          '经典': '《真诰》、《登真隐诀》',
          '圣地': '茅山'
        },
        'representatives': ['陶弘景', '司马承祯', '吴筠']
      },
      
      // 隋唐时期
      {
        'name': '天师道',
        'dynasty': '隋唐',
        'practice': '符箓、斋醮',
        'description': '天师道是道教的重要派别之一，由张道陵后裔传承，注重符箓法术和斋醮科仪。',
        'info': {
          '修行方式': '符箓驱邪、斋醮科仪、守戒积善',
          '理念': '道即太上老君、长生久视、济世度人',
          '经典': '《道德经》、《正一经》',
          '圣地': '龙虎山'
        },
        'representatives': ['张道陵', '张衡', '张鲁']
      },
      {
        'name': '钟吕金丹派',
        'dynasty': '唐代',
        'practice': '内丹',
        'description': '钟吕金丹派是道教的重要派别之一，由钟离权和吕洞宾创立，注重内丹修炼。',
        'info': {
          '修行方式': '内丹修炼、性命双修、服气辟谷',
          '理念': '金丹大道、性命双修、长生久视',
          '经典': '《钟吕传道集》、《灵宝毕法》',
          '圣地': '终南山'
        },
        'representatives': ['钟离权', '吕洞宾', '刘海蟾']
      },
      
      // 宋辽金时期
      {
        'name': '金丹派南宗',
        'dynasty': '北宋',
        'practice': '内丹',
        'description': '金丹派南宗是道教的重要派别之一，由张伯端创立，主张先命后性的内丹修炼方法。',
        'info': {
          '修行方式': '内丹修炼、先命后性、性命双修',
          '理念': '金丹大道、性命双修、长生久视',
          '经典': '《悟真篇》',
          '圣地': '天台'
        },
        'representatives': ['张伯端', '石泰', '薛道光']
      },
      {
        'name': '全真道',
        'dynasty': '金代',
        'practice': '内丹、清修',
        'description': '全真道是道教的重要派别之一，由王重阳创立，主张三教合一、先性后命的内丹修炼方法。',
        'info': {
          '修行方式': '内丹修炼、清修戒律、三教合一',
          '理念': '全真而仙、三教合一、性命双修',
          '经典': '《道德经》、《清静经》、《重阳立教十五论》',
          '圣地': '终南山、昆嵛山'
        },
        'representatives': ['王重阳', '丘处机', '马钰']
      },
      {
        'name': '太一道',
        'dynasty': '金代',
        'practice': '符箓、斋醮',
        'description': '太一道是道教的重要派别之一，由萧抱珍创立，注重符箓斋醮，规定道士必须出家。',
        'info': {
          '修行方式': '符箓斋醮、诵经祈福、守戒积善',
          '理念': '太一三元法箓、驱邪避凶、祈福禳灾',
          '经典': '《太一三元法箓》',
          '圣地': '卫州'
        },
        'representatives': ['萧抱珍', '萧道熙', '萧志冲']
      },
      {
        'name': '真大道',
        'dynasty': '金代',
        'practice': '清修、慈善',
        'description': '真大道是道教的重要派别之一，由刘德仁创立，以清心寡欲、谦卑自守、力作而食为教旨。',
        'info': {
          '修行方式': '清心寡欲、谦卑自守、力作而食',
          '理念': '大道无为、济世度人、慈善为本',
          '经典': '《真大道教规》',
          '圣地': '沧州'
        },
        'representatives': ['刘德仁', '郦希成', '张清志']
      },
      {
        'name': '净明道',
        'dynasty': '南宋',
        'practice': '忠孝、内丹',
        'description': '净明道是道教的重要派别之一，强调忠孝伦理，融合儒家思想与道教修炼。由许逊创立。',
        'info': {
          '修行方式': '忠孝伦理、内丹修炼、积善立功',
          '理念': '净明忠孝、仙道合一、济世度人',
          '经典': '《净明忠孝全书》',
          '圣地': '西山万寿宫'
        },
        'representatives': ['许逊', '刘玉', '黄元吉']
      },
      {
        'name': '神霄派',
        'dynasty': '北宋',
        'practice': '符箓、雷法',
        'description': '神霄派是道教的重要派别之一，注重符箓法术和雷法，强调通过法术来达到修仙的目的。',
        'info': {
          '修行方式': '符箓雷法、斋醮科仪、存思修炼',
          '理念': '雷法驱邪、祈福禳灾、修道成仙',
          '经典': '《高上神霄玉清真王紫书大法》',
          '圣地': '龙虎山'
        },
        'representatives': ['王文卿', '林灵素', '张虚靖']
      },
      {
        'name': '清微派',
        'dynasty': '南宋',
        'practice': '符箓、雷法',
        'description': '清微派是道教的重要派别之一，注重符箓法术和雷法，强调通过法术来达到修仙的目的。',
        'info': {
          '修行方式': '符箓雷法、斋醮科仪、存思修炼',
          '理念': '清微道妙、雷法驱邪、修道成仙',
          '经典': '《清微元降大法》',
          '圣地': '青城山'
        },
        'representatives': ['黄舜申', '李少微', '张道贵']
      },
      {
        'name': '天心派',
        'dynasty': '北宋',
        'practice': '符箓、雷法',
        'description': '天心派是道教的重要派别之一，注重符箓法术和雷法，强调通过法术来达到修仙的目的。',
        'info': {
          '修行方式': '符箓雷法、斋醮科仪、存思修炼',
          '理念': '天心正法、驱邪避凶、修道成仙',
          '经典': '《天心正法》',
          '圣地': '龙虎山'
        },
        'representatives': ['饶洞天', '路时中', '雷时中']
      },
      
      // 元明清时期
      {
        'name': '龙门派',
        'dynasty': '元代',
        'practice': '内丹、清修',
        'description': '龙门派是全真派的重要支派，由丘处机创立，强调严格的清修戒律和内丹修炼。',
        'info': {
          '修行方式': '内丹修炼、清修戒律、功行双全',
          '理念': '龙门心法、全真传承、修道成仙',
          '经典': '《邱祖全书》、《龙门心法》',
          '圣地': '白云观、崂山'
        },
        'representatives': ['丘处机', '尹志平', '李志常']
      },
      {
        'name': '遇仙派',
        'dynasty': '元代',
        'practice': '内丹、清修',
        'description': '遇仙派是全真派的重要支派，由马钰创立，强调清净无为的修炼方法。',
        'info': {
          '修行方式': '内丹修炼、清修戒律、清净无为',
          '理念': '遇仙得道、清净无为、修道成仙',
          '经典': '《洞玄金玉集》',
          '圣地': '宁海'
        },
        'representatives': ['马钰', '马丹阳', '马钰之妻孙不二']
      },
      {
        'name': '南无派',
        'dynasty': '元代',
        'practice': '内丹、清修',
        'description': '南无派是全真派的重要支派，由谭处端创立，强调清静无为的修炼方法。',
        'info': {
          '修行方式': '内丹修炼、清修戒律、清静无为',
          '理念': '南无大道、清静无为、修道成仙',
          '经典': '《水云集》',
          '圣地': '宁海'
        },
        'representatives': ['谭处端', '谭长真']
      },
      {
        'name': '随山派',
        'dynasty': '元代',
        'practice': '内丹、清修',
        'description': '随山派是全真派的重要支派，由刘处玄创立，强调无为而治的修炼方法。',
        'info': {
          '修行方式': '内丹修炼、清修戒律、无为而治',
          '理念': '随山修道、无为而治、修道成仙',
          '经典': '《仙乐集》',
          '圣地': '东莱'
        },
        'representatives': ['刘处玄', '刘长生']
      },
      {
        'name': '嵛山派',
        'dynasty': '元代',
        'practice': '内丹、清修',
        'description': '嵛山派是全真派的重要支派，由王处一创立，强调清静无为的修炼方法。',
        'info': {
          '修行方式': '内丹修炼、清修戒律、清静无为',
          '理念': '嵛山修道、清静无为、修道成仙',
          '经典': '《云光集》',
          '圣地': '昆嵛山'
        },
        'representatives': ['王处一', '王玉阳']
      },
      {
        'name': '华山派',
        'dynasty': '元代',
        'practice': '内丹、清修',
        'description': '华山派是全真派的重要支派，由郝大通创立，强调清静无为的修炼方法。',
        'info': {
          '修行方式': '内丹修炼、清修戒律、清静无为',
          '理念': '华山修道、清静无为、修道成仙',
          '经典': '《太古集》',
          '圣地': '华山'
        },
        'representatives': ['郝大通', '郝太古']
      },
      {
        'name': '清静派',
        'dynasty': '元代',
        'practice': '内丹、清修',
        'description': '清静派是全真派的重要支派，由孙不二创立，强调清静无为的修炼方法，是唯一的女性创始人。',
        'info': {
          '修行方式': '内丹修炼、清修戒律、清静无为',
          '理念': '清静修道、清静无为、修道成仙',
          '经典': '《孙不二元君法语》',
          '圣地': '宁海'
        },
        'representatives': ['孙不二', '孙清静']
      },
      {
        'name': '正一道',
        'dynasty': '明代',
        'practice': '符箓、斋醮',
        'description': '正一道是道教的主要派别之一，由张道陵后裔传承，注重符箓法术和斋醮科仪。',
        'info': {
          '修行方式': '符箓驱邪、斋醮科仪、守戒积善',
          '理念': '道即太上老君、长生久视、济世度人',
          '经典': '《道德经》、《正一经》、《正统道藏》',
          '圣地': '龙虎山'
        },
        'representatives': ['张正常', '张宇初', '张继禹']
      },
      {
        'name': '三丰派',
        'dynasty': '明代',
        'practice': '内丹、武术',
        'description': '三丰派是道教的重要派别之一，由张三丰创立，融合文始、少阳二派，主张性命双修。',
        'info': {
          '修行方式': '内丹修炼、武术、性命双修',
          '理念': '三教合一、性命双修、修道成仙',
          '经典': '《张三丰全集》',
          '圣地': '武当山'
        },
        'representatives': ['张三丰', '张邋遢']
      },
      {
        'name': '伍柳派',
        'dynasty': '清代',
        'practice': '内丹',
        'description': '伍柳派是道教的重要派别之一，由伍冲虚和柳华阳创立，简化丹道修炼法门。',
        'info': {
          '修行方式': '内丹修炼、性命双修、简化丹法',
          '理念': '内丹简化、性命双修、修道成仙',
          '经典': '《伍柳仙宗》',
          '圣地': '江西南昌'
        },
        'representatives': ['伍冲虚', '柳华阳']
      },
      {
        'name': '千峰派',
        'dynasty': '清代',
        'practice': '内丹',
        'description': '千峰派是道教的重要派别之一，由赵避尘创立，改丹道单传为普传。',
        'info': {
          '修行方式': '内丹修炼、性命双修、丹道普传',
          '理念': '丹道普传、性命双修、修道成仙',
          '经典': '《性命法诀明指》',
          '圣地': '北京'
        },
        'representatives': ['赵避尘', '赵千峰']
      },
      {
        'name': '青城派',
        'dynasty': '清代',
        'practice': '内丹、武术',
        'description': '青城派是道教的重要派别之一，以青城山为圣地，注重内丹修炼和武术。',
        'info': {
          '修行方式': '内丹修炼、武术、内外兼修',
          '理念': '青城仙道、内外兼修、修道成仙',
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
      if (!_webDataInitialized) {
        _initializeWebData();
      }
      final originalFigure = _webFigures.firstWhere((f) => f['name'] == name, orElse: () => {});
      if (originalFigure.isEmpty) return null;
      
      // 创建可修改的副本
      final figure = Map<String, dynamic>.from(originalFigure);
      
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
    
    final originalFigure = result.first;
    final figure = Map<String, dynamic>.from(originalFigure);
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
      if (!_webDataInitialized) {
        _initializeWebData();
      }
      final figures = _webFigures.map((f) => Map<String, dynamic>.from(f)).toList();
      
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
    final originalFigures = await db.query('figures', orderBy: 'era_order ASC');
    final figures = originalFigures.map((f) => Map<String, dynamic>.from(f)).toList();
    
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
      final existingIndex = _webFigures.indexWhere((f) => f['name'] == name);
      int figureId;
      
      if (existingIndex >= 0) {
        // 更新现有人物
        final existingFigure = _webFigures[existingIndex];
        final updatedFigure = Map<String, dynamic>.from(existingFigure);
        updatedFigure['bio'] = bio;
        _webFigures[existingIndex] = updatedFigure;
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
      if (!_webDataInitialized) {
        _initializeWebData();
      }
      final sects = _webSects.map((s) => Map<String, dynamic>.from(s)).toList();
      
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
    final originalSects = await db.query('sects', orderBy: 'id ASC');
    final sects = originalSects.map((s) => Map<String, dynamic>.from(s)).toList();
    
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
      if (!_webDataInitialized) {
        _initializeWebData();
      }
      final originalSect = _webSects.firstWhere((s) => s['id'] == id, orElse: () => {});
      if (originalSect.isEmpty) return null;
      
      // 创建可修改的副本
      final sect = Map<String, dynamic>.from(originalSect);
      
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
    
    final originalSect = result.first;
    final sect = Map<String, dynamic>.from(originalSect);
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
