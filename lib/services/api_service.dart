import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://192.168.1.7:3000';

  static Future<List<Map<String, dynamic>>?> fetchFigures({String? keyword}) async {
    try {
      String url = '$_baseUrl/figures';
      if (keyword != null && keyword.isNotEmpty) {
        url += '?keyword=${Uri.encodeComponent(keyword)}';
      }
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      } else {
        print('获取人物列表失败: ${response.body}');
      }
    } catch (e) {
      print('获取人物列表异常: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> fetchFigureById(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/figures/$id'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Map<String, dynamic>.from(data['data']);
        }
      } else {
        print('获取人物详情失败: ${response.body}');
      }
    } catch (e) {
      print('获取人物详情异常: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> fetchFigureByName(String name) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/figures/name/${Uri.encodeComponent(name)}'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Map<String, dynamic>.from(data['data']);
        }
      } else {
        print('获取人物详情失败: ${response.body}');
      }
    } catch (e) {
      print('获取人物详情异常: $e');
    }
    return null;
  }

  static Future<bool> createFigure(Map<String, dynamic> figureData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/figures'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(figureData),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        print('创建人物失败: ${response.body}');
      }
    } catch (e) {
      print('创建人物异常: $e');
    }
    return false;
  }

  static Future<bool> updateFigure(String id, Map<String, dynamic> figureData) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/figures/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(figureData),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        print('更新人物失败: ${response.body}');
      }
    } catch (e) {
      print('更新人物异常: $e');
    }
    return false;
  }

  static Future<bool> deleteFigure(String id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/figures/$id'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        print('删除人物失败: ${response.body}');
      }
    } catch (e) {
      print('删除人物异常: $e');
    }
    return false;
  }

  static Future<List<Map<String, dynamic>>?> fetchSects({String? keyword, String? dynasty}) async {
    try {
      String url = '$_baseUrl/sects';
      List<String> params = [];
      if (keyword != null && keyword.isNotEmpty) {
        params.add('keyword=${Uri.encodeComponent(keyword)}');
      }
      if (dynasty != null && dynasty.isNotEmpty) {
        params.add('dynasty=${Uri.encodeComponent(dynasty)}');
      }
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      } else {
        print('获取派系列表失败: ${response.body}');
      }
    } catch (e) {
      print('获取派系列表异常: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> fetchSectById(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/sects/$id'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Map<String, dynamic>.from(data['data']);
        }
      } else {
        print('获取派系详情失败: ${response.body}');
      }
    } catch (e) {
      print('获取派系详情异常: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> fetchSectByName(String name) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/sects/name/${Uri.encodeComponent(name)}'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Map<String, dynamic>.from(data['data']);
        }
      } else {
        print('获取派系详情失败: ${response.body}');
      }
    } catch (e) {
      print('获取派系详情异常: $e');
    }
    return null;
  }

  static Future<bool> createSect(Map<String, dynamic> sectData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sects'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(sectData),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        print('创建派系失败: ${response.body}');
      }
    } catch (e) {
      print('创建派系异常: $e');
    }
    return false;
  }

  static Future<bool> updateSect(String id, Map<String, dynamic> sectData) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/sects/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(sectData),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        print('更新派系失败: ${response.body}');
      }
    } catch (e) {
      print('更新派系异常: $e');
    }
    return false;
  }

  static Future<bool> deleteSect(String id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/sects/$id'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        print('删除派系失败: ${response.body}');
      }
    } catch (e) {
      print('删除派系异常: $e');
    }
    return false;
  }

  static Future<List<Map<String, dynamic>>?> fetchThoughtConcepts({String? keyword}) async {
    try {
      String url = '$_baseUrl/thought_concepts';
      if (keyword != null && keyword.isNotEmpty) {
        url += '?keyword=${Uri.encodeComponent(keyword)}';
      }
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      } else {
        print('获取思想概念列表失败: ${response.body}');
      }
    } catch (e) {
      print('获取思想概念列表异常: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> fetchThoughtConceptById(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/thought_concepts/$id'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Map<String, dynamic>.from(data['data']);
        }
      } else {
        print('获取思想概念详情失败: ${response.body}');
      }
    } catch (e) {
      print('获取思想概念详情异常: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> fetchThoughtConceptByName(String name) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/thought_concepts/name/${Uri.encodeComponent(name)}'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Map<String, dynamic>.from(data['data']);
        }
      } else {
        print('获取思想概念详情失败: ${response.body}');
      }
    } catch (e) {
      print('获取思想概念详情异常: $e');
    }
    return null;
  }

  static Future<bool> createThoughtConcept(Map<String, dynamic> conceptData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/thought_concepts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(conceptData),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        print('创建思想概念失败: ${response.body}');
      }
    } catch (e) {
      print('创建思想概念异常: $e');
    }
    return false;
  }

  static Future<bool> updateThoughtConcept(String id, Map<String, dynamic> conceptData) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/thought_concepts/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(conceptData),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        print('更新思想概念失败: ${response.body}');
      }
    } catch (e) {
      print('更新思想概念异常: $e');
    }
    return false;
  }

  static Future<bool> deleteThoughtConcept(String id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/thought_concepts/$id'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        print('删除思想概念失败: ${response.body}');
      }
    } catch (e) {
      print('删除思想概念异常: $e');
    }
    return false;
  }
}