def main(): Unit \ IO + Chan + NonDet =
    // アプリを起動し続けるためのチャンネル
    let (_, receiver) = Channel.buffered(1);

    discard run {
        Game.restartGame()
    } with SwingLayer.withSwing;

    // チャンネルで待機してアプリを起動し続ける
    Channel.recv(receiver)
