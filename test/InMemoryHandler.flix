mod InMemoryHandler {
    /// テスト用ハンドラ
    /// initialTiles: テスト用の初期盤面
    /// inputList: クリック入力のシーケンス
    pub def withTest(initialTiles: Vector[Int32], inputList: List[Int32], f: Unit -> a \ ef): a \ (ef - Game) =
        region rc {
            let inputsRef: Ref[List[Int32], rc] = Ref.fresh(rc, inputList);
            let startCountRef: Ref[Int32, rc] = Ref.fresh(rc, 0);

            run {
                f()
            } with handler Game {
                def getInitialState(resume) = {
                    let count = Ref.get(startCountRef);
                    Ref.put(count + 1, startCountRef);
                    if (count == 0)
                        resume(initialTiles)
                    else
                        // 再スタート時: 未クリア状態を返して NoInput で終了させる
                        resume(Vector#{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 0, 15})
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
