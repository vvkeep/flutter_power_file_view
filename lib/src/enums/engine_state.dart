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
}
