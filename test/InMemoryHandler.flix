mod InMemoryHandler {
    /// テスト用ハンドラ（単一盤面）
    /// initialTiles: テスト用の初期盤面
    /// inputList: 入力のシーケンス（Click, Arrow, NoInput）
    pub def withTest(initialTiles: Vector[Int32], inputList: List[Game.GameInput], f: Unit -> Game.GameState \ ef): Game.GameState \ (ef - Game.Game) =
        withTestMultiBoards(initialTiles :: Nil, inputList, f)

    /// テスト用ハンドラ（複数盤面対応 - 再シャッフルテスト用）
    /// boardsList: 盤面のリスト（getInitialTilesが呼ばれるたびに次の盤面を返す）
    /// inputList: 入力のシーケンス
    pub def withTestMultiBoards(boardsList: List[Vector[Int32]], inputList: List[Game.GameInput], f: Unit -> Game.GameState \ ef): Game.GameState \ (ef - Game.Game) =
        region rc {
            let boardsRef: Ref[List[Vector[Int32]], rc] = Ref.fresh(rc, boardsList);
            let inputsRef: Ref[List[Game.GameInput], rc] = Ref.fresh(rc, inputList);
            let defaultTiles = List.head(boardsList) |> Option.getWithDefault(Vector#{});
            let stateRef: Ref[Game.GameState, rc] = Ref.fresh(rc, { tiles = defaultTiles });

            run {
                f()
            } with handler Game.Game {
                def getInitialTiles(resume) = {
                    let boards = Ref.get(boardsRef);
                    match boards {
                        case Nil => resume(defaultTiles)
                        case b :: bs => {
                            Ref.put(bs, boardsRef);
                            resume(b)
                        }
                    }
                }
                def render(state, resume) = {
                    Ref.put(state, stateRef);
                    resume()
                }
                def getInput(resume) = {
                    let inputs = Ref.get(inputsRef);
                    match inputs {
                        case Nil => Ref.get(stateRef)  
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
