/// ユーザー入力を表す Enum
pub enum GameInput with Eq {
    case Click(Int32)    // タイルをクリック（インデックス）
    case Arrow(Direction) // 矢印キー
    case NoInput         // 入力なし（テスト用終了シグナル）
}

/// 矢印キーの方向
pub enum Direction with Eq {
    case Up
    case Down
    case Left
    case Right
}

/// ゲームUI操作の抽象エフェクト
pub eff Game {
    /// 初期状態を取得する
    def getInitialState(): Vector[Int32]

    /// 現在の状態を表示する
    def render(state: Vector[Int32]): Unit

    /// ユーザ入力を取得する
    def getInput(): GameInput

    /// クリア時の処理
    def onCleared(): Unit
}

mod GameLoop {
    use Direction.{Up, Down, Left, Right}

    /// ゲームのメインループ（最終状態を返す）
    pub def start(): Vector[Int32] \ Game =
        let initial = Game.getInitialState();
        if (PuzzleLogic.isCleared(initial))
            onCleared(initial)
        else
            runLoop(initial)

    /// メインループ
    def runLoop(state: Vector[Int32]): Vector[Int32] \ Game =
        Game.render(state);
        let input = Game.getInput();
        match input {
            case GameInput.NoInput => state
            case _ =>
                (forM (
                    index <- inputToIndex(input, state);
                    newState <- PuzzleLogic.tryMove(state, index)
                ) yield (
                    if (PuzzleLogic.isCleared(newState)) onCleared(newState)
                    else runLoop(newState)
                ))
                |> Option.getWithDefault(runLoop(state))
        }

    /// 入力をタイルインデックスに変換
    def inputToIndex(input: GameInput, tiles: Vector[Int32]): Option[Int32] =
        match input {
            case GameInput.Click(index) => Some(index)
            case GameInput.Arrow(dir) => Some(arrowToIndex(dir, tiles))
            case GameInput.NoInput => None
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
    def onCleared(state: Vector[Int32]): Vector[Int32] \ Game =
        Game.render(state);
        Game.onCleared();
        state
}
