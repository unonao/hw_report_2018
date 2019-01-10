# ハードウェア構成法 冬休み特訓レポート2018 

## 問題
> 10ビットの正数 : 変域 1~1023 について,
> 偶数なら2で割る
> 奇数なら3倍して+1する
> を繰り返していると, 数字が大小を繰り返しそのうち1になります.
> これを Collatz 山脈と呼ぶことにします.
> Collats 山脈の最高峰を与える登り口 (=奇数) のうち
> 最も行程の長いスタート地点の数字をルートの名前とします.
> 例えば 7, 8, 9, 10, 11 からスタートした場合
> 最高峰は52になりますが行程の一番長い9をルート名とします.
> 最高峰が高い順に上位4本のルート名とその行程の長さを計算する回路を設計してください.

## 環境
- macbook pro
- virtual box + vagrant + Ubuntu 16.04
- Quartus Prime 18.0 Lite Edition

環境構築については、[https://qiita.com/kawasin73/items/f89aba6bc1dee39c3863] を参考にしました。
quartusを入れましたが、Modelsim実行時にvlibが見つからないというエラーが出たので、[https://forums.intel.com/s/question/0D50P00003yyTcCSAU/execution-of-vlib-failed-ubuntu-1604?language=en_US] を参考にして、シンボリックリンクを貼ったら動作しました。

## 実装
priority encoder と barrel shifter を用いて偶数を全てスキップしています.
RAMを用いて、既に調査した登り口に対する最高峰の高さと行程の長さを記憶しておくことで再計算を防ぎます.
RAMを2-port RAMにすることで、ルートの最高峰の計算を2つ平行して行います。
