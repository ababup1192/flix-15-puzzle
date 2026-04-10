/// ユーザー入力を表す Enum
pub enum GameInput with Eq {
    case Click(Int32)    // タイルをクリック（インデックス）
    case Arrow(Direction) // 矢印キー
}

/// 矢印キーの方向
pub enum Direction with Eq {
    case Up
    case Down
    case Left
    case Right
}

/// ゲーム状態のレコード型
pub type alias GameState = { tiles = Vector[Int32], correctPositions = Vector[Int32] }

/// ゲームUI操作の抽象エフェクト
pub eff Game {
    /// 初期タイル配列を取得する
    def getInitialTiles(): Vector[Int32]

    /// 現在の状態を表示する
    def render(state: GameState): Unit

    /// ユーザ入力を取得する
    def getInput(): GameInput

    /// クリア時の処理
    def onCleared(): Unit
}

mod GameLoop {
    use Direction.{Up, Down, Left, Right}

    /// GameState を生成するヘルパー
    def makeState(tiles: Vector[Int32]): GameState =
        { tiles = tiles, correctPositions = PuzzleLogic.correctPositions(tiles) }

    /// ゲームのメインループ（最終状態を返す）
    pub def start(): GameState \ Game =
        let tiles = Game.getInitialTiles();
        let initial = makeState(tiles);
        runLoop(initial)

    /// メインループ
    def runLoop(state: GameState): GameState \ Game =
        Game.render(state);
        let input = Game.getInput();
        let index = inputToIndex(input, state#tiles);
        let newTiles = state#tiles |> PuzzleLogic.move(index);
        let newState = makeState(newTiles);

        if (PuzzleLogic.isCleared(newTiles)) onCleared(newState)
        else runLoop(newState)

    /// 入力をタイルインデックスに変換
    def inputToIndex(input: GameInput, tiles: Vector[Int32]): Int32 =
        match input {
            case GameInput.Click(index) => index
            case GameInput.Arrow(dir) => arrowToIndex(dir, tiles)
        }

    /// 矢印キーを移動するタイルのインデックスに変換
    def arrowToIndex(dir: Direction, tiles: Vector[Int32]): Int32 =
        let emptyIndex = PuzzleLogic.findEmpty(tiles);
        let offset = match dir {
            case Right => -1
            case Left  => 1
            case Down  => -4
            case Up    => 4
        };
        emptyIndex + offset

    /// クリア処理して最終状態を返す
    def onCleared(state: GameState): GameState \ Game =
        Game.render(state);
        Game.onCleared();
        state
}
