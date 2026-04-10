def main(): Unit \ IO + Chan + NonDet =
    // アプリを起動し続けるためのチャンネル
    let (_, receiver) = Channel.buffered(1);

    discard run {
        GameLoop.start()
    } with SwingLayer.withSwing;

    // チャンネルで待機してアプリを起動し続ける
    discard Channel.recv(receiver)
