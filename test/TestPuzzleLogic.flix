mod TestPuzzleLogic {

    /// canMove のテスト - 隣接タイルは移動可能、非隣接は移動不可
    @Test
    def testCanMove(): Unit \ Assert =
        let tiles = PuzzleLogic.initialTiles(); // 空きは位置15
        // 隣接: 位置14（15の左）と位置11（15の上）
        Assert.assertTrue(PuzzleLogic.canMove(tiles, 14));
        Assert.assertTrue(PuzzleLogic.canMove(tiles, 11));
        // 非隣接: 位置0（左上）と位置5
        Assert.assertFalse(PuzzleLogic.canMove(tiles, 0));
        Assert.assertFalse(PuzzleLogic.canMove(tiles, 5))

    /// move のテスト - タイルと空きマスが入れ替わる
    @Test
    def testMove(): Unit \ Assert =
        let tiles = PuzzleLogic.initialTiles();
        let newTiles = PuzzleLogic.move(tiles, 14);
        Assert.assertEq(expected = 0, Vector.get(14, newTiles));
        Assert.assertEq(expected = 15, Vector.get(15, newTiles))

    /// move のテスト - 移動不可なタイルは変化しない
    @Test
    def testMoveInvalid(): Unit \ Assert =
        let tiles = PuzzleLogic.initialTiles();
        let newTiles = PuzzleLogic.move(tiles, 0);
        Assert.assertEq(expected = tiles, newTiles)

    /// findEmpty のテスト
    @Test
    def testFindEmpty(): Unit \ Assert =
        let tiles = PuzzleLogic.initialTiles();
        Assert.assertEq(expected = 15, PuzzleLogic.findEmpty(tiles))

    /// indexToPos と posToIndex の相互変換テスト
    @Test
    def testPositionConversion(): Unit \ Assert =
        Assert.assertEq(expected = (0, 0), PuzzleLogic.indexToPos(0));
        Assert.assertEq(expected = (3, 3), PuzzleLogic.indexToPos(15));
        Assert.assertEq(expected = 0, PuzzleLogic.posToIndex(0, 0));
        Assert.assertEq(expected = 15, PuzzleLogic.posToIndex(3, 3))

    /// isSolvable のテスト - 解ける配置と解けない配置
    @Test
    def testIsSolvable(): Unit \ Assert =
        // 初期配置は解ける
        Assert.assertTrue(PuzzleLogic.isSolvable(PuzzleLogic.initialTiles()));
        // 15と14を入れ替えた配置は解けない
        let unsolvable = Vector#{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 15, 14, 0};
        Assert.assertFalse(PuzzleLogic.isSolvable(unsolvable))

    /// isCleared のテスト - クリア状態
    @Test
    def testIsClearedTrue(): Unit \ Assert =
        Assert.assertTrue(PuzzleLogic.isCleared(PuzzleLogic.initialTiles()))

    /// isCleared のテスト - 未クリア状態
    @Test
    def testIsClearedFalse(): Unit \ Assert =
        let shuffled = Vector#{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 0, 15};
        Assert.assertFalse(PuzzleLogic.isCleared(shuffled))

}
