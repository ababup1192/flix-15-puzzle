mod TestGame {

    /// テスト用盤面（15と0を入れ替え、1手でクリア可能）
    def initTiles(): Vector[Int32] =
        Vector#{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 0, 15}

    /// 1手でクリアするテスト
    @Test
    def testSingleMoveToWin(): Unit \ Assert =
        let inputs = 15 :: Nil;
        let tiles = run {
            GameLoop.start()
        } with InMemoryHandler.withTest(initTiles(), inputs);
        Assert.assertTrue(PuzzleLogic.isCleared(tiles))

    /// 移動不可能なタイルをクリックしても状態が変わらないテスト
    @Test
    def testInvalidMoveNoChange(): Unit \ Assert =
        let inputs = 0 :: Nil;  // 0は移動不可
        let tiles = run {
            GameLoop.start()
        } with InMemoryHandler.withTest(initTiles(), inputs);
        Assert.assertEq(expected = initTiles(), tiles)

}
