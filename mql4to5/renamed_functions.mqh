//+------------------------------------------------------------------+
//|                                            renamed_functions.mqh |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

double StrToDouble(const string number_string)
{
   return(StringToDouble(number_string));
}

string DoubleToStr(double double_value, int _digits=8)
{
   return(DoubleToString(double_value, _digits));
}

string CharToStr(uchar c)
{
   return(CharToString(c));
}

string TimeToStr(datetime time,int flags=TIME_DATE|TIME_MINUTES)
{
   return(TimeToString(time,flags));
}

datetime StrToTime(string value)
{
   return(StringToTime(value));
}

template<typename T1, typename T2>
string MT4StringConcatenate(const T1 s1, const T2 s2)
{
   string result;
   StringConcatenate(result,s1,s2);
   return result;
}

template<typename T1, typename T2, typename T3>
string MT4StringConcatenate(const T1 s1, const T2 s2, const T3 s3)
{
   string result;
   StringConcatenate(result,s1,s2,s3);
   return result;
}

template<typename T1, typename T2, typename T3, typename T4>
string MT4StringConcatenate(const T1 s1, const T2 s2, const T3 s3, const T4 s4)
{
   string result;
   StringConcatenate(result,s1,s2,s3,s4);
   return result;
}

template<typename T1, typename T2, typename T3, typename T4, typename T5>
string MT4StringConcatenate(const T1 s1, const T2 s2, const T3 s3, const T4 s4, const T5 s5)
{
   string result;
   StringConcatenate(result,s1,s2,s3,s4,s5);
   return result;
}

template<typename T1, typename T2, typename T3, typename T4, typename T5, typename T6>
string MT4StringConcatenate(const T1 s1, const T2 s2, const T3 s3, const T4 s4, const T5 s5, const T6 s6)
{
   string result;
   StringConcatenate(result,s1,s2,s3,s4,s5,s6);
   return result;
}

template<typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7>
string MT4StringConcatenate(const T1 s1, const T2 s2, const T3 s3, const T4 s4, const T5 s5, const T6 s6, const T7 s7)
{
   string result;
   StringConcatenate(result,s1,s2,s3,s4,s5,s6,s7);
   return result;
}

template<typename T1, typename T2, typename T3, typename T4, typename T5, typename T6, typename T7, typename T8>
string MT4StringConcatenate(const T1 s1, const T2 s2, const T3 s3, const T4 s4, const T5 s5, const T6 s6, const T7 s7, const T8 s8)
{
   string result;
   StringConcatenate(result,s1,s2,s3,s4,s5,s6,s7,s8);
   return result;
}