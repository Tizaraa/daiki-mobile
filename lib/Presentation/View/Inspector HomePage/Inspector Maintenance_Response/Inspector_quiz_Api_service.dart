import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:redis/redis.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../../Core/Utils/api_service.dart';
import 'Inspector_quiz_model.dart';

class ApiService {
  final RedisConnection redisConnection;
  Command? redisCommand;
  final String redisPassword = 'password';
  bool _isRedisReadOnly = false;

  ApiService() : redisConnection = RedisConnection() {
    _initializeRedis();
  }

  Future<void> _initializeRedis() async {
    const int maxRetries = 1;
    int retries = 0;

    while (retries < maxRetries) {
      try {
        if (redisCommand != null) {
          try {
            await redisCommand!.send_object(['QUIT']).timeout(Duration(seconds: 1));
          } catch (e) {
            print('Error while closing previous connection: $e');
          }
        }

        redisCommand = await redisConnection
            .connect('145.223.88.141', 6379)
            .timeout(Duration(seconds: 5), onTimeout: () {
          throw Exception('Redis connection timeout');
        });

        await redisCommand!.send_object(['AUTH', redisPassword]).timeout(
          Duration(seconds: 2),
          onTimeout: () {
            throw Exception('Redis authentication timeout');
          },
        );

        try {
          await redisCommand!.send_object(['SET', 'test_key', 'test_value']).timeout(Duration(seconds: 2));
          await redisCommand!.send_object(['DEL', 'test_key']).timeout(Duration(seconds: 2));
          _isRedisReadOnly = false;
          print('Redis connected, authenticated, and writable');
        } catch (e) {
          _isRedisReadOnly = true;
          print('Redis is read-only: $e');
        }

        return;
      } catch (e) {
        retries++;
        print('Failed to connect/authenticate to Redis (attempt $retries/$maxRetries): $e');
        if (retries == maxRetries) {
          redisCommand = null;
          _isRedisReadOnly = true;
          print('Max retries reached. Redis connection failed.');
          return;
        }
        await Future.delayed(Duration(seconds: 1));
      }
    }
  }

  Future<bool> uploadImage(
      int questionId,
      File imageFile,
      int maintenanceScheduleId,
      int johkasouId,
      String? ipAddress,
      String? location,
      String? deviceModel,
      ) async {
    try {
      String? token = await TokenManager.getToken();
      if (token == null) throw Exception('No token found');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${DaikiAPI.api_key}/api/v1/image/store'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields.addAll({
        'maintenance_schedule_id': maintenanceScheduleId.toString(),
        'johkasou_model_id': johkasouId.toString(),
        'question_id': questionId.toString(),
        'type': 'inspection',
        'ip_address': ipAddress ?? 'Unknown',
        'location': location ?? 'Unknown',
        'device_model': deviceModel ?? 'Unknown',
      });

      request.files.add(await http.MultipartFile.fromPath(
        'media',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      print('Uploading image for question $questionId (johkasouId: $johkasouId):');
      print('Request headers: ${request.headers}');
      print('Request fields: ${request.fields}');
      print('File path: ${imageFile.path}');

      final streamedResponse = await request.send().timeout(Duration(seconds: 5));
      final response = await http.Response.fromStream(streamedResponse);

      print('Image upload response: HTTP ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is Map<String, dynamic>) {
          bool success = (responseData['status'] as bool?) == true || (responseData['success'] as bool?) == true;
          print('Image upload success: $success');
          return success;
        } else {
          throw Exception('Invalid response format: Expected a JSON object');
        }
      } else {
        throw Exception('Failed to upload image: HTTP ${response.statusCode} - ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Error uploading image for question $questionId (johkasouId: $johkasouId): $e\nStack trace: $stackTrace');
      throw Exception('Error uploading image: $e');
    }
  }

  Future<List<Category>> fetchCategories(
      int maintenanceScheduleId,
      int johkasouId,
      int projectId,
      ) async {
    try {
      String? token = await TokenManager.getToken();
      if (token == null) throw Exception('No token found. Please log in.');

      final prefs = await SharedPreferences.getInstance();
      String cacheKey = 'categories_${maintenanceScheduleId}_${johkasouId}';
      final cachedData = prefs.getString(cacheKey);

      // Try to load from cache first
      if (cachedData != null) {
        print('Retrieved categories from SharedPreferences for johkasouId: $johkasouId');
        final categoriesJson = json.decode(cachedData);
        if (categoriesJson is List) {
          final categories = categoriesJson.map((json) {
            final category = Category.fromJson(json);
            // Ensure all question fields are properly initialized
            category.questions.forEach((q) {
              q.required = q.required ?? 0;
            });
            return category;
          }).toList();
          return categories;
        }
      }

      // Try to load from Redis if available
      if (redisCommand != null && !_isRedisReadOnly) {
        try {
          var redisData = await redisCommand!.send_object(['GET', cacheKey]).timeout(
            Duration(seconds: 2),
            onTimeout: () => null,
          );
          if (redisData != null) {
            print('Retrieved categories from Redis cache for johkasouId: $johkasouId');
            final categoriesJson = json.decode(redisData);
            if (categoriesJson is List) {
              final categories = categoriesJson.map((json) {
                final category = Category.fromJson(json);
                category.questions.forEach((q) {
                  q.required = q.required ?? 0;
                });
                return category;
              }).toList();
              await prefs.setString(cacheKey, json.encode(categoriesJson));
              return categories;
            }
          }
        } catch (e) {
          print('Redis error while fetching categories for johkasouId $johkasouId: $e');
        }
      }

      // Fetch from API if not available in cache
      print('Fetching categories from API for johkasouId: $johkasouId');
      final response = await http.get(
        Uri.parse(
            '${DaikiAPI.api_key}/api/v1/stp-data/perform-for-johkasou-model/$maintenanceScheduleId?johkasou_model_id=$johkasouId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 5), onTimeout: () {
        throw Exception('API request timed out');
      });

      print('API response for johkasouId $johkasouId: HTTP ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['date'] != null && data['date'] is Map && data['date']['categories'] != null) {
          final categoriesJson = data['date']['categories'];
          if (categoriesJson is List) {
            final categories = categoriesJson.map((json) {
              final category = Category.fromJson(json);
              // Ensure all question fields are properly set
              category.questions.forEach((q) {
                q.required = q.required ?? 0;
              });
              return category;
            }).toList();

            // Save to cache
            await prefs.setString(cacheKey, json.encode(categoriesJson));
            print('Stored categories in SharedPreferences for johkasouId: $johkasouId');

            // Save to Redis if available
            if (!_isRedisReadOnly) {
              try {
                await _storeInRedis(cacheKey, json.encode(categoriesJson));
                print('Stored categories in Redis cache for johkasouId: $johkasouId');
              } catch (e) {
                print('Failed to store categories in Redis: $e');
              }
            }

            return categories;
          } else {
            throw Exception('Categories data is not a list: $categoriesJson');
          }
        } else {
          throw Exception('Invalid response structure: Missing or invalid "date" or "categories" field');
        }
      } else if (response.statusCode == 401) {
        // Token expired
        await TokenManager.clearToken();
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception('Failed to load categories: HTTP ${response.statusCode} - ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Error in fetchCategories for johkasouId $johkasouId: $e\nStack trace: $stackTrace');
      throw Exception('Error fetching categories: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<void> _storeInRedis(String key, String data) async {
    if (redisCommand == null || _isRedisReadOnly) {
      print('Skipping Redis store: command null or read-only for key: $key');
      return;
    }
    try {
      await redisCommand!.send_object(['SET', key, data]).timeout(Duration(seconds: 2));
      await redisCommand!.send_object(['EXPIRE', key, 3600]).timeout(Duration(seconds: 2));
      print('Stored in Redis cache: $key');
    } catch (e) {
      if (e.toString().contains('READONLY')) {
        _isRedisReadOnly = true;
        print('Redis is read-only, disabling writes: $e');
      } else {
        print('Failed to store in Redis for key $key: $e');
      }
    }
  }

  Future<bool> finalSubmit(int maintenanceScheduleId) async {
    try {
      String? token = await TokenManager.getToken();
      if (token == null) throw Exception('No token found. Please log in.');

      final response = await http.post(
        Uri.parse('${DaikiAPI.api_key}/api/v1/maintenance/stp-final-submit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: json.encode({
          'maintenance_schedule_id': maintenanceScheduleId,
        }),
      ).timeout(Duration(seconds: 15), onTimeout: () {
        throw Exception('Final submit API request timed out');
      });

      print('Final submit response for maintenanceScheduleId $maintenanceScheduleId: HTTP ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is Map<String, dynamic>) {
          bool success = (responseData['status'] as bool?) == true || (responseData['success'] as bool?) == true;
          print('Final submit success: $success');
          return success;
        } else {
          throw Exception('Invalid response format: Expected a JSON object');
        }
      } else {
        throw Exception('Failed to submit final report: HTTP ${response.statusCode} - ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Error in finalSubmit for maintenanceScheduleId $maintenanceScheduleId: $e\nStack trace: $stackTrace');
      throw Exception('Error submitting final report: $e');
    }
  }

  Future<void> close() async {
    try {
      if (redisCommand != null) {
        await redisCommand!.send_object(['QUIT']).timeout(Duration(seconds: 1));
      }
      await redisConnection.close();
    } catch (e) {
      print('Error closing Redis connection: $e');
    }
  }
}