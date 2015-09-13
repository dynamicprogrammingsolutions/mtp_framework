//+------------------------------------------------------------------+
//|                                                  accountinfo.mqh |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

string AccountCompany()
{
   return(AccountInfoString(ACCOUNT_COMPANY));
}

string AccountName()
{
   return(AccountInfoString(ACCOUNT_NAME));
}

long AccountNumber()
{
   return(AccountInfoInteger(ACCOUNT_LOGIN));
}

string AccountCurrency()
{
   return(AccountInfoString(ACCOUNT_CURRENCY));
}

double AccountBalance()
{
   return(AccountInfoDouble(ACCOUNT_BALANCE));
}

double AccountEquity()
{
   return(AccountInfoDouble(ACCOUNT_EQUITY));
}

bool IsDemo()
{
if(AccountInfoInteger(ACCOUNT_TRADE_MODE)==ACCOUNT_TRADE_MODE_DEMO)
   return(true);
else
   return(false);
}

bool IsTesting()
{
   return(MQL5InfoInteger(MQL5_TESTING));
}

bool IsVisualMode()
{
   return(MQL5InfoInteger(MQL5_VISUAL_MODE));
}

double AccountFreeMargin()
{
   return(AccountInfoDouble(ACCOUNT_FREEMARGIN));
}

ushort AccountLeverage()
{
   return((ushort)AccountInfoInteger(ACCOUNT_LEVERAGE));
}

