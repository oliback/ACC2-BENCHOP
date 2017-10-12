## Copyright (C) 2016 Marco Caliari
## Copyright (C) 2016 Nir Krakauer
## Copyright (C) 2017 Michele Ginesi
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {} {} newgammainc (@var{x}, @var{a})
## @deftypefnx {} {} newgammainc (@var{x}, @var{a}, @var{tail})
## Compute the normalized incomplete gamma function.
##
## This is defined as
## @tex
## $$
##  \gamma (x, a) = {1 \over {\Gamma (a)}}\displaystyle{\int_0^x t^{a-1} e^{-t} dt}
## $$
## @end tex
## @ifnottex
##
## @example
## @group
##                                 x
##                        1       /
## newgammainc (x, a) = ---------    | exp (-t) t^(a-1) dt
##                   gamma (a)    /
##                             t=0
## @end group
## @end example
##
## @end ifnottex
## with the limiting value of 1 as @var{x} approaches infinity.
## The standard notation is @math{P(a,x)}, e.g., @nospell{Abramowitz} and
## @nospell{Stegun} (6.5.1).
##
## If @var{a} is scalar, then @code{newgammainc (@var{x}, @var{a})} is returned
## for each element of @var{x} and vice versa.
##
## If neither @var{x} nor @var{a} is scalar, the sizes of @var{x} and
## @var{a} must agree, and @code{newgammainc} is applied element-by-element.
## The elements of @var{a} must be nonnegative.
##
## By default or if @var{tail} is @qcode{"lower"} the incomplete gamma
## function integrated from 0 to @var{x} is computed.  If @var{tail}
## is @qcode{"upper"} then the complementary function integrated from
##  @var{x} to infinity is calculated.
##
## If @var{tail} is @qcode{"scaledlower"}, then the lower incomplete gamma
## function is multiplied by
## @tex
## $\Gamma(a+1)\exp(x)x^{-a}$.
## @end tex
## @ifnottex
## @math{gamma(a+1)*exp(x)/(x^a)}.
## @end ifnottex
## If @var{tail} is @qcode{"scaledupper"}, then the upper incomplete gamma
## function is divided by the same quantity.
##
## References:
##
## @nospell{W. Gautschi},
## @cite{A computational procedure for incomplete gamma functions}
## @nospell{ACM Trans. Math Software},
## pp. 466--481, Vol 5, No. 4, 2012.
##
## @nospell{W. H. Press, S. A. Teukolsky, W. T. Vetterling, and B. P. Flannery}
## @cite{Numerical Recipes in Fortran 77},
## ch. 6.2, Vol 1, 1992.
##
## @seealso{gamma, gammaincinv, gammaln}
## @end deftypefn

## P(a,x) = gamma(a,x)/Gamma(a), upper
## 1-P(a,x)=Q(a,x)=Gamma(a,x)/Gamma(a), lower

function y = newgammainc (x, a, tail = "lower")

  if (nargin >= 4 || nargin <= 1)
    print_usage ();
  endif

  if ((! isscalar (x)) || (! isscalar (a)))
    [err, x, a] = common_size (x, a);
    if (err > 0)
      error ("newgammainc: x, a must be of common size or scalars");
    endif
  endif

  if (any (a < 0) || any (imag (a) != 0))
    error ("newgammainc: a must be real and non negative");
  endif

  if (any (imag (x) != 0))
    error ("newgammainc: x must be real");
  endif

  ## Initialize output array.
  if (isinteger (x))
    x = double (x);
  endif

  if (strcmpi (class (a), "single"))
    x = single (x);
  endif

  y = zeros (size (x), class (x));

  ## Different x, a combinations are handled by different subfunctions.
  i_done = false (size (x)); # Track which elements have been calculated.

  ## Case 0: x == Inf, a == Inf

  ii = ((x == Inf) & (a == Inf));
  if (any (ii(:)))
    y(ii) = NaN;
    i_done(ii) = true;
  endif

  ## Case 1: x == 0, a == 0.
  ii = ((x == 0) & (a == 0));
  if (any (ii(:)))
    y(ii) = newgammainc_00 (tail);
    i_done(ii) = true;
  endif

  ## Case 2: x == 0.
  ii = ((! i_done) & (x == 0));
  if (any (ii(:)))
    y(ii) = newgammainc_x0 (tail);
    i_done(ii) = true;
  endif

  ## Case 3: x = Inf
  ii = ((! i_done) & (x == Inf));
  if (any (ii(:)))
    y(ii) = newgammainc_x_inf (tail);
    i_done(ii) = true;
  endif

  ## Case 4: a = Inf
  ii = ((! i_done) & (a == Inf));
  if (any (ii(:)))
    y(ii) = newgammainc_a_inf (tail);
    i_done(ii) = true;
  endif

  ## Case 5: a == 0.
  ii = ((! i_done) & (a == 0));
  if (any (ii(:)))
    y(ii) = newgammainc_a0 (x(ii), tail);
    i_done(ii) = true;
  endif

  ## Case 6: a == 1.
  ii = ((! i_done) & (a == 1));
  if (any (ii(:)))
    y(ii) = newgammainc_a1 (x(ii), tail);
    i_done(ii) = true;
  endif

  flag_an = ((a > 1) & (a == fix (a)) & (x <= 36) & (abs (x) >= 1e-01) & ...
        (a <= 18));

  ## Case 7: positive integer a; exp (x) and a!  both under 1/eps.
  ii = ((! i_done) & flag_an);
  if (any (ii(:)))
    y(ii) = newgammainc_an (x(ii), a(ii), tail);
    i_done(ii) = true;
  endif

  ## For a < 2, x < 0, we increment a by 2 and use a recurrence formula after
  ## the computations.

  flag_a_small = ((abs (a) < 2) & (abs(a) > 0) & (! i_done) & (x < 0));
  a(flag_a_small) += 2;

  flag_s = (((x + 0.25 < a | x < 0 | a < 5) & (x > -20)) | (abs (x) < 1));

  ## Case 8: x, a relatively small.
  ii = ((! i_done) & flag_s);
  if (any (ii(:)))
    y(ii) = newgammainc_s (x(ii), a(ii), tail);
    i_done(ii) = true;
  endif

  ## Case 9: x positive and large relative to a.
  ii = (! i_done);
  if (any (ii(:)))
    y(ii) = newgammainc_l (x(ii), a(ii), tail);
    i_done(ii) = true;
  endif

  if (any (flag_a_small))
    if (strcmpi (tail, "lower"))
      y(flag_a_small) += D (x(flag_a_small), a(flag_a_small) - 1) + ...
        D (x(flag_a_small), a(flag_a_small) - 2);
    elseif (strcmpi (tail, "upper"))
      y(flag_a_small) -= D (x(flag_a_small), a(flag_a_small) - 1) + ...
           D (x(flag_a_small), a(flag_a_small) - 2);
    elseif (strcmpi (tail, "scaledlower"))
      y(flag_a_small) = y(flag_a_small) .* (x(flag_a_small) .^ 2) ./ ...
        (a(flag_a_small) .* (a(flag_a_small) - 1)) + (x(flag_a_small) ./ ...
          (a(flag_a_small) - 1)) + 1;
    elseif (strcmpi (tail, "scaledupper"))
      y(flag_a_small) = y(flag_a_small) .* (x(flag_a_small) .^ 2) ./ ...
        (a(flag_a_small) .* (a(flag_a_small) - 1)) - (x(flag_a_small) ./ ...
          (a(flag_a_small) - 1)) - 1;
     endif
  endif

endfunction

## Subfunctions to handle each case:

## x == 0, a == 0.
function y = newgammainc_00 (tail)
  if (strcmpi (tail, "upper") || strcmpi (tail, "scaledupper"))
    y = 0;
  else
    y = 1;
  endif
endfunction

## x == 0.
function y = newgammainc_x0 (tail)
  if (strcmpi (tail, "upper") || strcmpi (tail, "scaledlower"))
    y = 1;
  elseif (strcmpi (tail, "lower"))
    y = 0;
  else
    y = Inf;
  endif
endfunction

## x == Inf.
function y = newgammainc_x_inf (tail)
  if (strcmpi (tail, "lower"))
    y = 1;
  elseif (strcmpi (tail, "upper") || strcmpi (tail, "scaledupper"))
    y = 0;
  else
    y = Inf;
  endif
endfunction

## a == Inf.
function y = newgammainc_a_inf (tail)
  if (strcmpi (tail, "lower"))
    y = 0;
  elseif (strcmpi (tail, "upper") || strcmpi (tail, "scaledlower"))
    y = 1;
  else
    y = Inf;
  endif
endfunction

## a == 0.
function y = newgammainc_a0 (x, tail)
  if (strcmpi (tail, "lower"))
    y = 1;
  elseif (strcmpi (tail, "scaledlower"))
    y = exp (x);
  else
    y = 0;
  endif
endfunction

## a == 1.
function y = newgammainc_a1 (x, tail)
  if (strcmpi (tail, "lower"))
    y = 1 - exp (-x);
  elseif (strcmpi (tail, "scaledlower"))
    if (abs (x) < 1/2)
      y = expm1 (x) ./ x;
    else
      y = (exp (x) - 1) ./ x;
    endif
  elseif (strcmpi (tail, "upper"))
    y = exp (-x);
  else
    y = 1 ./ x;
  endif
endfunction

## positive integer a; exp (x) and a! both under 1/eps
## uses closed-form expressions for nonnegative integer a
## -- http://mathworld.wolfram.com/IncompleteGammaFunction.html.
function y = newgammainc_an (x, a, tail)
  y = t = ones (size (x), class (x));
  i = 1;
  while (any (a(:) > i))
    jj = (a > i);
    t(jj) .*= (x(jj) / i);
    y(jj) += t(jj);
    i++;
  endwhile
  if (strcmpi (tail, "upper"))
    y .*= exp (-x);
  elseif (strcmpi (tail, "lower"))
    y = 1 - exp (-x) .* y;
  elseif (strcmpi (tail, "scaledupper"))
    y .*= exp (-x) ./ D(x, a);
  elseif (strcmpi (tail, "scaledlower"))
    y = (1 - exp (-x) .* y) ./ D(x, a);
  endif
endfunction

## x + 0.25 < a | x < 0 | x not real | abs(x) < 1 | a < 5.
## Numerical Recipes in Fortran 77 (6.2.5)
## series
function y = newgammainc_s (x, a, tail)
  if (strcmpi (tail, "scaledlower") || strcmpi (tail, "scaledupper"))
    y = ones (size (x), class (x));
    term = x ./ (a + 1);
  else
    ## Of course it is possible to scale at the end, but some tests fail.
    ## And try newgammainc (1,1000), it take 0 iterations if you scale now.
    y = D (x,a);
    term = y .* x ./ (a + 1);
  endif
  n = 1;
  while (any (abs (term(:)) > abs (y(:)) * eps))
    ## y can be zero from the beginning (newgammainc (1,1000))
    jj = abs (term) > abs (y) * eps;
    n += 1;
    y(jj) += term(jj);
    term(jj) .*= x(jj) ./ (a(jj) + n);
  endwhile
  if (strcmpi (tail, "upper"))
    y = 1 - y;
  elseif (strcmpi (tail, "scaledupper"))
    y = 1 ./ D (x,a) - y;
  endif
endfunction

## x positive and large relative to a
## NRF77 (6.2.7)
## Gamma (a,x)/Gamma (a)
## Lentz's algorithm
## __newgammainc_lentz__ in libinterp/corefcn/__newgammainc_lentz__.cc
function y = newgammainc_l (x, a, tail)
    n = numel (x);
    y = zeros (size (x), class (x));
    for i = 1:n
      y(i) = __newgammainc_lentz__ (x(i), a(i));
    endfor
    if (strcmpi (tail, "upper"))
      y .*= D (x, a);
    elseif (strcmpi (tail,  "lower"))
      y = 1 - y .* D (x, a);
    elseif (strcmpi (tail, "scaledlower"))
      y = 1 ./ D (x, a) - y;
    endif
  endfunction

function y = D (x, a)
  ##  Compute exp(-x)*x^a/Gamma(a+1) in a stable way for x and a large.
  ##
  ## L. Knusel, Computation of the Chi-square and Poisson distribution,
  ## SIAM J. Sci. Stat. Comput., 7(3), 1986
  ## which quotes Section 5, Abramowitz&Stegun 6.1.40, 6.1.41.
  athresh = 10; ## FIXME: can be better tuned?
  y = zeros (size (x), class (x));
  i_done = false (size (x));
  i_done(x == 0) = true;
  ii = ((! i_done) & (x > 0) & (a > athresh) & (a >= x));
  if (any (ii(:)))
    lnGa = log (2 * pi * a(ii)) / 2 + 1 ./ (12 * a(ii)) - ...
           1 ./ (360 * a(ii) .^ 3) + 1 ./ (1260 * a(ii) .^ 5) - ...
           1 ./ (1680 * a(ii) .^ 7) + 1 ./ (1188 * a(ii) .^ 9)- ...
           691 ./ (87360 * a(ii) .^ 11) + 1 ./ (156 * a(ii) .^ 13) - ...
           3617 ./ (122400 * a(ii) .^ 15) + ...
           43867 ./ (244188 * a(ii) .^ 17) - 174611 ./ (125400 * a(ii) .^ 19);
    lns = log1p ((a(ii) - x(ii)) ./ x(ii));
    y(ii) = exp ((a(ii) - x(ii)) - a(ii) .* lns - lnGa);
    i_done(ii) = true;
  endif
  ii = ((! i_done) & (x > 0) & (a > athresh) & (a < x));
  if (any (ii(:)))
    lnGa = log (2 * pi * a(ii)) / 2 + 1 ./ (12 * a(ii)) - ...
           1 ./ (360 * a(ii) .^ 3) + 1 ./ (1260 * a(ii) .^ 5) - ...
           1 ./ (1680 * a(ii) .^ 7) + 1 ./ (1188 * a(ii) .^ 9)- ...
           691 ./ (87360 * a(ii) .^ 11) + 1 ./ (156 * a(ii) .^ 13) - ...
           3617 ./ (122400 * a(ii) .^ 15) + ...
           43867 ./ (244188 * a(ii) .^ 17) - 174611 ./ (125400 * a(ii) .^ 19);
    lns = -log1p ((x(ii) - a(ii)) ./ a(ii));
    y(ii) = exp ((a(ii) - x(ii)) - a(ii) .* lns - lnGa);
    i_done(ii) = true;
  endif
  ii = ((! i_done) & ((x <= 0) | (a <= athresh)));
  if (any (ii(:))) ## standard formula for a not so large.
    y(ii) = exp (a(ii) .* log (x(ii)) - x(ii) - gammaln (a(ii) + 1));
    i_done(ii) = true;
  endif
  ii = ((x < 0) & (a == fix (a)));
  if any(ii(:)) ## remove spurious imaginary part.
    y(ii) = real (y(ii));
  endif
endfunction

## Test: case 1,2,5
%!test
%! assert (newgammainc ([0, 0, 1], [0, 1, 0]), [1, 0, 1]);
%!test
%! assert (newgammainc ([0, 0, 1], [0, 1, 0], "upper"), [0, 1, 0]);
%!test
%! assert (newgammainc ([0, 0, 1], [0, 1, 0], "scaledlower"), [1, 1, exp(1)]);
%!test
%! assert (newgammainc ([0, 0, 1], [0, 1, 0], "scaledupper"), [0, Inf, 0]);

## Test: case 3,4
%!test
%! assert (newgammainc ([2, Inf], [Inf, 2]), [0, 1]);
%!test
%! assert (newgammainc ([2, Inf], [Inf, 2], "upper"), [1, 0]);
%!test
%! assert (newgammainc ([2, Inf], [Inf, 2], "scaledlower"), [1, Inf]);
%!test
%! assert (newgammainc ([2, Inf], [Inf, 2], "scaledupper"), [Inf, 0]);

## Test: case 5
%!test
%!  % Here Matlab fails
%! assert (newgammainc (-100,1,"upper"),exp (100),-eps);

## Test: case 6
%!test
%! assert (newgammainc ([1, 2, 3], 1), 1 - exp (-[1, 2, 3]));
%!test
%! assert (newgammainc ([1, 2, 3], 1, "upper"), exp (- [1, 2, 3]));
%!test
%! assert (newgammainc ([1, 2, 3], 1, "scaledlower"), ...
%!      (exp ([1, 2, 3]) - 1) ./ [1, 2, 3]);
%! assert (newgammainc ([1, 2, 3], 1, "scaledupper"), 1 ./ [1, 2, 3]);

## Test: case 7
%!test
%! assert (newgammainc (2, 2, "lower"), 0.593994150290162, -2e-15);
%!test
%! assert (newgammainc (2, 2, "upper"), 0.406005849709838, -2e-15);
%!test
%! assert (newgammainc (2, 2, "scaledlower"), 2.194528049465325, -2e-15);
%!test
%! assert (newgammainc (2, 2, "scaledupper"), 1.500000000000000, -2e-15);
%!test
%! assert (newgammainc ([3 2 36],[2 3 18], "upper"),...
%!      [4/exp(3) 5*exp(-2) (4369755579265807723 / 2977975)/exp(36)]);
%!test
%! assert (newgammainc (10, 10), 1 - (5719087 / 567) * exp (-10), -eps);
%!test
%! assert (newgammainc (10, 10, "upper"), (5719087 / 567) * exp (-10), -eps);

## Test: case 8
%!test
%! assert (newgammainc (-10, 10), 3.112658265341493126871617e7, -2 * eps);
%!test
%!  % Here Matlab fails
%! assert (isreal (newgammainc (-10, 10)), true);
%!test
%! assert (newgammainc (-10, 10.1, "upper"),...
%!         -2.9582761911890713293e7-1i * 9.612022339061679758e6,-30 * eps);
%!test
%! assert (newgammainc (-10, 10, "upper"), -3.112658165341493126871616e7, ...
%!         -2 * eps);
%!test
%! assert (newgammainc (-10, 10, "scaledlower"), ...
%!       0.5128019364747265,-1e-14);
%!test
%! assert (newgammainc (-10, 10, "scaledupper"), ...
%!       -0.5128019200000000, -1e-14);
%!test
%! assert (newgammainc (200, 201, "upper"),...
%!       0.518794309678684497, -2 * eps);
%!test
%! assert (newgammainc (200, 201, "scaledupper"), ...
%!       18.4904360746560462660798514, -eps);
%!test
%!  % here we are very good (no D (x,a)) involved
%! assert (newgammainc(1000, 1000.5, "scaledlower"), 39.48467539583672271, ...
%!         -2* eps);
%!test
%! assert (newgammainc (709, 1000, "upper"), ...
%!       0.99999999999999999999999954358, -eps);

## Test: case 9
%!test <47800>
%! assert (newgammainc (60, 6, "upper"), ...
%!       6.18022358081160257327264261e-20, -10 * eps);
%!test
%!  % Here Matlab is better
%! assert (newgammainc (751, 750, "upper"),...
%!      0.4805914320558831327179457887, -12 * eps);
%!test
%! assert (newgammainc (200, 200, "upper"), 0.49059658199276367497217454, ...
%!      -4 * eps);
%!test
%! assert (newgammainc (200, 200), 0.509403418007236325027825459574527043, ...
%!      -3 * eps);
%!test
%! assert (newgammainc (200, 200, "scaledupper"), 17.3984438553791505135122900, ...
%!      -eps);
%!test
%! assert (newgammainc (200, 200, "scaledlower"), 18.065406676779221643065, ...
%!      -6 * eps);
%!test
%! assert (newgammainc (201, 200, "upper"), 0.46249244908276709524913736667,...
%!      -7 * eps);

## Test small argument
%!test
%! assert (newgammainc ([1e-05, 1e-07,1e-10,1e-14], 0.1), ...
%!      [0.33239840504050, 0.20972940370977, 0.10511370061022, ...
%!      0.041846517936723], 1e-13);

%!test
%! assert (newgammainc ([1e-05, 1e-07,1e-10,1e-14], 0.2), ...
%!      [0.10891226058559, 0.043358823442178, 0.010891244210402, ...
%!      0.0017261458806785], 1e-13);

%!test
%! assert (newgammainc ([1e-02, 1e-03, 1e-5, 1e-9, 1e-14], 0.9), ...
%!      [0.016401189184068, 0.0020735998660840, 0.000032879756964708, ...
%!      8.2590606569241e-9, 2.6117443021738e-13], -1e-12);

%!test
%! assert (newgammainc ([1e-02, 1e-03, 1e-5, 1e-9, 1e-14], 2), ...
%!      [0.0000496679133402659, 4.99666791633340e-7, 4.99996666679167e-11, ...
%!      4.99999999666667e-19, 4.99999999999997e-29], -1e-12);

%!xtest
%! assert (newgammainc (-20, 1.1, "upper"),...
%!      6.50986687074979e8 + 2.11518396291149e8*i, -1e-13);

## Test on the conservation of the class, five tests for each subroutine
%!assert (class (newgammainc (0, 1)) == "double")
%!assert (class (newgammainc (single (0), 1)) == "single")
%!assert (class (newgammainc (int8 (0), 1)) == "double")
%!assert (class (newgammainc (0, single (1))) == "single")
%!assert (class (newgammainc (0, int8 (1))) == "double")
%!assert (class (newgammainc (1, 0)) == "double")
%!assert (class (newgammainc (single (1), 0)) == "single")
%!assert (class (newgammainc (int8 (1), 0)) == "double")
%!assert (class (newgammainc (1, single (0))) == "single")
%!assert (class (newgammainc (1, int8 (0))) == "double")
%!assert (class (newgammainc (1, 1)) == "double")
%!assert (class (newgammainc (single (1), 1)) == "single")
%!assert (class (newgammainc (int8 (1), 1)) == "double")
%!assert (class (newgammainc (1, single (1))) == "single")
%!assert (class (newgammainc (1, int8(1))) == "double")
%!assert (class (newgammainc (1, 2)) == "double")
%!assert (class (newgammainc (single (1), 2)) == "single")
%!assert (class (newgammainc (int8 (1), 2)) == "double")
%!assert (class (newgammainc (1, single (2))) == "single")
%!assert (class (newgammainc (1, int8 (2))) == "double")
%!assert (class (newgammainc (-1, 0.5)) == "double")
%!assert (class (newgammainc (single (-1), 0.5)) == "single")
%!assert (class (newgammainc (int8 (-1), 0.5)) == "double")
%!assert (class (newgammainc (-1, single (0.5))) == "single")
%!assert (class (newgammainc (-1, int8 (0.5))) == "double")
%!assert (class (newgammainc (1, 0.5)) == "double")
%!assert (class (newgammainc (single (1), 0.5)) == "single")
%!assert (class (newgammainc (int8 (1), 0.5)) == "double")
%!assert (class (newgammainc (1, single (0.5))) == "single")
%!assert (class (newgammainc (1, int8 (0.5))) == "double")

## Test input validation
%!error newgammainc ()
%!error newgammainc (1)
%!error newgammainc (1,2,3,4)
%!error newgammainc (1, [0, 1i,1])
%!error newgammainc (1, [0, -1, 1])
%!error newgammainc ([0 0],[0; 0])
%!error newgammainc ([1 2 3], [1 2])
%!error newgammainc (1i,1)
%!error newgammainc (1,1i)
