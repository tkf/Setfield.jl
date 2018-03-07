# If no constructor is defined explicitly, don't generate any
# inner-consturctor; let Julia generate the default constructor; i.e.,
# @settable should be a no-op.
@settable struct NoConstructor{A,B}
    b::B
end

@testset "NoConstructor" begin
    s1 = NoConstructor{:a,Int}(1)
    s2 = @set s1.b = 2
    @test s2 === NoConstructor{:a,Int}(2)
end

# If the position-only constructor is defined explicitly, don't
# generate any inner-consturctor; i.e., @settable should be a no-op.
@settable struct ExplicitConstructor{A,B}
    b::B
    ExplicitConstructor{A,B}(b::B) where {A,B} = new{A,B}(b)
end

@testset "ExplicitConstructor" begin
    s1 = ExplicitConstructor{:a,Int}(1)
    s2 = @set s1.b = 2
    @test s2 === ExplicitConstructor{:a,Int}(2)
end

# If non- position-only constructor is given, generate the
# position-only constructor from it.
@settable struct TypedConstructor{A,B}
    a::A
    b::B
    function TypedConstructor{A,B}(a::A; b::B=0) where {A,B}
        # This assertion has to be executed in the generated inner
        # constructor as well:
        @assert a > b
        return new{A,B}(a, b)
    end
end

@testset "TypedConstructor" begin
    s1 = TypedConstructor{Int,Int}(1)
    s2 = @set s1.b = -2
    @test s2 === TypedConstructor{Int,Int}(1,-2)
    @test_throws AssertionError @set s1.b = 2
end

@settable struct UntypedConstructor{A,B}
    a::A
    b::B
    function UntypedConstructor(a::A; b::B=0) where {A,B}
        # This assertion has to be executed in the generated inner
        # constructor as well:
        @assert a > b
        return new{A,B}(a, b)
    end
end
Setfield.constructor_of(::Type{<: UntypedConstructor}) = UntypedConstructor

@testset "UntypedConstructor" begin
    s1 = UntypedConstructor(1, 0)
    s2 = @set s1.b = -2
    @test s2 === UntypedConstructor(1, b=-2)
    @test_throws AssertionError @set s1.b = 2
end

# @settable must (1) choose a correct constructor for generating
# positional-only constructor and (2) do so without overriding
# existing constructor.
# https://github.com/jw3126/Setfield.jl/pull/18#discussion_r172649307
@settable struct ManyConstructors
    a
    b
    ManyConstructors(a; b=2) = new(a, b)
    ManyConstructors(a) = new(a, 1)  # must not be overridden
end

@testset "ManyConstructors" begin
    # The single-argument constructor must be the one defined by user.
    @test ManyConstructors(0) === ManyConstructors(0, b=1)

    s1 = ManyConstructors(0)
    s2 = @set s1.b = -2
    @test s2 === ManyConstructors(0, b=-2)
end
