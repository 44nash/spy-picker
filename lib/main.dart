import 'dart:developer' as developer;
import 'package:chess/chess.dart' as Chess;
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:flutter/material.dart';
import 'package:wp_chessboard/components/pieces.dart';
import 'package:wp_chessboard/wp_chessboard.dart';



void main() {
  runApp(MaterialApp(home: const MyApp()));
}

class MyApp extends StatefulWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class Spy { 
  
  Spy({required this.title, required this.piece}); 

  String title;
  dynamic piece;
}

class _MyAppState extends State<MyApp> {
  final controller = WPChessboardController();
  Chess.Chess chess = Chess.Chess.fromFEN("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");
  List<List<int>>? lastMove;

  void initState() {
    setState(() {
      chess = Chess.Chess.fromFEN("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");
    });
    update();
  }
  List<dynamic> spec_list = [
          Spy(title: "1", piece: null),
          Spy(title: "2", piece: null),
          Spy(title: "3", piece: null)  ];  //  -------------------------LIST--------------------------------- 

  // not working on drop
  Widget squareBuilder(SquareInfo info) {
    Color fieldColor = (info.index + info.rank) % 2 == 0 ? Colors.grey.shade200 : Colors.grey.shade600;
    Color overlayColor = Colors.transparent;

    if (lastMove != null ) {
      if (lastMove!.first.first == info.rank && lastMove!.first.last == info.file) {
        overlayColor = Colors.blueAccent.shade400.withOpacity(0.4);
      } else if (lastMove!.last.first == info.rank && lastMove!.last.last == info.file) {
        overlayColor = Colors.blueAccent.shade400.withOpacity(0.87);
      }
    }

    return Container(
      color: fieldColor,
      width: info.size,
      height: info.size,
      child: AnimatedContainer(
        color: overlayColor,
        width: info.size,
        height: info.size,
        duration: const Duration(milliseconds: 200),
      )
    );
  }

  void onPieceStartDrag(SquareInfo square, String piece) {
    showHintFields(square, piece);
  }

  void onPieceTap(SquareInfo square, String piece) {

 
    developer.log('Square => ${square} || Piece => ${piece}');    //  ---------------------------------------------------------- 

    String spy = '$square-$piece';
    Spy spyObj = new Spy(title: spy, piece: BlackBishop(size: 50));
    spec_list.removeAt(2);  
    spec_list = [spyObj, ...spec_list];

            setState(() {
           spec_list= spec_list;
        });

    developer.log('Spec list $spec_list');  
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text('Piece Data'),
        content:  Text('Square => ${square} || Piece => ${piece}'),
        
      ));
    
    
    // if (controller.hints.key == square.index.toString()) {
    //   controller.setHints(HintMap());
    //   return;
    // }
    // showHintFields(square, piece);
  }
  
  void showHintFields(SquareInfo square, String piece) {
    final moves = chess.generate_moves({ 'square': square.toString() });
    final hintMap = HintMap(key: square.index.toString());
    for (var move in moves) {
      String to = move.toAlgebraic;
      int rank = to.codeUnitAt(1) - "1".codeUnitAt(0) + 1;
      int file = to.codeUnitAt(0) - "a".codeUnitAt(0) + 1;

      hintMap.set(rank, file, (size) => MoveHint(
        size: size,
        onPressed: () => doMove(move),
      ));
    }
    controller.setHints(hintMap);
  }

  void onEmptyFieldTap(SquareInfo square) {
    controller.setHints(HintMap());
  }

  void onPieceDrop(PieceDropEvent event) {
    chess.move({ "from": event.from.toString(), "to": event.to.toString() });
    
    lastMove = [
      [ event.from.rank, event.from.file ],
      [ event.to.rank, event.to.file ]
    ];

    update(animated: false);
  }

  void doMove(Chess.Move move) {
    chess.move(move);
    
    int rankFrom = move.fromAlgebraic.codeUnitAt(1) - "1".codeUnitAt(0) + 1;
    int fileFrom = move.fromAlgebraic.codeUnitAt(0) - "a".codeUnitAt(0) + 1;
    int rankTo = move.toAlgebraic.codeUnitAt(1) - "1".codeUnitAt(0) + 1;
    int fileTo = move.toAlgebraic.codeUnitAt(0) - "a".codeUnitAt(0) + 1;
    lastMove = [
      [ rankFrom, fileFrom ],
      [ rankTo, fileTo ]
    ];

    update();
  }
  void setDefaultFen() {
    setState(() {
      chess = Chess.Chess.fromFEN("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");
    });
    update();
  }

  void setRandomFen() {
    setState(() {
      chess = Chess.Chess.fromFEN("3bK3/4B1P1/3p2N1/1rp3P1/2p2p2/p3n3/P5k1/6q1 w - - 0 1");
    });
    update();
  }

  void update({bool animated = true}) {
    controller.setFen(chess.fen, animation: animated);
  }

  void addArrows() {
    controller.setArrows([
      Arrow(
        from: SquareLocation.fromString("b1"),
        to: SquareLocation.fromString("c3"),
      ),
      Arrow(
        from: SquareLocation.fromString("g1"),
        to: SquareLocation.fromString("f3"),
        color: Colors.red
      )
    ]);
  }

  void removeArrows() {
    controller.setArrows([]);
  }

  BoardOrientation orienatation = BoardOrientation.white;
  void toggleArrows() {
    setState(() {
      if (orienatation == BoardOrientation.white) {
        orienatation = BoardOrientation.black;
      } else {
        orienatation = BoardOrientation.white;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WPChessboard Demo',
      home: Scaffold(
        body: Builder(builder: (context) {
            final double size = MediaQuery.of(context).size.shortestSide;

        int speclistlen = spec_list.length;
        
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WPChessboard(
                  size: size,
                  orientation: orienatation,
                  squareBuilder: squareBuilder,
                  controller: controller,
                  // Dont pass any onPieceDrop handler to disable drag and drop
                  onPieceDrop: onPieceDrop,
                  onPieceTap: onPieceTap,
                  onPieceStartDrag: onPieceStartDrag,
                  onEmptyFieldTap: onEmptyFieldTap,
                  turnTopPlayerPieces: false,
                  ghostOnDrag: true,
                  dropIndicator: DropIndicatorArgs(
                    size: size / 2,
                    color: Colors.lightBlue.withOpacity(0.24)
                  ),
                  pieceMap: PieceMap(
                    K: (size) => WhiteKing(size: size),
                    Q: (size) => WhiteQueen(size: size),
                    B: (size) => WhiteBishop(size: size),
                    N: (size) => WhiteKnight(size: size),
                    R: (size) => WhiteRook(size: size),
                    P: (size) => WhitePawn(size: size),
                    k: (size) => BlackKing(size: size),
                    q: (size) => BlackQueen(size: size),
                    b: (size) => BlackBishop(size: size),
                    n: (size) => BlackKnight(size: size),
                    r: (size) => BlackRook(size: size),
                    p: (size) => BlackPawn(size: size),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                            Container(
                                padding: EdgeInsets.only(left: 8.0),
                                width: 120,
                                height: 200,
                                child:Column(
                                  children: [
                                    ElevatedButton(onPressed: () {}, child: Text("${spec_list[0].title}")),
                                    const SizedBox(height: 24),
                                    ElevatedButton(onPressed: () {}, child: spec_list[0].piece != null ? spec_list[0].piece : null)

      
                                   ]
                                
                                )

                                    //  ElevatedButton(onPressed: () {}, child: Text("${spec_list[0].title}"))
                                    ),
                             Container(
                                padding: EdgeInsets.only(left: 8.0),
                                width: 120,
                                height: 200,
                                child: Column(
                                  children: [
                                    ElevatedButton(onPressed: () {}, child: Text("${spec_list[1].title}")),
                                    const SizedBox(height: 24),
                                    ElevatedButton(onPressed: () {}, child: spec_list[1].piece != null ? spec_list[1].piece : null)

      
                                   ]
                                
                                )

                                ),
                                    //ElevatedButton(onPressed: () {}, child: Text("${spec_list[1].title}"))),
                             Container(
                                padding: EdgeInsets.only(left: 8.0),
                                width: 120,
                                height: 200,
                                child: Column(
                                  children: [
                                    ElevatedButton(onPressed: () {}, child: Text("${spec_list[2].title}")),
                                    const SizedBox(height: 24),
                                   ElevatedButton(onPressed: () {}, child: spec_list[2].piece != null ? spec_list[2].piece : null)

      
                                   ]
                                )
                              )
                                    
                          ]
                  
                  //spec_list.getRange(0, speclistlen).map((e) => Text('$e')).toList(),
                ),
                ),
                const SizedBox(height: 24),
                // TextButton(
                //   onPressed: setDefaultFen,
                //   child: const Text("Set default Fen"),
                // ),
                // TextButton(
                //   onPressed: setRandomFen,
                //   child: const Text("Set random Fen"),
                // ),
                // TextButton(
                //   onPressed: addArrows,
                //   child: const Text("Add Arrows"),
                // ),
                // TextButton(
                //   onPressed: removeArrows,
                //   child: const Text("Remove Arrows"),
                // ),
                // TextButton(
                //   onPressed: toggleArrows,
                //   child: const Text("Change Orientation"),
                // )
              ],
            );
          },
        )
      )
    );
  }
}