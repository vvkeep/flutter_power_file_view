package cn.vvkeep.power_file_view;

public enum EngineState {

    /**
     * Not initialized
     * <p>
     * 未初始化
     */
    none(0),

    /**
     * Ready to start initializing
     * <p>
     * 开始初始化
     */
    start(1),

    /**
     * Initialization complete
     * <p>
     * 初始化完成
     */
    done(10),

    /**
     * Initialization exception
     * <p>
     * 初始化失败
     */
    error(11),

    /**
     * Download successful
     * <p>
     * 下载完成
     */
    downloadSuccess(20),

    /**
     * Download failed
     * <p>
     * 下载失败
     */
    downloadFail(21),

    /**
     * Downloading
     * <p>
     * 下载中
     */
    downloading(22),

    /**
     * Installation succeeded
     * <p>
     * 安装成功
     */
    installSuccess(30),

    /**
     * Installation failed
     * <p>
     * 安装失败
     */
    installFail(31);


    private final int value;

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
