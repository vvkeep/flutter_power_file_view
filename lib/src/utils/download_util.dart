import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:power_file_view/src/constant/enums.dart';
import 'package:power_file_view/src/i18n/power_localizations.dart';

import 'file_util.dart';

class DownloadUtil {
  static Dio _dio() {
    final BaseOptions options = BaseOptions(
      connectTimeout: 90 * 1000,
      receiveTimeout: 90 * 1000,
    );
    return Dio(options);
  }

  /// Using Dio to realize file download function
  static Future<void> download(
    String fileUrl,
    String filePath, {
    required Function(DownloadState value) callback,
    ProgressCallback? onProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    dynamic data,
    Options? options,
  }) async {
    callback(DownloadState.none);

    try {
      callback(DownloadState.downloading);

      final Response<dynamic> response = await _dio().download(
        fileUrl,
        filePath,
        onReceiveProgress: onProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        data: data,
        options: options,
      );

      callback(response.statusCode == 200 ? DownloadState.done : DownloadState.fail);
    } catch (e) {
      callback(DownloadState.error);
    }
  }

  /// Get file size through network link
  static Future<String?> fileSize(
    BuildContext context,
    String fileUrl, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    String? fileSizeTip,
    String? fileSizeErrorTip,
    String? fileSizeFailTip,
  }) async {
    final PowerLocalizations local = PowerLocalizations.of(context);

    try {
      final Response<dynamic> response = await _dio().head<dynamic>(
        fileUrl,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      );

      int size = 0;
      response.headers.forEach((String label, List<String> value) {
        if (label == 'content-length') {
          for (final String v in value) {
            size += int.tryParse(v) ?? 0;
          }
        }
      });

      if (response.headers.toString().contains('content-length')) {
        return '${fileSizeTip ?? local.fileSize}${FileUtil.fileSize(size)}';
      } else {
        return fileSizeFailTip ?? local.fileSizeFail;
      }
    } catch (e) {
      return fileSizeErrorTip ?? local.fileSizeError;
    }
  }
}
