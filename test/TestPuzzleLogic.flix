mod TestPuzzleLogic {

    /// canMove のテスト - 隣接タイルは移動可能、非隣接は移動不可
    @Test
    def testCanMove(): Unit \ Assert =
        // 空きを位置5に配置して4方向テスト
        //  0  1  2  3
        //  4 [0] 6  7
        //  8  9 10 11
        // 12 13 14 15
        let tiles = Vector#{1, 2, 3, 4, 5, 0, 7, 8, 9, 10, 11, 12, 13, 14, 15, 6};
        let results = List#{
            PuzzleLogic.canMove(tiles, 4),   // 左隣接: 移動可能
            PuzzleLogic.canMove(tiles, 6),   // 右隣接: 移動可能
            PuzzleLogic.canMove(tiles, 1),   // 上隣接: 移動可能
            PuzzleLogic.canMove(tiles, 9),   // 下隣接: 移動可能
            PuzzleLogic.canMove(tiles, 0),   // 非隣接（左上）: 移動不可
            PuzzleLogic.canMove(tiles, 15)   // 非隣接（右下）: 移動不可
        };
        Assert.assertEq(expected = List#{true, true, true, true, false, false}, results)

    /// move のテスト - タイルと空きマスが入れ替わる
    @Test
    def testMove(): Unit \ Assert =
        // 初期盤面:
        //  1  2  3  4
        //  5  6  7  8
        //  9 10 11 12
        // 13 14 15 [0]
        let tiles = PuzzleLogic.initialTiles();
        // 1手目: 位置14（タイル15）を移動 → 0が位置14へ
        // 2手目: 位置10（タイル11）を移動 → 0が位置10へ
        // 結果:
        //  1  2  3  4
        //  5  6  7  8
        //  9 10 [0] 12
        // 13 14 11 15
        let result = tiles
            |> PuzzleLogic.move(14)
            |> PuzzleLogic.move(10);
        let expected = Vector#{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 0, 12, 13, 14, 11, 15};
        Assert.assertEq(expected = expected, result)

    /// move のテスト - 移動不可なタイルは変化しない
    @Test
    def testMoveInvalid(): Unit \ Assert =
        let tiles = PuzzleLogic.initialTiles();
        let newTiles = PuzzleLogic.move(0, tiles);
        Assert.assertEq(expected = tiles, newTiles)

    /// findEmpty のテスト
    @Test
    def testFindEmpty(): Unit \ Assert =
        let tiles = PuzzleLogic.initialTiles();
        Assert.assertEq(expected = 15, PuzzleLogic.findEmpty(tiles))

    /// indexToPos のテスト
    @Test
    def testIndexToPos(): Unit \ Assert =
        let results = List#{
            PuzzleLogic.indexToPos(0),
            PuzzleLogic.indexToPos(15)
        };
        Assert.assertEq(expected = List#{(0, 0), (3, 3)}, results)

    /// posToIndex のテスト
    @Test
    def testPosToIndex(): Unit \ Assert =
        let results = List#{
            PuzzleLogic.posToIndex(0, 0),
            PuzzleLogic.posToIndex(3, 3)
        };
        Assert.assertEq(expected = List#{0, 15}, results)

    /// isSolvable のテスト - 解ける配置（1手でクリア可能）
    @Test
    def testIsSolvableTrue(): Unit \ Assert =
        //  1  2  3  4
        //  5  6  7  8
        //  9 10 11 12
        // 13 14 [0] 15
        let solvable = Vector#{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 0, 15};
        Assert.assertTrue(PuzzleLogic.isSolvable(solvable))

    /// isSolvable のテスト - 解けない配置（15と14を入れ替え）
    @Test
    def testIsSolvableFalse(): Unit \ Assert =
        //  1  2  3  4
        //  5  6  7  8
        //  9 10 11 12
        // 13 15 14 [0]
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
