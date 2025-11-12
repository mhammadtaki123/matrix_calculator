import 'package:flutter/material.dart';
import 'matrix.dart';

void main() => runApp(const MatrixApp());

class MatrixApp extends StatelessWidget {
  const MatrixApp({super.key});
  @override
  Widget build(BuildContext context) =>
      const MaterialApp(debugShowCheckedModeBanner: false, home: Home());
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _n = 2; // 2 or 3
  late List<TextEditingController> _a;
  late List<TextEditingController> _b;

  List<List<double>>? _res; // result matrix to show
  String? _msg; // messages (det, errors)

  @override
  void initState() {
    super.initState();
    _initCtrls(2);
  }

  void _initCtrls(int n) {
    _n = n;
    _a = List.generate(n * n, (_) => TextEditingController(text: '0'));
    _b = List.generate(n * n, (_) => TextEditingController(text: '0'));
    _res = null;
    _msg = null;
    setState(() {});
  }

  double _p(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0.0;

  // ---------- UI helpers ----------
  Widget _cell(TextEditingController c) => SizedBox(
    width: 56,
    child: TextField(
      controller: c,
      textAlign: TextAlign.center,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      decoration: const InputDecoration(
        isDense: true,
        border: OutlineInputBorder(),
      ),
      onChanged: (_) => setState(() {}),
    ),
  );

  Table _grid(List<TextEditingController> cs) => Table(
    defaultColumnWidth: const FixedColumnWidth(60),
    border: TableBorder.all(color: Colors.black12),
    children: List.generate(_n, (r) {
      return TableRow(
        children: [
          for (int c = 0; c < _n; c++)
            Padding(
              padding: const EdgeInsets.all(6),
              child: _cell(cs[r * _n + c]),
            ),
        ],
      );
    }),
  );

  Widget _box(double v) => Padding(
    padding: const EdgeInsets.all(8),
    child: Text(
      _fmt(v),
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 16),
    ),
  );

  Table _show(List<List<double>> m) => Table(
    defaultColumnWidth: const FixedColumnWidth(80),
    border: TableBorder.all(color: Colors.black12),
    children: List.generate(m.length, (r) {
      return TableRow(children: [for (final v in m[r]) _box(v)]);
    }),
  );

  String _fmt(double v) {
    final s = v.toStringAsFixed(6);
    return s.contains('.') ? s.replaceFirst(RegExp(r'\.?0+$'), '') : s;
  }

  void _setZeros(List<TextEditingController> cs) {
    for (final c in cs) {
      c.text = '0';
    }
  }

  void _resetA() {
    _setZeros(_a);
    setState(() {
      _res = null;
      _msg = null;
    });
  }

  void _resetB() {
    _setZeros(_b);
    setState(() {
      _res = null;
      _msg = null;
    });
  }

  void _resetAll() {
    _setZeros([..._a, ..._b]);
    setState(() {
      _res = null;
      _msg = null;
    });
  }

  // ---------- actions ----------
  void _do(String op) {
    setState(() {
      _msg = null;
      _res = null;

      try {
        if (_n == 2) {
          final A = Matrix2(_p(_a[0]), _p(_a[1]), _p(_a[2]), _p(_a[3]));
          if (op == 'det') {
            _msg = 'det(A) = ${_fmt(A.det())}';
            return;
          }
          if (op == 'inv') {
            final X = A.inv();
            _res = [
              [X.a, X.b],
              [X.c, X.d],
            ];
            return;
          }
          final B = Matrix2(_p(_b[0]), _p(_b[1]), _p(_b[2]), _p(_b[3]));
          Matrix2 R = A;
          if (op == '+') R = A.add(B);
          if (op == '-') R = A.sub(B);
          if (op == 'x') R = A.mul(B);
          _res = [
            [R.a, R.b],
            [R.c, R.d],
          ];
        } else {
          final A = Matrix3(
            _p(_a[0]),
            _p(_a[1]),
            _p(_a[2]),
            _p(_a[3]),
            _p(_a[4]),
            _p(_a[5]),
            _p(_a[6]),
            _p(_a[7]),
            _p(_a[8]),
          );
          if (op == 'det') {
            _msg = 'det(A) = ${_fmt(A.det())}';
            return;
          }
          if (op == 'inv') {
            _msg = 'inv(A) is only implemented for 2×2.';
            return;
          }
          final B = Matrix3(
            _p(_b[0]),
            _p(_b[1]),
            _p(_b[2]),
            _p(_b[3]),
            _p(_b[4]),
            _p(_b[5]),
            _p(_b[6]),
            _p(_b[7]),
            _p(_b[8]),
          );
          Matrix3 R = A;
          if (op == '+') R = A.add(B);
          if (op == '-') R = A.sub(B);
          if (op == 'x') R = A.mul(B);
          _res = [
            [R.a, R.b, R.c],
            [R.d, R.e, R.f],
            [R.g, R.h, R.i],
          ];
        }
      } catch (e) {
        _msg = e.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Matrix Calculator (2×2 & 3×3)')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // size selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Size: '),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _n,
                items: const [
                  DropdownMenuItem(value: 2, child: Text('2 × 2')),
                  DropdownMenuItem(value: 3, child: Text('3 × 3')),
                ],
                onChanged: (v) {
                  if (v != null) _initCtrls(v);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // inputs
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const Text(
                    'A',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  _grid(_a),
                  const SizedBox(height: 6),
                  OutlinedButton(
                    onPressed: _resetA,
                    child: const Text('Reset A'),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  const Text(
                    'B',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  _grid(_b),
                  const SizedBox(height: 6),
                  OutlinedButton(
                    onPressed: _resetB,
                    child: const Text('Reset B'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ops
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _do('+'),
                child: const Text('A + B'),
              ),
              ElevatedButton(
                onPressed: () => _do('-'),
                child: const Text('A - B'),
              ),
              ElevatedButton(
                onPressed: () => _do('x'),
                child: const Text('A × B'),
              ),
              ElevatedButton(
                onPressed: () => _do('det'),
                child: const Text('det(A)'),
              ),
              ElevatedButton(
                onPressed: _n == 2 ? () => _do('inv') : null,
                child: const Text('inv(A)'),
              ),
              OutlinedButton(
                onPressed: _resetAll,
                child: const Text('Reset All'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_msg != null)
            Text(_msg!, style: const TextStyle(color: Colors.blue)),
          if (_res != null)
            Card(
              margin: const EdgeInsets.only(top: 8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: _show(_res!),
              ),
            ),
        ],
      ),
    ),
  );
}
