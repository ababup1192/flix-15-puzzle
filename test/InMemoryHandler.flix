mod InMemoryHandler {
    /// テスト用ハンドラ
    /// initialTiles: テスト用の初期盤面
    /// inputList: 入力のシーケンス（Click, Arrow, NoInput）
    pub def withTest(initialTiles: Vector[Int32], inputList: List[GameInput], f: Unit -> GameState \ ef): GameState \ (ef - Game) =
        region rc {
            let inputsRef: Ref[List[GameInput], rc] = Ref.fresh(rc, inputList);
            let stateRef: Ref[GameState, rc] = Ref.fresh(rc, { tiles = initialTiles, correctPositions = PuzzleLogic.correctPositions(initialTiles) });

            run {
                f()
            } with handler Game {
                def getInitialTiles(resume) = {
                    resume(initialTiles)
                }
                def render(state, resume) = {
                    Ref.put(state, stateRef); 
                    resume()
                }
                def getInput(resume) = {
                    let inputs = Ref.get(inputsRef);
                    match inputs {
                        case Nil => Ref.get(stateRef)  // 保存した状態を返す
                        case x :: xs => {
                            Ref.put(xs, inputsRef);
                            resume(x)
                        }
                    }
                }
                def onCleared(resume) = {
                    resume()
                }
            }
        }
}
