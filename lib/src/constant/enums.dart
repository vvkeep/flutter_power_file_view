/// PreviewType
enum PreviewType {
  /// Not initialized
  none,

  /// Unsupported platform
  unsupportedPlatform,

  /// Nonexistent file
  nonExistent,

  /// Unsupported file type
  unsupportedType,

  /// X5 initializing
  engineLoading,

  /// X5 Initialization failed
  engineFail,

  /// Successfully opened file
  done
}

enum DownloadState {
  /// Not downloaded
  none,

  /// Downloading
  downloading,

  /// Download complete
  done,

  /// Download fail
  fail,

  /// Download exception
  error
}

enum EngineState {
  /// Not initialized
  none,

  /// Ready to start initializing
  start,

  /// Initialization complete
  done,

  /// Initialization exception
  error,

  /// Download successful
  downloadSuccess,

  /// Download failed
  downloadFail,

  /// Downloading
  downloading,

  /// Installation succeeded
  installSuccess,

  /// Installation failed
  installFail
}

extension EngineStateExtension on EngineState {
  static EngineState getType(int i) {
    switch (i) {
      case 0:
        return EngineState.none;
      case 1:
        return EngineState.start;
      case 10:
        return EngineState.done;
      case 11:
        return EngineState.error;
      case 20:
        return EngineState.downloadSuccess;
      case 21:
        return EngineState.downloadFail;
      case 22:
        return EngineState.downloading;
      case 30:
        return EngineState.installSuccess;
      case 31:
        return EngineState.installFail;
      default:
        return EngineState.none;
    }
  }

  static int getRawValue(EngineState state) {
    switch (state) {
      case EngineState.none:
        return 0;
      case EngineState.start:
        return 1;
      case EngineState.done:
        return 10;
      case EngineState.error:
        return 11;
      case EngineState.downloadSuccess:
        return 20;
      case EngineState.downloadFail:
        return 21;
      case EngineState.downloading:
        return 22;
      case EngineState.installSuccess:
        return 30;
      case EngineState.installFail:
        return 31;
    }
  }

  static String description(EngineState state) {
    switch (state) {
      case EngineState.none:
        return 'Not initialized';
      case EngineState.start:
        return 'Ready to start initializing';
      case EngineState.done:
        return 'Initialization complete';
      case EngineState.error:
        return 'Initialization exception';
      case EngineState.downloadSuccess:
        return 'Download successful';
      case EngineState.downloadFail:
        return 'Download failed';
      case EngineState.downloading:
        return 'Downloading';
      case EngineState.installSuccess:
        return 'Installation succeeded';
      case EngineState.installFail:
        return 'Installation failed';
    }
  }
}
