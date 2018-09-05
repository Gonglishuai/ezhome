#pragma once
 
// A simple RAII resource releaser
// See http://the-witness.net/news/2012/11/scopeexit-in-c11/
// Note that the lambda in the macro captures its arguments, i.e. the external
// variables, by reference. This is OK for pointers but may not be OK for
// some other types.

template <typename F>
struct ScopeExit {
    ScopeExit(F f) : f(f) {}
    ~ScopeExit() { f(); }
    F f;
};

template <typename F>
ScopeExit<F> MakeScopeExit(F f) {
    return ScopeExit<F>(f);
};

#define STRING_JOIN2(arg1, arg2) DO_STRING_JOIN2(arg1, arg2)
#define DO_STRING_JOIN2(arg1, arg2) arg1 ## arg2
#define SCOPE_EXIT(code) \
    auto STRING_JOIN2(scope_exit_, __LINE__) = MakeScopeExit([&](){code;})
    