//+------------------------------------------------------------------+
//|                                              moneymanagement.mq4 |
//|                                            Zoltan Laszlo Ferenci |
//|                              http://www.metatraderprogrammer.com |
//+------------------------------------------------------------------+
#property copyright "Zoltan Laszlo Ferenci"
#property link      "http://www.metatraderprogrammer.com"

bool addaccountbalance = true;
double addfixbalance = 0;

double accountbalance = 0;
double accountequity = 0;
double accountfreemargin = 0;

double commission = 0;
bool commission_aspercent = false;

double currencyrate_fix = 1;
string currencyrate_live = "";
bool currencyrate_live_reciproc = false;
double currencyrate = 1;

datetime mm_init_ticktime = 0;
string mminiterror = "moneymanagement.mqh has not been initalized!";

CSymbolInfoInterface* mm_symbol;

void moneymanagement_init(string __symbol)
{
   mm_symbol = global_app().symbolloader.LoadSymbol(__symbol);
   CSymbolInfoInterface* _symbol = mm_symbol;
   
   mm_init_ticktime = (datetime)SymbolInfoInteger(_symbol.Name(),SYMBOL_TIME);
   if (currencyrate_live != "")
   {
      currencyrate = (SymbolInfoDouble(currencyrate_live,SYMBOL_ASK)+SymbolInfoDouble(currencyrate_live,SYMBOL_BID))/2;
      if (currencyrate_live_reciproc)
         currencyrate = 1/currencyrate;
   }
   else
   {
      currencyrate = currencyrate_fix;
   }   

   accountbalance = addfixbalance;
   accountfreemargin = addfixbalance;
   accountequity = addfixbalance;
   if (addaccountbalance)
   {
      accountbalance += AccountBalance();
      accountequity += AccountEquity();
      accountfreemargin += AccountFreeMargin();
   }
   accountbalance = accountbalance/currencyrate;
   accountequity = accountequity/currencyrate;
   accountfreemargin = accountfreemargin/currencyrate;      
}

double commission_indist(double price = 0)
{
   CSymbolInfoInterface* _symbol = mm_symbol;

   if (price == 0)
   {
      price = _symbol.Bid();
   }
   if (commission_aspercent)
      return(price * (commission / 100));
   else {
      if (_symbol.LotValue() == 0) return 0;
      return(commission/_symbol.LotValue());
   }
}
//-------------------------

double mmgetlot_stoploss_req(double balance, int in_stoploss, double percent, double price = 0, double maxrisk = -1)
{
   CSymbolInfoInterface* _symbol = mm_symbol;

   mm_initalized_alert();
   if (in_stoploss <= 0) {
      Alert("mmgetlot_stoploss_req: stoploss cannot be 0"); return(0);
   }
   double risk = balance * (percent/100);
   if (maxrisk > 0 && risk > maxrisk) risk = maxrisk;
   
   /*if (isset(_symbol)) {
      if (_symbol.LotValue() == 0 || _symbol.TickSize() == 0) {
         string symbol_ = _symbol.Name();
         delete _symbol;
         loadsymbol(symbol_);
         if (_symbol.LotValue() == 0 || _symbol.TickSize() == 0) return 0;
      }
   }*/
   
   return((risk) / ((in_stoploss*_symbol.TickSize() + commission_indist(price)) * _symbol.LotValue()));
}


double mmgetlot_stoploss(int in_stoploss, double percent, double price = 0, double maxrisk = -1)
{
   CSymbolInfoInterface* _symbol = mm_symbol;
   mm_initalized_alert();
   return(_symbol.LotRound(mmgetlot_stoploss_req(accountbalance,in_stoploss,percent,price,maxrisk)));
}

double mmgetlot_slmargin(int in_stoploss, double percent, double price = 0)
{
   CSymbolInfoInterface* _symbol = mm_symbol;
   mm_initalized_alert();
   return(_symbol.LotRound(mmgetlot_stoploss_req(accountfreemargin,in_stoploss,percent,price)));
}

double mmgetlot_slequity(int in_stoploss, double percent, double price = 0)
{
   CSymbolInfoInterface* _symbol = mm_symbol;
   mm_initalized_alert();
   return(_symbol.LotRound(mmgetlot_stoploss_req(accountequity,in_stoploss,percent,price)));
}

//-------------------------

double mmgetlot_value_req(double balance, double multiple, double price = 0)
{
   CSymbolInfoInterface* _symbol = mm_symbol;

   mm_initalized_alert();
   if (price == 0)
   {
      price = _symbol.Bid();
   }
   return((balance*multiple)/(_symbol.LotValue()*price));
}


double mmgetlot_value(double multiple, double price = 0)
{
   CSymbolInfoInterface* _symbol = mm_symbol;

   mm_initalized_alert();
   return(_symbol.LotRound(mmgetlot_value_req(accountbalance,multiple,price)));
}

//-------------------------

double mmgetlot_balperlot_req(double balance,double balperlot)
{
   mm_initalized_alert();
   return(balance/balperlot);
}


double mmgetlot_balperlot(double balperlot)
{
   CSymbolInfoInterface* _symbol = mm_symbol;
   mm_initalized_alert();
   return(_symbol.LotRound(mmgetlot_balperlot_req(accountbalance,balperlot)));
}

//-------------------------
double mmgetlot_ref_balance(double lot_ref, double ref_balance, bool round = true)
{
   CSymbolInfoInterface* _symbol = mm_symbol;

   mm_initalized_alert();
   if (round)
      return(_symbol.LotRound(accountbalance*lot_ref/ref_balance));
   else
      return(accountbalance*lot_ref/ref_balance);
}

double mmgetlot_ref_equity(double lot_ref, double ref_balance, bool round = true)
{
   CSymbolInfoInterface* _symbol = mm_symbol;

   mm_initalized_alert();
   if (round)
      return(_symbol.LotRound(accountequity*lot_ref/ref_balance));
   else
      return(accountequity*lot_ref/ref_balance);
}

//-------0------------------

double mmgetlot_freemargin(double percent)
{
   mm_initalized_alert();
   
   CSymbolInfoInterface* _symbol = mm_symbol;

   double freemargin = AccountFreeMargin();
   int leverage = AccountLeverage();
   double value = freemargin*leverage*percent*0.01;
   Alert(freemargin," ",leverage," ",value," ",_symbol.LotValue());
   return(_symbol.LotRound(value/_symbol.LotValue()));
}  


bool mm_initalized()
{
   CSymbolInfoInterface* _symbol = mm_symbol;

   if (mm_init_ticktime == MarketInfo(_symbol.Name(),MODE_TIME))
      return(true);
   else
      return(false);
}

bool mm_initalized_alert(string text = "") //tested
{
   return true;
}