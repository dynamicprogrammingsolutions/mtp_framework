//+------------------------------------------------------------------+
//|                                                SymbolInfoExt.mqh |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "..\Application.mqh"
#include "SymbolInfo.mqh"

//#include "..\libraries\eventhandler.mqh"
//#include "..\trade\SymbolInfo.mqh"
#include "..\libraries\math.mqh"

#include <Arrays\ArrayObj.mqh>

#define FRACTIONAL_TRESHOLD 50000
#define LOTROUNDUP_DEF 0.5

class CMTPSymbolInfo : public CSymbolInfo
{
   private:
      CEventHandlerBase* event;
      
   public:
      //double m_lotroundup;
      double lot_extradigits;
      //double m_roundup_to_minlot;

      double lotroundup;
      bool roundup_to_minlot;
      
      double lotroundup_close;
      bool roundup_to_minlot_close;

   public:
      virtual bool Name(string name);
      void CMTPSymbolInfo();
      double TickSizeR() { return(TickSize()==0?CMTPSymbolInfo::m_point:TickSize()); }
      int InTicks(double price) { return((int)MathRound(price/TickSizeR())); }
      double InTicksD(double price) { return(price/TickSizeR()); }
      int TickSizeInPoints() { return((int)(TickSizeR()/CMTPSymbolInfo::m_point)); }
      int StopsLevelInTicks() { return((int)MathRound(StopsLevel()/TickSizeInPoints())); }
      int MinTakeProfit() { return(StopsLevelInTicks()); }
      int MinStopLoss() { return(SpreadInTicks() + StopsLevelInTicks()); }
      int SpreadInTicks() { return(Spread()/TickSizeInPoints()); }
      double LotValue() { return(TickValue()/TickSize()); }
      bool IsFractional(double treshold = FRACTIONAL_TRESHOLD);
      double PriceRound(double price) { return(InTicks(price)*TickSizeR()); }
      double LotRound(double lotreq, bool close = false);
      double LotRoundUp() { return(lotroundup); }
      void LotRoundUp(double _lotroundup, bool _roundup_to_minlot) { lotroundup = _lotroundup; roundup_to_minlot = _roundup_to_minlot; }
      void LotRoundUpClose(double _lotroundup, bool _roundup_to_minlot) { lotroundup_close = _lotroundup; roundup_to_minlot_close = _roundup_to_minlot; }
};

bool CMTPSymbolInfo::Name(string name)
{
   if (m_name == name) {
      //event.Info("object already initalized for symbol "+name,__FUNCTION__);
      return(true);
   }
   event.Info("initalizing symbol "+name,__FUNCTION__);
   if (!CSymbolInfo::Name(name)) {
      event.Error("Invalid Symbol "+name,__FUNCTION__);
      m_name = "";
      return(false);
   } else {
      return(true);
   }
}

void CMTPSymbolInfo::CMTPSymbolInfo()
{
   event = this.app.GetService(srvEvent);
   m_name              ="";
   m_point             =0.0;
   m_tick_value        =0.0;
   m_tick_value_profit =0.0;
   m_tick_value_loss   =0.0;
   m_tick_size         =0.0;
   m_contract_size     =0.0;
   m_lots_min          =0.0;
   m_lots_max          =0.0;
   m_lots_step         =0.0;
   m_swap_long         =0.0;
   m_swap_short        =0.0;
   m_digits            =0;
   m_trade_execution   =0;
   m_trade_calcmode    =0;
   m_trade_mode        =0;
   m_swap_mode         =0;
   m_swap3             =0;
   m_margin_initial    =0.0;
   m_margin_maintenance=0.0;
   m_margin_long       =0.0;
   m_margin_short      =0.0;
   m_margin_limit      =0.0;
   m_margin_stop       =0.0;
   m_margin_stoplimit  =0.0;
   m_trade_time_flags  =0;
   m_trade_fill_flags  =0;
   
   lotroundup = LOTROUNDUP_DEF;
   lot_extradigits = 0;
   roundup_to_minlot = false;
}

bool CMTPSymbolInfo::IsFractional(double treshold = FRACTIONAL_TRESHOLD)
{
   if (Bid()/TickSize() > treshold) return(true);
   else return(false);
}
double CMTPSymbolInfo::LotRound(double lotreq, bool close = false)
{
   double _lotstep = LotsStep()/MathPow(10,lot_extradigits);
   double lotquotient = lotreq/_lotstep;
   
   double lotwhole = MathRound(lotquotient);
   if (l(lotwhole, lotquotient))
      lotwhole--;
   double lotdecimal = lotquotient-lotwhole;
   
   if (!close && lq(lotdecimal, lotroundup))
      lotwhole++;
   if (close && lq(lotdecimal, lotroundup_close))
      lotwhole++;

   double lot = lotwhole*_lotstep;
   if (s(lot, LotsMin()) && lot_extradigits == 0)
   {
      if ((!close && roundup_to_minlot) || (close && roundup_to_minlot_close))
         lot = LotsMin();
      else
         lot = 0;
   }
   if (lot > LotsMax())
      lot = LotsMax();
   return(lot);
}