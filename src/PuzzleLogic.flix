mod PuzzleLogic {

    /// インデックスから位置(行, 列)への変換
    pub def indexToPos(index: Int32): (Int32, Int32) =
        (index / 4, index `Int32.remainder` 4)

    /// 位置(行, 列)からインデックスへの変換
    pub def posToIndex(row: Int32, col: Int32): Int32 =
        row * 4 + col

    /// 空きマス(0)のインデックスを探す
    pub def findEmpty(tiles: Vector[Int32]): Int32 =
        Vector.findIndexOf(t -> t == 0, tiles) |> Option.getWithDefault(-1)

    /// Datalogでタイルが移動可能か判定
    /// クリックしたタイルが空きマスに隣接している場合のみ移動可能
    pub def canMove(tiles: Vector[Int32], clickedIndex: Int32): Bool =
        let emptyIndex = findEmpty(tiles);
        // 範囲外チェック
        if (clickedIndex < 0 or clickedIndex > 15 or emptyIndex < 0)
            false
        else
            // インデックスを (row, col) 座標に変換
            let (clickedRow, clickedCol) = indexToPos(clickedIndex);
            let (emptyRow, emptyCol) = indexToPos(emptyIndex);

            // Datalog ファクト: クリック位置、空きマス位置、4方向の隣接セルを定義
            let facts = #{
                ClickedPos(clickedRow, clickedCol).
                EmptyPos(emptyRow, emptyCol).
                // クリック位置から見た上下左右の隣接セル
                Adjacent(clickedRow, clickedCol, clickedRow, clickedCol - 1).  // 左
                Adjacent(clickedRow, clickedCol, clickedRow, clickedCol + 1).  // 右
                Adjacent(clickedRow, clickedCol, clickedRow - 1, clickedCol).  // 上
                Adjacent(clickedRow, clickedCol, clickedRow + 1, clickedCol).  // 下
            };

            // Datalog ルール: クリック位置の隣接セルに空きマスがあれば CanMove
            let rules = #{
                CanMove() :- ClickedPos(cr, cc), EmptyPos(er, ec), Adjacent(cr, cc, er, ec).
            };

            // クエリ結果が空でなければ移動可能
            let result = query facts, rules select true from CanMove();
            not Vector.isEmpty(result)

    /// タイルを移動（空きマスと入れ替え）
    pub def move(clickedIndex: Int32, tiles: Vector[Int32]): Vector[Int32] =
        let emptyIndex = findEmpty(tiles);
        if (not canMove(tiles, clickedIndex))
            tiles
        else
            let clickedTile = Vector.get(clickedIndex, tiles);
            tiles
                |> Vector.update(clickedIndex, 0)
                |> Vector.update(emptyIndex, clickedTile)

    /// 初期配列を生成
    pub def initialTiles(): Vector[Int32] =
        Vector#{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0}

    /// 正しい位置にあるピースのインデックスを返す
    pub def correctPositions(tiles: Vector[Int32]): Vector[Int32] =
        Vector.range(0, 16)
            |> Vector.filter(index -> {
                let tile = Vector.get(index, tiles);
                tile != 0 and tile == index + 1
            })

    /// 転倒数を計算（0を除く）
    pub def countInversions(tiles: Vector[Int32]): Int32 =
        let filtered = Vector.filter(t -> t != 0, tiles);
        let len = Vector.length(filtered);
        Vector.range(0, len) |> Vector.foldLeft((acc, i) -> {
            let vi = Vector.get(i, filtered);
            Vector.range(i + 1, len) |> Vector.foldLeft((acc2, j) -> {
                let vj = Vector.get(j, filtered);
                if (vi > vj)
                    acc2 + 1
                else
                    acc2
            }, acc)
        }, 0)

    /// 空きマスの行（下から数えて 1-4）
    pub def emptyRowFromBottom(tiles: Vector[Int32]): Int32 =
        let emptyIdx = findEmpty(tiles);
        let row = emptyIdx / 4;  // 0-3
        4 - row

    /// 15パズルが解けるか判定
    /// 4x4パズルでは: (転倒数 + 空きマスの行(下から)) が奇数なら解ける
    pub def isSolvable(tiles: Vector[Int32]): Bool =
        let inversions = countInversions(tiles);
        let emptyRow = emptyRowFromBottom(tiles);
        Int32.remainder(inversions + emptyRow, 2) == 1

    /// ゲームがクリアされたかチェック
    pub def isCleared(tiles: Vector[Int32]): Bool =
        tiles == initialTiles()
}
