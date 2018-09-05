#pragma once

//////////////////////////////////////////////////////////////////////////
// Given a function or callable type 'fun', returns an object with 
// a void operator(P ptr) that calls fun(&ptr)
// Useful for passing C API function as deleters to shared_ptr<> which require ** instead of *.
template <typename Fun>
struct arg_ref_adaptor_functor 
{
public:
   arg_ref_adaptor_functor(Fun fun): fun(fun) {}

   template <typename P> 
   void operator()(P ptr) 
   { fun(&ptr); }

private:
//    typename boost::decay<Fun>::type fun;
   Fun fun;
};

template <typename Fun>
inline arg_ref_adaptor_functor<Fun> arg_ref_adaptor(Fun fun)
{  return arg_ref_adaptor_functor<Fun>(fun); }

