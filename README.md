# ハードウェア構成法 冬休み特訓レポート2018

## 問題
> 10ビットの正数 : 変域 1~1023 について,
> 偶数なら2で割る
> 奇数なら3倍して|1する
> を繰り返していると, 数字が大小を繰り返しそのうち1になります.
> これを Collatz 山脈と呼ぶことにします.
> Collats 山脈の最高峰を与える登り口のうち
> 最も行程の長いスタート地点の数字をルートの名前とします.
> 例えば 7, 8, 9, 10, 11 からスタートした場合
> 最高峰は52になりますが行程の一番長い9をルート名とします.
> 最高峰が高い順に上位4本のルート名とその行程の長さを計算する回路を設計してください.

## 環境
- macbook pro
- Virtual box | Vagrant | Ubuntu 16.04
- Quartus Prime 18.0 Lite Edition

### 環境構築時の注意
環境構築については、紆余曲折を経て最終的には[https://qiita.com/kawasin73/items/f89aba6bc1dee39c3863] を参考にしました。

最新版Ubuntuと最新版Quartusでは不具合がでました。Ubuntuを使う場合はversionに気をつけたほうが良さそうです。

Quartusを入れましたが、Modelsim実行時にvlibが見つからないというエラーが出たので、[https://forums.intel.com/s/question/0D50P00003yyTcCSAU/execution-of-vlib-failed-ubuntu-1604?language=en_US] を参考にして、シンボリックリンクを貼ったら動作しました。

### Quartusのメリット
- macユーザーはインストールに手間取るのでキレそうになりますが、使ってみると高機能で涙が出ます。vhdlを回路図に変換できますし、逆に回路図をvhdlに変換できます。
- コンパイルするとエレメント数が確認できます。この結果を提出したほうが良さそうです。
- よく使う回路はパラメータをいくつか設定すればQuartusで生成できます。今回のRAMもQuartusで作成可能です。
- etc

## 教授から聞いた話
- 基本的にQuartusでコンパイルしてエレメント数が出れば、実装可能と考えて良い
- 何も考えないで2万クロックくらい
- 頑張って高速化して2000クロックくらい？
- 数百クロックは無理(実装不可）
- レジスタ1000個とかはなるべくやめてほしい...？

## 実装方法
- RAMを用いて、既に調査した登り口に対する最高峰の高さと行程の長さを記憶しておくことで再計算を防ぎます.
- RAMを2-port RAMにすることで、最高峰の計算を2つ平行して行います。
- あるルートのcollazs数を求めるときはpriority encoder と barrel shifter を用いて偶数を全てスキップします。
- 偶数ルートの計算や結果の保存は行いません。top4に511以下の数xがあれば、かわりに2xを答えにすればよいです。2xも511以下なら同様に繰り返します。ただし、今回の答えは全て513以上の奇数なので（本当か？）気にしなく良い。

## ファイル
レポジトリに含まれるファイルについて説明します

### ソースコード
- collatz.vhd :
  トップレベルのコードです。入力(clk)を受け取り、ram_wrap, pending, climb*2, controller, count_clk, sorterを結びつけ、答えをモジュール化したインスタンスから受け取って出力します。
- controller.vhd :
  全体の制御を行うファイルです。沢山の入力と出力がありますが、細かい条件分岐などの役割を担います。
- climb.vhd :
  入力したルートのcollatz数を求めるファイルです。プライオリティ・エンコーダーとバレルシフタを使うことで偶数を全てスキップします。また、RAMを確認することにより再計算を防ぎます。
- pending.vhd :
  衝突時にreadのデータ（途中結果）を保存します。最後に保存したデータをclimbに実行させます。処理が終了したらall_doneフラグを立てます。
- count_clk.vhd :
  all_doneフラグが立って終了するまで、クロック数をカウントします。
- sorter.vhd :
  climbの結果を受け取って、最高峰の値を使ってソートし、top4を保持しておきます。bubbleソートなどを無理に使おうとすると、最大動作周波数が下がってしまったので変更しました。
- ram_wrap.vhd :
  Quartus生成の2-port RAMを制御します。
- ram_2_port.vhd :
  Quartus によって生成された true 2-port RAM です。
- ram_2_port.mif : RAM の初期化ファイルです.
### Quartus関係
- print.pdf:
  トップレベルのソースコードを使って作成した回路図のpdfです。
- collatz.qpf : project file です.
- collatz.qsf : setting file です. Device は適当に Cyclone V の 5CGXFC7C7F23C8 を選びました.
- collatz.sdc : 制約記述ファイルです. clock の timing constraint を記述してあります. 適当に 50MHz にしておきました.
- ram_2_port.qip : ram_2_port.vhd のための環境ファイルです.
- output_files/collatz.flow.rpt : コンパイル結果の一部です. エレメントの使用状況を見ることができます.
- output_files/collatz.sta.rpt : コンパイル結果の一部です. 最大動作周波数を見ることができます.

## 結果
### 出力
clk_count : 2041

top4(root, peak, len)
1. 937, 250504, 173
2. 871, 190996, 178
3. 1023, 118096, 62
4. 639, 41524, 131

### 最大動作周波数
 Slow 1100mV 85C Model Fmax Summary

| Fmax      | Restricted Fmax | Clock Name | Note |
|-----------|-----------------|------------|------|
| 48.4 MHz  |  48.4 MHz        | clk        |      |

### エレメント使用率

|Flow Summary                     |                                             |
|---------------------------------|---------------------------------------------|
| Flow Status                     | Successful - Tue Jan 15 09:36:47 2019       |
| Quartus Prime Version           | 18.0.0 Build 614 04/24/2018 SJ Lite Edition |
| Revision Name                   | collatz                                     |
| Top-level Entity Name           | collatz                                     |
| Family                          | Cyclone V                                   |
| Device                          | 5CGXFC7C7F23C8                              |
| Timing Models                   | Final                                       |
| Logic utilization (in ALMs)     | 1,052 / 56,480 ( 2 % )                      |
| Total registers                 | 891                                         |
| Total pins                      | 177 / 268 ( 66 % )                          |
| Total virtual pins              | 0                                           |
| Total block memory bits         | 13,824 / 7,024,640 ( < 1 % )                |
| Total DSP Blocks                | 0 / 156 ( 0 % )                             |
| Total HSSI RX PCSs              | 0 / 6 ( 0 % )                               |
| Total HSSI PMA RX Deserializers | 0 / 6 ( 0 % )                               |
| Total HSSI TX PCSs              | 0 / 6 ( 0 % )                               |
| Total HSSI PMA TX Serializers   | 0 / 6 ( 0 % )                               |
| Total PLLs                      | 0 / 13 ( 0 % )                              |
| Total DLLs                      | 0 / 4 ( 0 % )                               |


## その他
### RAMについて
- RAMの生成時、「Which ports should be registered?」と聞かれたら、「Read output port(s) ‘q’」をオフにしないと出力がラッチされてクロックが遅れてしまう。
- 入力のラッチはデフォルトでオンになっており変更できない模様（1-port RAMでは変更できそう…？）

### デバッグについて
バグはコンパイル時に出るエラーや、波形を見て想定と違う部分を見て見つけます。[https://www.dcode.fr/collatz-conjecture]
などのサイトでcollatz数を計算できるので役に立ちました。

やってみた感じだと、デバッグは主に3段階くらい。
1. エディタの静的解析による構文チェック(if文やprocess文をちゃんと閉じているか？など)
2. コンパイルでチェックされる構文エラー(セミコロン忘れなど）や型エラー
3. コンパイル終了後に波形を確認。想定どおりにならない箇所を探す。
