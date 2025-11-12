class Matrix {
  final int rows;
  final int cols;
  final List<List<double>> _m;

  Matrix(this.rows, this.cols, List<List<double>> data)
    : _m = List.generate(
        rows,
        (r) => List<double>.from(data[r]),
        growable: false,
      ) {
    if (data.length != rows || data.any((r) => r.length != cols)) {
      throw ArgumentError('Matrix dimensions do not match provided data.');
    }
  }

  factory Matrix.fromFlat(int rows, int cols, List<double> values) {
    if (values.length != rows * cols) {
      throw ArgumentError('Flat data length must be rows*cols.');
    }
    final data = List.generate(rows, (r) {
      return List.generate(cols, (c) => values[r * cols + c]);
    });
    return Matrix(rows, cols, data);
  }

  List<double> operator [](int r) => _m[r];

  Matrix operator +(Matrix other) {
    _checkSameShape(other);
    final data = List.generate(rows, (r) {
      return List.generate(cols, (c) => _m[r][c] + other._m[r][c]);
    });
    return Matrix(rows, cols, data);
  }

  Matrix operator -(Matrix other) {
    _checkSameShape(other);
    final data = List.generate(rows, (r) {
      return List.generate(cols, (c) => _m[r][c] - other._m[r][c]);
    });
    return Matrix(rows, cols, data);
  }

  Matrix operator *(Matrix other) {
    if (cols != other.rows) {
      throw ArgumentError('A.cols must equal B.rows for multiplication');
    }
    final data = List.generate(rows, (r) {
      return List.generate(other.cols, (c) {
        double sum = 0;
        for (int k = 0; k < cols; k++) {
          sum += _m[r][k] * other._m[k][c];
        }
        return sum;
      });
    });
    return Matrix(rows, other.cols, data);
  }

  double det() {
    if (rows != cols) {
      throw ArgumentError('det() requires a square matrix');
    }
    if (rows == 2) {
      return _m[0][0] * _m[1][1] - _m[0][1] * _m[1][0];
    } else if (rows == 3) {
      final a = _m;
      return a[0][0] * (a[1][1] * a[2][2] - a[1][2] * a[2][1]) -
          a[0][1] * (a[1][0] * a[2][2] - a[1][2] * a[2][0]) +
          a[0][2] * (a[1][0] * a[2][1] - a[1][1] * a[2][0]);
    } else {
      throw UnimplementedError('det() only implemented for 2x2 and 3x3');
    }
  }

  Matrix inverse2x2() {
    if (rows != 2 || cols != 2) {
      throw ArgumentError('inverse2x2() requires a 2x2 matrix');
    }
    final d = det();
    if (d == 0) {
      throw ArgumentError('Matrix is singular (det=0), no inverse');
    }
    final a = _m;
    final inv = [
      [a[1][1] / d, -a[0][1] / d],
      [-a[1][0] / d, a[0][0] / d],
    ];
    return Matrix(2, 2, inv);
  }

  /// Inverse for 2x2 and 3x3 using adjugate/determinant.
  Matrix inverse() {
    if (rows != cols) {
      throw ArgumentError('inverse() requires a square matrix');
    }
    if (rows == 2) {
      return inverse2x2();
    } else if (rows == 3) {
      final d = det();
      if (d == 0) {
        throw ArgumentError('Matrix is singular (det=0), no inverse');
      }
      final a = _m;
      // Cofactor matrix C (not transposed yet)
      final List<List<double>> C = List.generate(3, (_) => List.filled(3, 0.0));

      double minorDet(int r, int c) {
        // indices not equal to r and c
        final rs = [0, 1, 2]..remove(r);
        final cs = [0, 1, 2]..remove(c);
        final m00 = a[rs[0]][cs[0]];
        final m01 = a[rs[0]][cs[1]];
        final m10 = a[rs[1]][cs[0]];
        final m11 = a[rs[1]][cs[1]];
        return m00 * m11 - m01 * m10;
      }

      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          final sign = ((i + j) % 2 == 0) ? 1.0 : -1.0;
          C[i][j] = sign * minorDet(i, j);
        }
      }

      // Adjugate is transpose of cofactor
      final adj = List.generate(3, (r) => List.generate(3, (c) => C[c][r]));
      final inv = List.generate(
        3,
        (r) => List.generate(3, (c) => adj[r][c] / d),
      );
      return Matrix(3, 3, inv);
    } else {
      throw UnimplementedError('inverse() only supported for 2x2 and 3x3');
    }
  }

  void _checkSameShape(Matrix o) {
    if (rows != o.rows || cols != o.cols) {
      throw ArgumentError('Matrices must have the same shape');
    }
  }
}
