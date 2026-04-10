mod InMemoryHandler {
    /// テスト用ハンドラ
    /// initialTiles: テスト用の初期盤面
    /// inputList: クリック入力のシーケンス
    pub def withTest(initialTiles: Vector[Int32], inputList: List[Int32], f: Unit -> a \ ef): a \ (ef - Game) =
        region rc {
            let inputsRef: Ref[List[Int32], rc] = Ref.fresh(rc, inputList);

            run {
                f()
            } with handler Game {
                def getInitialState(resume) = {
                    resume(initialTiles)
                }
                def render(_state, resume) = {
                    resume()
                }
                def getInput(resume) = {
                    let inputs = Ref.get(inputsRef);
                    match inputs {
                        case Nil => resume(GameInput.NoInput)
                        case x :: xs => {
                            Ref.put(xs, inputsRef);
                            resume(GameInput.Click(x))
                        }
                    }
                }
                def onCleared(resume) = {
                    resume()
                }
            }
        }
}
