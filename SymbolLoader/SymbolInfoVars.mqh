#property copyright "Zoltan Laszlo Ferenci"
#property link      "http://www.metatraderprogrammer.com"

#include "..\Loader.mqh"
#include "SymbolLoader.mqh"
#include "..\ChartInfo\IsFirstTick.mqh"

//CAccountInfo accountinfo;

bool variables_initalized=false;
enum ENUM_FRACT_MODE {
   FRACT_MODE_DISABLED,
   FRACT_MODE_ENABLED,
   FRACT_MODE_AUTO
};

ENUM_FRACT_MODE _fract_mode = FRACT_MODE_AUTO;

CMTPSymbolInfo* symbolinfo;

string symbol;
double point;
int digits;
double ticksize;
int stoplevel;
double tickvalue;
double minlot, lotstep, maxlot;
int stoplevel_inticks;
double ticksize_inpoints;
double lotvalue;
bool firsttick;

datetime ticktime;
double bid, ask;
double force_bid=0, force_ask=0;
int spread;
int spread_inticks;
int minsl, mintp;

bool convertfract_enabled = true;

string initerror = "variables.mqh has not been initalized!";
string priceiniterror = "variables.mqh has not been initalized at actual tick!";

class CSymbolInfoVars : public CServiceProvider
{
   public:
   virtual int Type() const { return classSymbolInfoVars; }
   
   TraitAppAccess
   
   CEventHandlerInterface* event;
   CSymbolLoaderInterface* symbolloader;
   CMTPSymbolInfo *m_symbolinfo;
   CIsFirstTick* isfirsttick;
   
   ENUM_TIMEFRAMES tf;
   
   CSymbolInfoVars(string _symbol, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
   {
      symbol = _symbol;
      tf = _tf;
   }
   virtual void Initalize()
   {
      event = App().GetService(srvEvent);
      symbolloader = App().GetService(srvSymbolLoader);
   }
   
   virtual void OnInit()
   {
      InitVars(symbol);
      isfirsttick = new CIsFirstTick(symbol,tf);
   }
   virtual void OnDeinit()
   {
      delete isfirsttick;
   }
   virtual void OnTick()
   {
      InitVarsTick();
      firsttick = isfirsttick.isfirsttick();
   }
   
   bool InitVars(string symbol);
   void InitVarsTick();
};

bool CSymbolInfoVars::InitVars(string in_symbol)
{
   if (symbol == in_symbol && variables_initalized) return(true);
   if (in_symbol == "")
   {
      in_symbol = Symbol();
   }
   m_symbolinfo = symbolloader.LoadSymbol(in_symbol);

   variables_initalized = true;
   symbolinfo = m_symbolinfo;
   symbol = in_symbol;
   point = m_symbolinfo.Point();
   digits = m_symbolinfo.Digits();
   stoplevel = m_symbolinfo.StopsLevel(); //in points
   tickvalue = m_symbolinfo.TickValue(); //in deposit currency
   ticksize = m_symbolinfo.TickSize();
   minlot = m_symbolinfo.LotsMin();
   lotstep = m_symbolinfo.LotsStep();
   maxlot = m_symbolinfo.LotsMax();
   //if (ticksize == 0) ticksize = point;
   ticksize_inpoints = m_symbolinfo.TickSizeInPoints();   //ticksize/point;
   stoplevel_inticks = m_symbolinfo.StopsLevelInTicks();//(int)MathRound(stoplevel/ticksize_inpoints);
   lotvalue = m_symbolinfo.LotValue(); //in deposit currency
   mintp = m_symbolinfo.MinTakeProfit();
   InitVarsTick();
   return(true);
}

void CSymbolInfoVars::InitVarsTick()
{
   if (symbol == "" || !variables_initalized) {
      event.Error("not initalized",__FUNCTION__);
      return;
   }

   if (isset(m_symbolinfo)) symbolloader.LoadSymbol(m_symbolinfo.Name());
   else {
      m_symbolinfo = symbolloader.LoadSymbol(Symbol());
   }
   //m_symbolinfo.Refresh();

   if (m_symbolinfo == NULL) event.Error("No SymbolInfo Object",__FUNCTION__);
   //this.event.Info("updaing price: "+m_symbolinfo.Bid()+" "+m_symbolinfo.Ask(),__FUNCTION__);

   ticktime = m_symbolinfo.Time();
   
   if (force_bid > 0) bid = force_bid; else bid = m_symbolinfo.Bid();
   if (force_ask > 0) ask = force_ask; else ask = m_symbolinfo.Ask();

   spread = m_symbolinfo.Spread();
   spread_inticks = m_symbolinfo.SpreadInTicks();
   minsl = m_symbolinfo.MinStopLoss();
}

bool isfractional(double treshold = FRACTIONAL_TRESHOLD)
{
   return(symbolinfo.IsFractional(treshold));
}

int fract(int& num)
{
   num *= 10;
   return(num);
}

double fractd(double& num)
{
   num *= 10;
   return(num);
}

int inticks(double price)
{
   return(symbolinfo.InTicks(price));
}

double inticksd(double price)
{
   return((double)symbolinfo.InTicksD(price));
}

int convertfract(double pips)
{
   switch(_fract_mode) {
      case FRACT_MODE_DISABLED:
         return pips;
      case FRACT_MODE_ENABLED:
         return pips*10.0;
      default:
         return (int)(convertfract_enabled?symbolinfo.ConvertFractional(pips):pips);
   }
}

double priceround(double price)
{
   return(symbolinfo.PriceRound(price));
}

double lotround(double lotreq, bool for_close = false)
{
   return(symbolinfo.LotRound(lotreq,for_close));
}