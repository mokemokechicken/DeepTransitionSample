swift： アプリの深い画面遷移なども自由に行う仕組み

はじめに
=======
iOSのネイティブアプリにおいて、例えば直前の画面に戻るというのは簡単ですが、
View(Controller)階層の遠い画面に遷移するのは、
普通にやると途中のViewに色々処理を書いて回る必要があったりして結構たいへんなものです。

他にも以下のようなことがしたいときがあります。

* Push通知から起動したときは、そのパラメータに応じて自動的にその画面を表示したい
* WebやWebViewのリンクから、アプリ内の特定の画面に遷移したい（対象の階層が深くても）。
* 画面遷移毎にGoogleAnalyticsなどで記録を行いたい

今回の仕組みはこれを簡単に行うためのルールとその実装です。

仕様
======

TransitionViewControllerProtocol を実装したViewControllerが、今回の仕組みで操作可能になります。
TransitionViewController と TransitionDefaultHandler では標準的な実装を行っています。
基本的にはこのTransitionViewControllerを継承してください。

TransitionViewController の継承したViewControllerが行うこと
----------------

* 一つのViewControllerはMain Storyboard の`Storyboard ID`で識別されます。 この挙動は後述する `decideViewController` Methodを実装することで変更できます。
* その階層を '/top/list_news/show_news' というような形で指定します。この場合、 top -> list_news -> show_news という順でViewControllerがつながります。
* ページ遷移するときは、 `requestTransition("/top/list_news!")` などで行います。
  * ViewControllerを追加する遷移がある場合は必ずそうしてください。
  * ただし、Back（ViewControllerを除去する動作）などは、別の方法(NavigationControllerが自動で付けるもの)で行っても大丈夫です
* viewDidAppearをoverrideした時は必ず super を呼ぶ(これを忘れるとそれ以降遷移しなくなります)

### TransitionAgentDelegate のMethodを 実装するとき
遷移に振る舞いをカスタマイズしたいときにはこれらを実装します。

* decideViewController では TransitionViewControllerProtocol を実装したUIViewControllerを返します。遷移してはいけない場合はnilを返します。
* showViewController, showModelViewController, showInternalViewController では、ViewControllerの表示アニメーションなどをカスマイズできます。
  そこではViewControllerを自由に表示して良いですが、ViewController階層に必ずAddすること。
  * → navigationController.pushViewController や presentViewController や addChildViewController?? などを使うこと

TransitionViewControllerProtocol の各Methodで行うこと
--------------
独自に TransitionViewControllerProtocol を実装するときは以下のことに気をつけてください。
実装は TransitionViewController, TransitionDefaultHandler を参考にしてください。

### addViewController

* ViewControllerを作成する
* 作成した ViewController に Agentに正しいPathを与えて設置する
* ViewController階層に必ずAddすること。
* viewDidAppearイベントをCenterに通知する (transitionCenter.reportViewDidAppear を呼ぶ)。基本的にはUIViewControllerのイベントの viewDidAppear内で行ってください。

### setupAgent

* Agentを正しいPathで作成し、必要なDelegateを設定します。

### removeViewController

* 子供のViewControllerを非表示・除去して、transitionCenter.reportFinishedRemoveViewControllerFromを呼びます


RootTransitionAgent
-----------

最初に表示するViewControllerは 特別に RootTransitionAgent （か継承した）Classを使って

`RootTransitionAgent.create().forever().start("/top")`

のような記述を AppDelegate に書けば表示されます。

遷移の通知
---------

履歴の参照
---------

特別な遷移
--------

* Back(n=1)
* up(n=1)

相対PATH
-------

記号
-----

* `/`: NavigationController の Push による遷移
* `!`: ModalViewのような表示
* `#`: Tab のような内部ViewController
* パラメータ： `/top/news(category=10,offset=50)`  のように () で渡します。 agent の params Methodで参照できます。
* `!/`: ModalViewのような表示内で、更にNavigationControllerのコンテナを含みます
* `#/`: Tab のような内部ViewController内で、更にNavigationControllerのコンテナを含みます
