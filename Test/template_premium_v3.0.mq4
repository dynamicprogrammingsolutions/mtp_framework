//* Copyright notice: This software and it's parts including any included files, except the anything from the "lib" directory is made by and is property of Dynamic Programming Solutions Corporation,
//* while the strategy elements used in it is property of the customer. Any parts can be reused in later software which doesn't violate our Non-Disclosure Agreement.
//* 
//* Non-Disclosure Agreement:
//* We pledge to hold your trading system in confidence.
//* We will not resell your expert advisor that contains your trading ideas, nor will we publish your system specifications.
//* Receipt of your system specifications or other intellectual property by us will effectively constitute a Non-Disclosure Agreement.
//* We have no obligation with respect to such information where the information:
//* 1) was known to us prior to receiving any of the Confidential Information from the customer;
//* 2) has become publicly known through no wrongful act of Recipient;
//* 3) was received by us without breach of this Agreement from a third party without restriction as to the use and disclosure of the information;
//* 4) was independently developed by us without use of the Confidential Information 
//* 
//* The customer has the following rights:
//* 1) Use the software in any instances for personal matters
//* 2) Learn the code and change it
//* 3) Ask any other programmer to make changes, under Non-Disclosure Agreement on the usage of the source code.
//* 4) Resell this EA with possibility to provide the source code under Non-Disclosure Agreement.
//* 5) Make this sofwtare available on website as a free downloadable product WITHOUT providing the source code (i.e. only the ex4 file is downloadable)

#property copyright "Dynamic Programming Solutions Corp."
#property link      "http://www.metatraderprogrammer.com"

#define CUSTOM_SERVICES
#define CUSTOM_CLASSES

#include <mtp_framework_1.1\Loader.mqh>
#include <mtp_framework_1.1\DefaultServices.mqh>   

#include <mtp_framework_1.1\EntryMethod\EntryMethodBase.mqh>
#include <mtp_framework_1.1\ChartInfo\IsFirstTick.mqh>
#include <mtp_framework_1.1\Signals\Signal.mqh>
#include <mtp_framework_1.1\Signals\SignalManagerBase.mqh>
#include <mtp_framework_1.1\SymbolLoader\SymbolInfoVars.mqh>
#include <mtp_framework_1.1\Commands\OrderCommandHandlerBase.mqh>

#ifdef __MQL4__
#include <mtp_framework_1.1\libraries\comments.mqh>
#else
#include <mtp_framework_1.1\libraries\comments_MT5.mqh>
#endif

input double lotsize = 0.1;

input double stoploss = 20;
input double takeprofit = 40;
input int _bar = 1;
input ENUM_TIMEFRAMES timeframe = 0;

input bool reverse_strategy = false;
input bool trade_only_at_barclose = true;
input bool trade_only_signal_change = true;

input bool long_enabled = true;
input bool short_enabled = true;
input bool close_opposite_order = false;
input int maxorders = 1;

#ifdef __MQL4__
input bool sl_virtual = false;
input bool tp_virtual = false;
input bool vstops_draw_line = false;
input bool realstops_draw_line = false;
input bool orderbymarket = false;
input color cl_buy = Blue;
input color cl_sell = Red;
#endif

input int _magic = 1234;
input int slippage = 3;

input bool printcomment = false;

CMoneyManagement* mm;

class CSignal1 : public COpenSignal { public:
   double val1;
   double val2;
   virtual void CalculateValues() {
      val1 = iClose(symbol,timeframe,bar);
      val2 = iOpen(symbol,timeframe,bar);
   }
   virtual bool BuyCondition() { return (val1 > val2); }
   virtual bool SellCondition() { return (val1 < val2); }
   virtual void OnTick() {
      if (comments_enabled) addcomment("Signal: "+signaltext(this.signal)+"\n");
   }
};

class CClosesignal1 : public CCloseSignal { public:
   double val1;
   double val2;
   virtual void CalculateValues() {
      val1 = iClose(symbol,timeframe,bar);
      val2 = iOpen(symbol,timeframe,bar);
   }
   virtual bool CloseSellCondition() { return (val1 > val2); }
   virtual bool CloseBuyCondition() { return (val1 < val2); }
   virtual void OnTick() {
      if (comments_enabled) addcomment("Signal Close: "+signaltext_close(this.closesignal)+"\n");
   }
};

class CMainSignal : public CMainSignalBase
{
public:
   CIsFirstTick* isfirsttick;
   
   CMainSignal()
   {
      isfirsttick = new CIsFirstTick(symbol,timeframe);
      if (true) Add(new CSignal1());      
      if (true) Add(new CClosesignal1());
   }
   
   virtual bool BeforeFilter() {
      if (trade_only_at_barclose && !isfirsttick.isfirsttick()) return false;
      return true;
   }
   
   virtual bool AfterFilter() {
      if (reverse_strategy) Reverse();
      if (trade_only_signal_change && (lastsignal == SIGNAL_NONE || signal == lastsignal)) return false;
      return true;
   }
   
   virtual void OnTick() {
      CSignalContainer::OnTick();
      if (comments_enabled) addcomment("signal: "+signaltext(signal)+" valid:"+(string)valid+"\n");   
   }   
};

class CSignalManager : public CSignalManagerBase
{
public:
   CSignalManager(int __bar)
   {
      bar = __bar;
      mainsignal = new CMainSignal();   
   }
};

class CEntryMethod : public CEntryMethodBase
{
public:
   virtual bool BuySignalFilter(bool valid)
   {
      if (!short_enabled) return false;
      if (ordermanager.CntOrders(ORDERSELECT_ANY,STATESELECT_FILLED) >= maxorders) return false;
      return true;
   }
   
   virtual bool SellSignalFilter(bool valid)
   {
      if (!long_enabled) return false;
      if (ordermanager.CntOrders(ORDERSELECT_ANY,STATESELECT_FILLED) >= maxorders) return false;
      return true;
   }
   virtual bool CloseOpposite()
   {
      return close_opposite_order;
   }
};

class COrderCommandHandler : public COrderCommandHandlerBase
{
public:
   virtual void CloseBuy()
   {
      ordermanager.CloseAll(ORDERSELECT_LONG,STATESELECT_FILLED);   
   }
   
   virtual void CloseSell()
   {
      ordermanager.CloseAll(ORDERSELECT_SHORT,STATESELECT_FILLED);     
   }
   
   virtual void OpenBuy()
   {
      ordermanager.NewOrder(symbol,ORDER_TYPE_BUY,mm,NULL,new CStopLossTicks(convertfract(stoploss)),new CTakeProfitTicks(convertfract(takeprofit)));      
   }
   
   virtual void OpenSell()
   {
      ordermanager.NewOrder(symbol,ORDER_TYPE_SELL,mm,NULL,new CStopLossTicks(convertfract(stoploss)),new CTakeProfitTicks(convertfract(takeprofit)));      
   }
};

class CMain : public CServiceProvider
{
public:
   CMain()
   {
      use_ontick = true;
      use_oninit = true;
   }
   
   virtual void OnTick()
   {
      writecomment();
      delcomment();
   }
   
   virtual void OnInit()
   {
   
      // TRADE
      if (COrderBase::trade_default == NULL) COrderBase::trade_default = new CTrade();
      if (IsTesting() && !IsVisualMode()) COrderBase::trade_default.LogLevel(LOG_LEVEL_ERRORS);
      else COrderBase::trade_default.LogLevel(LOG_LEVEL_ALL);
      COrderBase::trade_default.SetDeviationInPoints(slippage);
         
      #ifdef __MQL4__
   
         COrderBase::trade_default.SetColors(cl_buy, cl_sell);
         COrderBase::trade_default.SetIsEcn(orderbymarket);      
      
         // ORDER
         COrderBase::magic_default = _magic;
         COrder::sl_virtual_default = sl_virtual;
         COrder::tp_virtual_default = tp_virtual;
         COrder::vstops_draw_line = vstops_draw_line;
         COrder::realstops_draw_line = realstops_draw_line;   
      
      #endif   

      CEventHandlerInterface* eventhandler = App().GetService(srvEvent);
      if (IsTesting() && !IsVisualMode()) {      
         eventhandler.SetLogLevel(E_ERROR);
         comments_enabled = false;
      } else {
         eventhandler.SetLogLevel(E_NOTICE|E_WARNING|E_ERROR|E_INFO);
      }
      
      CEntryMethodBase* entrymethod = App().GetService(srvEntryMethod);
      
   }
};

CApplication app;

void OnTick()
{
   app.OnTick();  
}


int OnInit()
{
   mm = new CMoneyManagementFixed(lotsize);
   
   register_services();

   if (!app().ServiceIsRegistered("symbolinfovars")) app().RegisterService(new CSymbolInfoVars(Symbol()),srvNone,"symbolinfovars");
   if (!app().ServiceIsRegistered(srvSignalManager)) app().RegisterService(new CSignalManager(_bar),srvSignalManager,"signalmanager");
   if (!app().ServiceIsRegistered(srvEntryMethod)) app().RegisterService(new CEntryMethod(),srvEntryMethod,"entrymethod");
   if (!app().ServiceIsRegistered(srvOrderCommandHandler)) app().RegisterService(new COrderCommandHandler(),srvOrderCommandHandler,"ordercommandhandler");
   if (!app().ServiceIsRegistered("main")) app().RegisterService(new CMain(),srvNone,"main");

   app.InitalizeServices();
   
   if (!app().CommandHandlerIsRegistered(classOpenBuy)) {
      CObject* ordercommandhandler = app().GetService(srvOrderCommandHandler);
      app().RegisterCommandHandler(ordercommandhandler,classOpenBuy);
      app().RegisterCommandHandler(ordercommandhandler,classOpenSell);
      app().RegisterCommandHandler(ordercommandhandler,classCloseBuy);
      app().RegisterCommandHandler(ordercommandhandler,classCloseSell);
   }

   app.OnInit();
   return(0);
}

void OnDeinit(const int reason)
{
   app.OnDeinit();
   return;
}
