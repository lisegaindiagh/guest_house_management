import 'package:dio/dio.dart';

import '../Common/app_common.dart';

/* Api call Method Declared
* set Base url
* */
class ApiProvider {
  final Dio _dio = Dio();

  String baseUrl = "https://mediumvioletred-wallaby-126857.hostingersite.com/api/";

  Future<dynamic> getServerResponse(
    String url,
    String method, {
    var params,
    var queryParams,
    bool isTemplate = false,
    bool isCallCenServer = false,
  }) async {
    dynamic response;

    String cUrl = baseUrl + url;
    Options options = Options(
      headers: {
        'Content-Type': 'application/json',
        'authorization':
            "Bearer ${await AppCommon.sharePref.getString(AppCommon.sessionKey.token)}",
      },
    );

    try {
      if (method.toLowerCase() == "get") {
        response = await _dio.get(
          cUrl,
          options: options,
          queryParameters: !AppCommon.isEmpty(queryParams) ? queryParams : {},
        );
      } else if (method.toLowerCase() == "post") {
        response = await _dio.post(
          cUrl,
          options: options,
          data: !AppCommon.isEmpty(params)
              ? AppCommon.encodeJsonData(params)
              : {},
          queryParameters: !AppCommon.isEmpty(queryParams) ? queryParams : {},
        );
      } else if (method.toLowerCase() == "put") {
        response = await _dio.put(
          cUrl,
          options: options,
          data: params,
          queryParameters: !AppCommon.isEmpty(queryParams) ? queryParams : {},
        );
      } else if (method.toLowerCase() == "delete") {
        response = await _dio.delete(
          cUrl,
          options: options,
          queryParameters: !AppCommon.isEmpty(queryParams) ? queryParams : {},
        );
      }
    } catch (e) {
      // The exception is of type DioError
      if (e is DioException) {
        if (e.response!.statusCode == 401) {}
        AppCommon.displayToast(e.response!.data["Message"]);
      }
    }
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception("Failed to Load");
    }
  }
}
