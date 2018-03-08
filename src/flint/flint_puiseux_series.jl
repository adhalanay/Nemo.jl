###############################################################################
#
#   flint_puiseux_series.jl : Puiseux series over Flint rings and fields
#
###############################################################################

export PuiseuxSeriesRing, laurent_ring, rescale!

###############################################################################
#
#   Data type and parent object methods
#
###############################################################################

doc"""
    laurent_ring{T <: RingElement}(R::PuiseuxSeriesRing{T})
> Return the `LaurentSeriesRing` underlying the given `PuiseuxSeriesRing`.
""" 
laurent_ring(R::FlintPuiseuxSeriesRing{T}) where T <: RingElem = R.laurent_ring::parent_type(T)

doc"""
    laurent_ring{T <: FieldElement}(R::PuiseuxSeriesField{T})
> Return the `LaurentSeriesField` underlying the given `PuiseuxSeriesField`.
"""
laurent_ring(R::FlintPuiseuxSeriesField{T}) where T <: FieldElem = R.laurent_ring::parent_type(T)

doc"""
    O{T <: RingElement}(a::PuiseuxSeriesElem{T})
> Returns $0 + O(x^\mbox{val}(a))$. Usually this function is called with $x^n$
> as parameter for some rational $n$. Then the function returns the Puiseux series
> $0 + O(x^n)$, which can be used to set the precision of a Puiseux series when
> constructing it.
"""
function O(a::FlintPuiseuxSeriesElem{T}) where T <: RingElem
   val = valuation(a)
   par = parent(a)
   x = gen(laurent_ring(par))
   laur = O(x^numerator(val))
   return parent(a)(laur, denominator(val))
end

parent_type(::Type{T}) where {S <: RingElem, T <: FlintPuiseuxSeriesRingElem{S}} = FlintPuiseuxSeriesRing{S}

parent_type(::Type{T}) where {S <: FieldElem, T <: FlintPuiseuxSeriesFieldElem{S}} = FlintPuiseuxSeriesField{S}

doc"""
    parent(a::PuiseuxSeriesElem)
> Return the parent of the given Puiseux series.
"""
parent(a::FlintPuiseuxSeriesElem) = a.parent

elem_type(::Type{T}) where {S <: RingElem, T <: FlintPuiseuxSeriesRing{S}} = FlintPuiseuxSeriesRingElem{S}

elem_type(::Type{T}) where {S <: FieldElem, T <: FlintPuiseuxSeriesField{S}} = FlintPuiseuxSeriesFieldElem{S}

doc"""
    base_ring(R::FlintPuiseuxSeriesRing)
> Return the base (coefficient) ring of the given Puiseux series ring.
"""
base_ring(R::FlintPuiseuxSeriesRing{T}) where T <: RingElem = base_ring(laurent_ring(R))

doc"""
    base_ring(R::FlintPuiseuxSeriesField)
> Return the base (coefficient) ring of the given Puiseux series field.
"""
base_ring(R::FlintPuiseuxSeriesField{T}) where T <: FieldElem = base_ring(laurent_ring(R))

doc"""
    base_ring(a::PuiseuxSeriesElem)
> Return the base (coefficient) ring of the Puiseux series ring of the given Puiseux
> series.
"""
base_ring(a::FlintPuiseuxSeriesElem) = base_ring(parent(a))

function isdomain_type(::Type{T}) where {S <: RingElem, T <: FlintPuiseuxSeriesElem{S}}
   return isdomain_type(S)
end

isexact_type(a::Type{T}) where T <: FlintPuiseuxSeriesElem = false

function check_parent(a::FlintPuiseuxSeriesElem, b::FlintPuiseuxSeriesElem)
   parent(a) != parent(b) &&
             error("Incompatible Puiseux series rings in Puiseux series operation")
end

###############################################################################
#
#   Basic manipulation
#
###############################################################################

function Base.hash(a::FlintPuiseuxSeriesElem, h::UInt)
   b = 0xec4c3951832c37f0%UInt
   b = xor(b, hash(a.data, h))
   b = xor(b, hash(a.scale, h))
   return b
end

doc"""
    precision(a::FlintPuiseuxSeriesElem)
> Return the precision of the given Puiseux series in absolute terms.
"""
precision(a::FlintPuiseuxSeriesElem) = precision(a.data)//a.scale

doc"""
    valuation(a::FlintPuiseuxSeriesElem)
> Return the valuation of the given Puiseux series, i.e. the exponent of the first
> nonzero term (or the precision if it is arithmetically zero).
"""
valuation(a::FlintPuiseuxSeriesElem) = valuation(a.data)//a.scale

doc"""
    zero(R::FlintPuiseuxSeriesRing)
> Return $0 + O(x^n)$ where $n$ is the maximum precision of the Puiseux series
> ring $R$.
"""
zero(R::FlintPuiseuxSeriesRing) = R(0)

doc"""
    zero(R::FlintPuiseuxSeriesField)
> Return $0 + O(x^n)$ where $n$ is the maximum precision of the Puiseux series
> ring $R$.
"""
zero(R::FlintPuiseuxSeriesField) = R(0)

doc"""
    one(R::FlintPuiseuxSeriesRing)
> Return $1 + O(x^n)$ where $n$ is the maximum precision of the Puiseux series
> ring $R$.
"""
one(R::FlintPuiseuxSeriesField) = R(1)

doc"""
    one(R::FlintPuiseuxSeriesField)
> Return $1 + O(x^n)$ where $n$ is the maximum precision of the Puiseux series
> ring $R$.
"""
one(R::FlintPuiseuxSeriesRing) = R(1)

doc"""
    gen(R::FlintPuiseuxSeriesRing)
> Return the generator of the Puiseux series ring, i.e. $x + O(x^{n + 1})$ where
> $n$ is the maximum precision of the Puiseux series ring $R$.
"""
function gen(R::FlintPuiseuxSeriesRing)
   S = laurent_ring(R)
   return R(gen(S), 1)
end

doc"""
    gen(R::FlintPuiseuxSeriesField)
> Return the generator of the Puiseux series ring, i.e. $x + O(x^{n + 1})$ where
> $n$ is the maximum precision of the Puiseux series ring $R$.
"""
function gen(R::FlintPuiseuxSeriesField)
   S = laurent_ring(R)
   return R(gen(S), 1)
end

doc"""
    iszero(a::FlintPuiseuxSeriesElem)
> Return `true` if the given Puiseux series is arithmetically equal to zero to
> its current precision, otherwise return `false`.
"""
iszero(a::FlintPuiseuxSeriesElem) = iszero(a.data)

doc"""
    isone(a::FlintPuiseuxSeriesElem)
> Return `true` if the given Puiseux series is arithmetically equal to one to
> its current precision, otherwise return `false`.
"""
function isone(a::FlintPuiseuxSeriesElem)
   return isone(a.data)
end

doc"""
    isgen(a::FlintPuiseuxSeriesElem)
> Return `true` if the given Puiseux series is arithmetically equal to the
> generator of its Puiseux series ring to its current precision, otherwise return
> `false`.
"""
function isgen(a::FlintPuiseuxSeriesElem)
   return valuation(a) == 1 && pol_length(a.data) == 1 && isone(polcoeff(a.data, 0))
end

doc"""
    isunit(a::FlintPuiseuxSeriesElem)
> Return `true` if the given Puiseux series is arithmetically equal to a unit,
> i.e. is invertible, otherwise return `false`.
"""
isunit(a::FlintPuiseuxSeriesElem) = valuation(a) == 0 && isunit(polcoeff(a.data, 0))

doc"""
    modulus(a::PuiseuxSeriesElem)
> Return the modulus of the coefficients of the given Puiseux series.
"""
modulus(a::FlintPuiseuxSeriesElem) = modulus(base_ring(a))

doc"""
    rescale(a::FlintPuiseuxSeriesElem)
> Rescale so that the scale of the given Puiseux series and the scale of the underlying
> Laurent series are coprime. This function is used internally, as all user facing
> functions are assumed to rescale their output.
"""
function rescale!(a::FlintPuiseuxSeriesElem)
   if !iszero(a)
      d = gcd(a.scale, gcd(scale(a.data), gcd(valuation(a.data), precision(a.data))))
      if d != 1
         set_scale!(a.data, div(scale(a.data), d))
         set_prec!(a.data, div(precision(a.data), d))
         set_val!(a.data, div(valuation(a.data), d))
         a.scale = div(a.scale, d)
      end
   end
   return a
end

function deepcopy_internal(a::FlintPuiseuxSeriesElem, dict::ObjectIdDict)
    return parent(a)(deepcopy(a.data), a.scale)
end

###############################################################################
#
#   AbstractString I/O
#
###############################################################################

function show(io::IO, x::FlintPuiseuxSeriesElem)
   len = pol_length(x.data)
   if len == 0
      print(io, zero(base_ring(x)))
   else
      coeff_printed = false
      sc = scale(x.data)
      den = x.scale
      for i = 0:len - 1
         c = polcoeff(x.data, i)
         bracket = needs_parentheses(c)
         if !iszero(c)
            if coeff_printed && !isnegative(c)
               print(io, "+")
            end
            if i*sc + valuation(x.data) != 0
               if !isone(c) && (c != -1 || show_minus_one(elem_type(base_ring(x))))
                  if bracket
                     print(io, "(")
                  end
                  print(io, c)
                  if bracket
                     print(io, ")")
                  end
                  if i*sc + valuation(x.data) != 0
                     print(io, "*")
                  end
               end
               if c == -1 && !show_minus_one(elem_type(base_ring(x)))
                  print(io, "-")
               end
               print(io, string(var(parent(x.data))))
               if (i*sc + valuation(x.data))//den != 1
                  print(io, "^")
                  q = (valuation(x.data) + i*sc)//den
                  print(io, denominator(q) == 1 ? numerator(q) : q)
               end
            else
               print(io, c)
            end
            coeff_printed = true
         end
      end
   end
   q =  precision(x.data)//x.scale
   print(io, "+O(", string(var(parent(x.data))), "^", denominator(q) == 1 ? numerator(q) : q, ")")
end

function show(io::IO, a::FlintPuiseuxSeriesRing)
   print(io, "Puiseux series ring in ", var(laurent_ring(a)), " over ")
   show(io, base_ring(a))
end

function show(io::IO, a::FlintPuiseuxSeriesField)
   print(io, "Puiseux series field in ", var(laurent_ring(a)), " over ")
   show(io, base_ring(a))
end

needs_parentheses(x::FlintPuiseuxSeriesElem) = pol_length(x.data) > 1

isnegative(x::FlintPuiseuxSeriesElem) = pol_length(x) <= 1 && isnegative(polcoeff(x.data, 0))

show_minus_one(::Type{FlintPuiseuxSeriesElem{T}}) where T <: RingElem = show_minus_one(T)

###############################################################################
#
#   Unary operators
#
###############################################################################

function -(a::FlintPuiseuxSeriesElem)
   R = parent(a)
   return R(-a.data, a.scale)
end

###############################################################################
#
#   Binary operators
#
###############################################################################

function +(a::FlintPuiseuxSeriesElem{T}, b::FlintPuiseuxSeriesElem{T}) where T <: RingElem
    s = gcd(a.scale, b.scale)
    zscale = div(a.scale*b.scale, s)
    ainf = div(a.scale, s)
    binf = div(b.scale, s)
    z = parent(a)(inflate(a.data, binf) + inflate(b.data, ainf), zscale)
    z = rescale!(z)
    return z
end

function -(a::FlintPuiseuxSeriesElem{T}, b::FlintPuiseuxSeriesElem{T}) where T <: RingElem
    s = gcd(a.scale, b.scale)
    zscale = div(a.scale*b.scale, s)
    ainf = div(a.scale, s)
    binf = div(b.scale, s)
    z = parent(a)(inflate(a.data, binf) - inflate(b.data, ainf), zscale)
    z = rescale!(z)
    return z
end

function *(a::FlintPuiseuxSeriesElem{T}, b::FlintPuiseuxSeriesElem{T}) where T <: RingElem
    s = gcd(a.scale, b.scale)
    zscale = div(a.scale*b.scale, s)
    ainf = div(a.scale, s)
    binf = div(b.scale, s)
    z = parent(a)(inflate(a.data, binf)*inflate(b.data, ainf), zscale)
    z = rescale!(z)
    return z
end

###############################################################################
#
#   Exact division
#
###############################################################################

function divexact(a::FlintPuiseuxSeriesElem{T}, b::FlintPuiseuxSeriesElem{T}) where T <: RingElem
    s = gcd(a.scale, b.scale)
    zscale = div(a.scale*b.scale, s)
    ainf = div(a.scale, s)
    binf = div(b.scale, s)
    z = parent(a)(divexact(inflate(a.data, binf), inflate(b.data, ainf)), zscale)
    z = rescale!(z)
    return z
end

###############################################################################
#
#   Powering
#
###############################################################################

function ^(a::FlintPuiseuxSeriesElem{T}, b::Int) where T <: RingElem
   # special case powers of x for constructing power series efficiently
   if iszero(a.data)
      return parent(a)(a.data^0, a.scale)
   elseif b == 0
      # in fact, the result would be exact 1 if we had exact series
      return one(parent(a))
   elseif pol_length(a.data) == 1
      return parent(a)(a.data^b, a.scale)
   elseif b == 1
      return deepcopy(a)
   elseif b == -1
      return inv(a)
   end

   if b < 0
      a = inv(a)
      b = -b
   end

   z = parent(a)(a.data^b, a.scale)
   z = rescale!(z)
   return z
end

function ^(a::FlintPuiseuxSeriesElem{T}, b::Rational{Int}) where T <: RingElement
   (pol_length(a.data) != 1 || polcoeff(a.data, 0) != 1) && error("Rational power not implemented")
   z = parent(a)(a.data^numerator(b), a.scale*denominator(b))
   z = rescale!(z)
   return z
end

###############################################################################
#
#   Special functions
#
###############################################################################

doc"""
    eta_qexp(x::FlintPuiseuxSeriesElem{fmpz_laurent_series})
> Return the $q$-series for eta evaluated at $x$, which must currently be a rational
> power of the generator of the Puiseux series ring.
"""
function eta_qexp(x::FlintPuiseuxSeriesElem{fmpz_laurent_series})
   v = valuation(x)
   d = eta_qexp(x.data)
   z = parent(x)(d, x.scale)
   return z*x^(1//24)
end

###############################################################################
#
#   Promotion rules
#
###############################################################################

promote_rule(::Type{FlintPuiseuxSeriesRingElem{T}}, ::Type{FlintPuiseuxSeriesRingElem{T}}) where T <: RingElem = FlintPuiseuxSeriesRingElem{T}

promote_rule(::Type{FlintPuiseuxSeriesFieldElem{T}}, ::Type{FlintPuiseuxSeriesFieldElem{T}}) where T <: RingElem = FlintPuiseuxSeriesRingElem{T}

function promote_rule(::Type{FlintPuiseuxSeriesRingElem{T}}, ::Type{U}) where {T <: RingElem, U <: RingElement}
   promote_rule(T, U) == T ? FlintPuiseuxSeriesRingElem{T} : Union{}
end

function promote_rule(::Type{FlintPuiseuxSeriesFieldElem{T}}, ::Type{U}) where {T <: RingElem, U <: RingElement}
   promote_rule(T, U) == T ? FlintPuiseuxSeriesFieldElem{T} : Union{}
end

###############################################################################
#
#   Parent object call overload
#
###############################################################################

function (R::FlintPuiseuxSeriesRing{T})(b::RingElement) where T <: RingElem
   return R(base_ring(R)(b))
end

function (R::FlintPuiseuxSeriesField{T})(b::RingElement) where T <: RingElem
   return R(base_ring(R)(b))
end

function (R::FlintPuiseuxSeriesRing{T})() where T <: RingElem
   z = FlintPuiseuxSeriesRingElem{T}(laurent_ring(R)(), 1)
   z.parent = R
   return z
end

function (R::FlintPuiseuxSeriesField{T})() where T <: RingElem
   z = FlintPuiseuxSeriesFieldElem{T}(laurent_ring(R)(), 1)
   z.parent = R
   return z
end

function (R::FlintPuiseuxSeriesRing{T})(b::T, scale::Int) where T <: RingElem
   z = FlintPuiseuxSeriesRingElem{T}(b, scale)
   z.parent = R
   return z
end

function (R::FlintPuiseuxSeriesField{T})(b::T, scale::Int) where T <: RingElem
   z = FlintPuiseuxSeriesFieldElem{T}(b, scale)
   z.parent = R
   return z
end

function (R::FlintPuiseuxSeriesRing{T})(b::Union{Integer, Rational}) where T <: RingElem
   z = FlintPuiseuxSeriesRingElem{T}(laurent_ring(R)(b), 1)
   z.parent = R
   return z
end

function (R::FlintPuiseuxSeriesField{T})(b::Rational) where T <: RingElem
   z = FlintPuiseuxSeriesFieldElem{T}(laurent_ring(R)(b), 1)
   z.parent = R
   return z
end

function (R::FlintPuiseuxSeriesRing{T})(b::T) where T <: RingElem
   parent(b) != base_ring(R) && error("Unable to coerce to Puiseux series")
   z = FlintPuiseuxSeriesRingElem{T}(laurent_ring(R)(b), 1)
   z.parent = R
   return z
end

function (R::FlintPuiseuxSeriesField{T})(b::T) where T <: FieldElem
   parent(b) != base_ring(R) && error("Unable to coerce to Puiseux series")
   z = FlintPuiseuxSeriesFieldElem{T}(laurent_ring(R)(b), 1)
   z.parent = R
   return z
end

function (R::FlintPuiseuxSeriesRing{T})(b::FlintPuiseuxSeriesRingElem{T}) where T <: RingElem
   parent(b) != R && error("Unable to coerce Puiseux series")
   return b
end

function (R::FlintPuiseuxSeriesField{T})(b::FlintPuiseuxSeriesRingElem{T}) where T <: RingElem
   parent(b) != R && error("Unable to coerce Puiseux series")
   return b
end

###############################################################################
#
#   PuiseuxSeriesRing constructor
#
###############################################################################

doc"""
   PuiseuxSeriesRing(R::FlintIntegerRing, prec::Int, s::AbstractString; cached=true)
> Return a tuple $(S, x)$ consisting of the parent object `S` of a Puiseux series
> ring over the given base ring and a generator `x` for the Puiseux series ring.
> The maximum precision of the series in the ring is set to `prec`. This is taken as a
> maximum relative precision of the underlying Laurent series that are used to implement
> the Puiseux series in the ring. The supplied string `s` specifies the way the
> generator of the Puiseux series ring will be printed. By default, the parent
> object `S` will be cached so that supplying the same base ring, string and
> precision in future will return the same parent object and generator. If
> caching of the parent object is not required, `cached` can be set to `false`.
"""
function PuiseuxSeriesRing(R::FlintIntegerRing, prec::Int, s::AbstractString; cached=true)
   S, x = LaurentSeriesRing(R, prec, s; cached=cached)

   parent_obj = FlintPuiseuxSeriesRing{fmpz_laurent_series}(S, cached)

   return parent_obj, gen(parent_obj)
end
