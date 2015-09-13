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