import 'package:flutter/material.dart';
import 'matrix.dart';

void main() {
  runApp(const MatrixApp());
}

class MatrixApp extends StatelessWidget {
  const MatrixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Matrix Calculator',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6750A4),
        visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
        inputDecorationTheme: const InputDecorationTheme(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        ),
      ),
      home: const MatrixPage(),
    );
  }
}

class MatrixPage extends StatefulWidget {
  const MatrixPage({super.key});

  @override
  State<MatrixPage> createState() => _MatrixPageState();
}

enum Op { add, sub, mul, detA, invA, resetAll }

class _MatrixPageState extends State<MatrixPage> {
  int _n = 3;
  List<TextEditingController> _a = [];
  List<TextEditingController> _b = [];

  Matrix? _res;
  String _msg = '';

  @override
  void initState() {
    super.initState();
    _initCtrls(_n);
  }

  void _initCtrls(int n) {
    for (final c in [..._a, ..._b]) {
      c.dispose();
    }
    _n = n;
    _a = List.generate(n * n, (_) => TextEditingController(text: '0'));
    _b = List.generate(n * n, (_) => TextEditingController(text: '0'));
    _res = null;
    _msg = '';
    setState(() {});
  }

  double _parse(String s) => double.tryParse(s.trim()) ?? 0.0;

  Matrix _read(List<TextEditingController> ctrls) {
    final vals = ctrls.map((e) => _parse(e.text)).toList();
    return Matrix.fromFlat(_n, _n, vals);
  }

  void _reset(List<TextEditingController> ctrls) {
    for (final c in ctrls) {
      c.text = '0';
    }
    setState(() {
      _res = null;
      _msg = '';
    });
  }

  void _resetAll() {
    _reset(_a);
    _reset(_b);
  }

  void _do(String code) {
    final A = _read(_a);
    final B = _read(_b);
    try {
      switch (code) {
        case '+':
          setState(() {
            _res = A + B;
            _msg = 'A + B';
          });
          break;
        case '-':
          setState(() {
            _res = A - B;
            _msg = 'A - B';
          });
          break;
        case '*':
          setState(() {
            _res = A * B;
            _msg = 'A × B';
          });
          break;
        case 'det':
          final d = A.det();
          setState(() {
            _res = null;
            _msg = 'det(A) = ${_fmt(d)}';
          });
          break;
        case 'inv':
          final inv = A.inverse();
          setState(() {
            _res = inv;
            _msg = 'inv(A)';
          });
          break;
      }
    } catch (e) {
      setState(() {
        _res = null;
        _msg = 'Error: $e';
      });
    }
  }

  void _runOp(Op op) {
    switch (op) {
      case Op.add:
        _do('+');
        break;
      case Op.sub:
        _do('-');
        break;
      case Op.mul:
        _do('*');
        break;
      case Op.detA:
        _do('det');
        break;
      case Op.invA:
        _do('inv');
        break; // enabled for 2x2 & 3x3
      case Op.resetAll:
        _resetAll();
        break;
    }
  }

  String _fmt(num v) {
    final s = v.toStringAsFixed(6);
    return s.contains('.') ? s.replaceFirst(RegExp(r'\.?0+$'), '') : s;
  }

  @override
  void dispose() {
    for (final c in [..._a, ..._b]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matrix Calculator (2×2 & 3×3)')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _sizePicker(),
                  const SizedBox(height: 12),
                  _matricesSection(),
                  const SizedBox(height: 12),
                  _operationPicker(),
                  const SizedBox(height: 12),
                  _resultCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sizePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Size:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(width: 12),
        Theme(
          data: Theme.of(context).copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
          child: DropdownMenu<int>(
            initialSelection: _n,
            onSelected: (v) {
              if (v != null) _initCtrls(v);
            },
            dropdownMenuEntries: const [
              DropdownMenuEntry(value: 2, label: '2 × 2'),
              DropdownMenuEntry(value: 3, label: '3 × 3'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _operationPicker() {
    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: DropdownMenu<Op>(
        label: const Text('Operation'),
        onSelected: (op) {
          if (op != null) _runOp(op);
        },
        dropdownMenuEntries: const [
          DropdownMenuEntry(value: Op.add, label: 'A + B'),
          DropdownMenuEntry(value: Op.sub, label: 'A - B'),
          DropdownMenuEntry(value: Op.mul, label: 'A × B'),
          DropdownMenuEntry(value: Op.detA, label: 'det(A)'),
          DropdownMenuEntry(value: Op.invA, label: 'inv(A)'),
          DropdownMenuEntry(value: Op.resetAll, label: 'Reset All'),
        ],
      ),
    );
  }

  Widget _matricesSection() {
    return LayoutBuilder(
      builder: (context, c) {
        final twoAcross = c.maxWidth >= 720; // stack under 720
        final spacing = 16.0;
        final perPanelWidth = twoAcross
            ? (c.maxWidth - spacing) / 2
            : c.maxWidth;

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: perPanelWidth,
              child: _panel(context, 'A', _a, perPanelWidth),
            ),
            SizedBox(
              width: perPanelWidth,
              child: _panel(context, 'B', _b, perPanelWidth),
            ),
          ],
        );
      },
    );
  }

  Widget _panel(
    BuildContext ctx,
    String title,
    List<TextEditingController> ctrls,
    double panelWidth,
  ) {
    final double gap = 6; // tighter gaps
    final double inner = panelWidth; // full width
    final double perCellW = (inner - gap * (_n - 1)) / _n;
    const double targetH = 44; // compact height target
    final double ratio = (perCellW / targetH).clamp(
      1.4,
      6.0,
    ); // wider-than-tall

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: Theme.of(ctx).textTheme.titleMedium),
        const SizedBox(height: 6),
        SizedBox(width: inner, child: _grid(ctrls, gap, ratio)),
        const SizedBox(height: 8),
        FilledButton.tonal(
          onPressed: () => _reset(ctrls),
          child: Text('Reset $title'),
        ),
      ],
    );
  }

  Widget _grid(
    List<TextEditingController> ctrls,
    double gap,
    double childAspectRatio,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _n * _n,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _n,
        mainAxisSpacing: gap,
        crossAxisSpacing: gap,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, i) {
        return TextField(
          controller: ctrls[i],
          textAlign: TextAlign.center,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        );
      },
    );
  }

  Widget _resultCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0x22000000)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Result', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_msg.isNotEmpty) Text(_msg),
            if (_res != null) ...[
              const SizedBox(height: 6),
              _renderMatrix(_res!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _renderMatrix(Matrix m) {
    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: List.generate(m.rows, (r) {
        return TableRow(
          children: List.generate(m.cols, (c) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(_fmt(m[r][c])),
            );
          }),
        );
      }),
    );
  }
}
