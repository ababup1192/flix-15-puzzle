mod Game {
    use Direction.{Up, Down, Left, Right}

    /// ユーザー入力を表す。マウスのクリックとキーボードの矢印キーに対応。
    pub enum GameInput with Eq {
        case Click(Int32)    // タイルをクリック
        case Arrow(Direction) // 矢印キー
    }

    /// 矢印キーの方向
    pub enum Direction with Eq {
        case Up
        case Down
        case Left
        case Right
    }

    pub type alias GameState = { tiles = Vector[Int32] }

    pub eff Game {
        def getInitialTiles(): Vector[Int32]
        def render(state: GameState): Unit
        def getInput(): GameInput
        def onCleared(): Unit
    }

    pub def restartGame(): GameState \ Game =
        runLoop({tiles = Game.getInitialTiles()})

    @Tailrec
    def runLoop(state: GameState): GameState \ Game =
        Game.render(state);
        let input = Game.getInput();
        let tiles = state#tiles;
        let newTiles = PuzzleLogic.move(inputToIndex(input, tiles), tiles);
        let newState = {tiles = newTiles};

        if (PuzzleLogic.isCleared(newTiles)) {
            Game.render(newState);
            Game.onCleared();
            restartGame()
        } else {
            runLoop(newState)
        }

    def inputToIndex(input: GameInput, tiles: Vector[Int32]): Int32 =
        match input {
            case GameInput.Click(index) => index
            case GameInput.Arrow(dir) => arrowToIndex(dir, tiles)
        }

    def arrowToIndex(dir: Direction, tiles: Vector[Int32]): Int32 =
        let emptyIndex = PuzzleLogic.findEmpty(tiles);
        let offset = match dir {
            case Right => -1
            case Left  => 1
            case Down  => -4
            case Up    => 4
        };
        emptyIndex + offset
}
