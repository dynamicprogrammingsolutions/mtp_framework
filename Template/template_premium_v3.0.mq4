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

#define CUSTOM_SERVICES srvMain,
#define CUSTOM_CLASSES classSignalManager, classEntryMethod, classOrderCommandHandler, classMain,

#include <mtp_framework_1.1\Loader.mqh>
#include <mtp_framework_1.1\DefaultServices.mqh>   

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

bool savetofile_at_remove = true;
bool savetofile_at_chart_change = false;
bool savetofile_at_chart_close = false;
bool savetofile_at_parameter_change = false;
bool savetofile_at_template_change = false;
bool savetofile_at_terminal_close = true;

bool loadfromfile = true;
string datafile = "save_dps";

ulong benchmark_sum;
ulong benchmark_cnt;

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

/* INLINE SIGNAL
class CMainSignal : public COpenAndCloseSignal
{
   CIsFirstTick* isfirsttick;
   CMainSignal()
   {
      isfirsttick = new CIsFirstTick(symbol,timeframe);
   }
   OpenSignal()
   {
      
   }
   CloseSignal()
   {
      
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
}
*/

class CMainSignal : public CSignalContainer
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
   virtual int Type() const { return classSignalManager; }   
   virtual void OnInit()
   {
      bar = _bar;
      mainsignal = new CMainSignal();      
   }
   virtual void OnDeinit()
   {
      delete mainsignal;
   }
   
};

class CEntryMethod : public CEntryMethodBase
{
public:
   virtual int Type() const { return classEntryMethod; }

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
   CStopLoss* sl;
   CTakeProfit* tp;
   CMoneyManagement* mm;
   
   virtual void OnInit()
   {
      mm = new CMoneyManagementFixed(lotsize);
      sl = new CStopLossTicks(convertfract(stoploss));
      tp = new CTakeProfitTicks(convertfract(takeprofit));
   }

   virtual int Type() const { return classOrderCommandHandler; }
   
   virtual void CloseAll()
   {
      ordermanager.CloseAll(ORDERSELECT_ANY,STATESELECT_FILLED);
   }

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
      ordermanager.NewOrder(symbol,ORDER_TYPE_BUY,mm,NULL,sl,tp);      
   }
   
   virtual void OpenSell()
   {
      ordermanager.NewOrder(symbol,ORDER_TYPE_SELL,mm,NULL,sl,tp);      
   }
};

class CMain : public CServiceProvider
{
public:
   virtual int Type() const { return classMain; }
   
   TraitAppAccess

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

      if (IsTesting() && !IsVisualMode()) {      
         application.eventhandler.SetLogLevel(E_ERROR);
         comments_enabled = false;
      } else {
         application.eventhandler.SetLogLevel(E_NOTICE|E_WARNING|E_ERROR|E_INFO);
      }
      
      ((COrderManager*)(application.ordermanager)).retrainhistory = 1;
      
      #ifdef __MQL4__
         // STORE OPEN ORDERS
         for (int i = OrdersTotal()-1; i >= 0; i--) {
            if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
               COrder* exord;
               exord = App().ordermanager.ExistingOrder(OrderTicket());
               if (exord != NULL) {  
                  if (exord.symbol != _symbol.Name() || exord.magic != COrderBase::magic_default) {         
                     int idx = om.GetIdxByTicket(exord.GetTicket());
                     if (idx >= 0)
                        App().ordermanager.orders.Delete(idx);
                  }                     
               } else {
                  //Print("Order Adding Failed");
               }
            }
         }
         om.AssignAttachedOrders();
      #endif
      
      if (loadfromfile) {
         string filename = datafile+Symbol()+".dat";
         if (FileIsExist(filename))
         {
            Print("loading from file");
            int handle = FileOpen(filename,FILE_READ|FILE_BIN);
      
            if (!App().ordermanager.Load(handle)) {
               Print("file load failed");
            }
            FileClose(handle);
            FileDelete(filename);
         }      
      }
      
   }
   
   virtual void OnDeinit()
   {
      if (benchmark_cnt > 0) Print("benchmark ("+(string)benchmark_cnt+"): "+(string)(benchmark_sum/(benchmark_cnt*1.0)));
      
      string filename = datafile+Symbol()+".dat";
      if ((savetofile_at_remove && UninitializeReason() == REASON_REMOVE) ||
      (savetofile_at_chart_change && UninitializeReason() == REASON_CHARTCHANGE) ||
      (savetofile_at_chart_close && UninitializeReason() == REASON_CHARTCLOSE) ||
      (savetofile_at_parameter_change && UninitializeReason() == REASON_PARAMETERS) ||
      (savetofile_at_template_change && UninitializeReason() == REASON_TEMPLATE) ||
      (savetofile_at_terminal_close && UninitializeReason() == REASON_CLOSE)) {
         Print("saving to file");
         int handle = FileOpen(filename,FILE_WRITE|FILE_BIN);
         if (!App().ordermanager.Save(handle)) {
            Print("file save failed");
         }
         FileClose(handle);
      } else {
         FileDelete(filename);
      }
   }
};

CApplication application;

void OnTick()
{
   application.OnTick();  
}


int OnInit()
{

   if (!application.Initalized()) {
   
      register_services();
   
      application.RegisterService(new CSignalManager(),srvSignalManager,"signalmanager");
      application.RegisterService(new CEntryMethod(),srvEntryMethod,"entrymethod");
      application.RegisterService(new CMain(),srvMain,"main");
      application.RegisterService(new COrderCommandHandler(),srvNone,"ordercommandhandler");
      application.RegisterService(new CScriptManagerBase(),srvScriptManager,"scriptmanager");
      
      application.RegisterCommandHandler(application.GetService("ordercommandhandler"),classOrderCommand);
      application.RegisterCommandHandler(new COrderScriptHandler(),classScript);
   
      application.Initalize();
         
   }

   application.OnInit();
   
   return(0);
}

void OnDeinit(const int reason)
{
   application.OnDeinit();
}

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
   application.OnChartEvent(id, lparam, dparam, sparam);
}