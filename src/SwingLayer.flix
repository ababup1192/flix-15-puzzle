mod SwingLayer {
    import javax.swing.JFrame
    import javax.swing.JButton
    import javax.swing.JLabel
    import javax.swing.JPanel
    import javax.swing.JOptionPane
    import java.awt.GridLayout
    import java.awt.Font
    import java.awt.Dimension
    import java.awt.Component
    import java.awt.Color
    import java.awt.event.ActionListener
    import java.awt.event.ActionEvent
    import java.awt.event.KeyListener
    import java.awt.event.KeyEvent
    import com.formdev.flatlaf.FlatDarkLaf
    import java.lang.Object

    use Math.Shuffle

    def correctColor(): Color \ IO = new Color(200, 80, 80)     // 赤
    def wrongColor(): Color \ IO = new Color(80, 160, 200)      // 水色

    /// キーコードを Direction に変換
    def keyCodeToDirection(keyCode: Int32): Option[Game.Direction] =
        match keyCode {
            case 37 => Some(Game.Direction.Left)   // VK_LEFT
            case 38 => Some(Game.Direction.Up)     // VK_UP
            case 39 => Some(Game.Direction.Right)  // VK_RIGHT
            case 40 => Some(Game.Direction.Down)   // VK_DOWN
            case _ => None
        }

    /// ボタンを作成
    def createButton(index: Int32, tile: Int32, isCorrect: Bool, sender: Sender[Game.GameInput]): JButton \ IO =
        let btn = new JButton("${tile}");
        btn.setFont(new Font("SansSerif", 1, 24));
        if (isCorrect)
            btn.setBackground(correctColor())
        else
            btn.setBackground(wrongColor());
        let listener: ActionListener = new ActionListener {
            def actionPerformed(_this: ActionListener, _e: ActionEvent): Unit \ Chan =
                Channel.send(Game.GameInput.Click(index), sender)
        };
        btn.addActionListener(listener);
        btn

    /// パネルを再描画
    def reRenderPanel(frame: JFrame, tiles: Vector[Int32], correctIndices: Vector[Int32], sender: Sender[Game.GameInput]): Unit \ IO =
        let panel = getPanel(frame);
        panel.removeAll();
        Vector.forEachWithIndex((index, tile) -> {
            if (tile == 0) {
                let emptyLabel = new JLabel("");
                discard panel.add(emptyLabel)
            } else {
                let isCorrect = Vector.memberOf(index, correctIndices);
                let btn = createButton(index, tile, isCorrect, sender);
                discard panel.add(btn)
            }
        }, tiles);
        panel.revalidate();
        panel.repaint()

    /// Swing UIを初期化（キーボードリスナー付き）
    def initUI(sender: Sender[Game.GameInput]): JFrame \ IO =
        discard FlatDarkLaf.setup();
        let frame = new JFrame("15 Puzzle");
        let panel = new JPanel();

        panel.setLayout(new GridLayout(4, 4, 5, 5));
        panel.setPreferredSize(new Dimension(400, 400));

        // キーボードリスナーを追加
        let keyListener: KeyListener = new KeyListener {
            def keyPressed(_this: KeyListener, e: KeyEvent): Unit \ IO + Chan =
                let keyCode = e.getKeyCode();
                match keyCodeToDirection(keyCode) {
                    case Some(dir) => Channel.send(Game.GameInput.Arrow(dir), sender)
                    case None => ()
                }
            def keyReleased(_this: KeyListener, _e: KeyEvent): Unit = ()
            def keyTyped(_this: KeyListener, _e: KeyEvent): Unit = ()
        };
        panel.setFocusable(true);
        panel.addKeyListener(keyListener);

        frame.setContentPane(panel);
        frame.setDefaultCloseOperation(3); // JFrame.EXIT_ON_CLOSE = 3
        frame.pack();
        frame.setVisible(true);

        frame

    /// フレームからパネルを取得
    def getPanel(frame: JFrame): JPanel \ IO =
        let container = frame.getContentPane();
        unchecked_cast(container as JPanel)

    /// メッセージダイアログを表示
    def showDialog(frame: JFrame, msg: String): Unit \ IO =
        let parent: Component = checked_cast(frame);
        let message: Object = checked_cast(msg);
        JOptionPane.showMessageDialog(parent, message)

        /// シャッフルされた解ける盤面を生成（即クリア状態も弾く）
        def shuffleUntilSolvable(): Vector[Int32] \ NonDet =
            def loop(): Vector[Int32] \ Shuffle = {
                let shuffled = Shuffle.permutation(16);
                if (not PuzzleLogic.isSolvable(shuffled) or PuzzleLogic.isCleared(shuffled))
                    loop()
                else
                    shuffled
            };
            Shuffle.handle(loop)()

    /// Swingハンドラを返す関数（run { } with SwingHandler.withSwing 形式で使用）
    pub def withSwing(f: Unit -> a \ ef): a \ (ef - Game.Game) + IO + Chan + NonDet =
        let (sender, receiver): (Sender[Game.GameInput], Receiver[Game.GameInput]) = Channel.buffered(1);
        let frame = initUI(sender);
        run {
            f()
        } with handler Game.Game {
            def getInitialTiles(resume) = {
                resume(shuffleUntilSolvable())
            }
            def render(state, resume) = {
                reRenderPanel(frame, state#tiles, state#correctPositions, sender);
                resume()
            }
            def getInput(resume) = {
                let input = Channel.recv(receiver);
                resume(input)
            }
            def onCleared(resume) = {
                showDialog(frame, "Congratulations! Puzzle Cleared!");
                resume()
            }
        }
}
