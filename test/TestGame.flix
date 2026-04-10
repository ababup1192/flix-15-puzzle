mod TestGame {

    /// テスト用盤面（2手でクリア可能）
    ///  1  2  3  4
    ///  5  6  7  8
    ///  9 10 11 12
    /// 13 [0] 14 15
    def initTiles(): Vector[Int32] =
        Vector#{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 0, 14, 15}

    /// クリック入力で2手でクリアするテスト
    @Test
    def testClickMoveToWin(): Unit \ Assert =
        // initTiles(): 13 [0] 14 15
        // 1手目: 位置14（タイル14）をクリック → 14と0が入れ替わる
        // 2手目: 位置15（タイル15）をクリック → 15と0が入れ替わる
        // 結果: 13 14 15 [0] → クリア
        let inputs = GameInput.Click(14) :: GameInput.Click(15) :: Nil;
        let state = run {
            GameLoop.start()
        } with InMemoryHandler.withTest(initTiles(), inputs);
        Assert.assertTrue(PuzzleLogic.isCleared(state#tiles))

    /// 移動不可能なタイルをクリックしても状態が変わらないテスト
    @Test
    def testInvalidClickNoChange(): Unit \ Assert =
        let inputs = GameInput.Click(0) :: Nil;
        let state = run {
            GameLoop.start()
        } with InMemoryHandler.withTest(initTiles(), inputs);
        Assert.assertEq(expected = initTiles(), state#tiles)

    /// 矢印キー入力でタイルが移動するテスト（2手）
    @Test
    def testArrowKeyMove(): Unit \ Assert =
        // 初期盤面: initTiles()
        //  1  2  3  4
        //  5  6  7  8
        //  9 10 11 12
        // 13 [0] 14 15
        // 1手目: 下矢印 → 位置9のタイル(10)が下に移動
        // 2手目: 右矢印 → 位置8のタイル(9)が右に移動
        // 結果:
        //  1  2  3  4
        //  5  6  7  8
        // [0] 9 11 12
        // 13 10 14 15
        let inputs = GameInput.Arrow(Direction.Down) :: GameInput.Arrow(Direction.Right) :: Nil;
        let state = run {
            GameLoop.start()
        } with InMemoryHandler.withTest(initTiles(), inputs);
        let expected = Vector#{1, 2, 3, 4, 5, 6, 7, 8, 0, 9, 11, 12, 13, 10, 14, 15};
        Assert.assertEq(expected = expected, state#tiles)

}
