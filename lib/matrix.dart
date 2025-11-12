class Matrix2 {
  double a, b, c, d;
  Matrix2(this.a, this.b, this.c, this.d);

  Matrix2 add(Matrix2 o) => Matrix2(a + o.a, b + o.b, c + o.c, d + o.d);
  Matrix2 sub(Matrix2 o) => Matrix2(a - o.a, b - o.b, c - o.c, d - o.d);
  Matrix2 mul(Matrix2 o) => Matrix2(
    a * o.a + b * o.c,
    a * o.b + b * o.d,
    c * o.a + d * o.c,
    c * o.b + d * o.d,
  );
  double det() => a * d - b * c;
  Matrix2 inv() {
    final detVal = det();
    if (detVal == 0) throw ArgumentError('Matrix is singular (det=0).');
    return Matrix2(d / detVal, -b / detVal, -c / detVal, a / detVal);
  }
}

class Matrix3 {
  double a, b, c, d, e, f, g, h, i;
  Matrix3(
    this.a,
    this.b,
    this.c,
    this.d,
    this.e,
    this.f,
    this.g,
    this.h,
    this.i,
  );

  Matrix3 add(Matrix3 o) => Matrix3(
    a + o.a,
    b + o.b,
    c + o.c,
    d + o.d,
    e + o.e,
    f + o.f,
    g + o.g,
    h + o.h,
    i + o.i,
  );

  Matrix3 sub(Matrix3 o) => Matrix3(
    a - o.a,
    b - o.b,
    c - o.c,
    d - o.d,
    e - o.e,
    f - o.f,
    g - o.g,
    h - o.h,
    i - o.i,
  );

  Matrix3 mul(Matrix3 o) => Matrix3(
    a * o.a + b * o.d + c * o.g,
    a * o.b + b * o.e + c * o.h,
    a * o.c + b * o.f + c * o.i,
    d * o.a + e * o.d + f * o.g,
    d * o.b + e * o.e + f * o.h,
    d * o.c + e * o.f + f * o.i,
    g * o.a + h * o.d + i * o.g,
    g * o.b + h * o.e + i * o.h,
    g * o.c + h * o.f + i * o.i,
  );

  double det() =>
      a * (e * i - f * h) - b * (d * i - f * g) + c * (d * h - e * g);
}
