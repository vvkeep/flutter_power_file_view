package cn.vvkeep.power_file_view;

public enum EngineState {
    /// Not initialized
    none(0),

    /// Ready to start initializing
    start(1),

    /// Initialization complete
    done(10),

    /// Initialization exception
    error(11),

    /// Download successful
    downloadSuccess(20),

    /// Download failed
    downloadFail(21),

    /// Downloading
    downloading(22),

    /// Installation succeeded
    installSuccess(30),

    /// Installation failed
    installFail(31);


    private int value;

    EngineState(int value) {
        this.value = value;
    }

    public static EngineState valueOf(int value) {
        switch (value) {
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

    public int getValue() {
        return value;
    }

    @Override
    public String toString() {
        return "EngineState{" +
                "value=" + value +
                '}';
    }
}
