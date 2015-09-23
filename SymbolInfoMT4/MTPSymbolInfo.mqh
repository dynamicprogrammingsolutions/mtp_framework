//
#include "..\Loader.mqh"
#include "SymbolInfo.mqh"
#include "..\libraries\math.mqh"
#include "..\libraries\commonfunctions.mqh"

#include <Arrays\ArrayObj.mqh>

#define FRACTIONAL_TRESHOLD 50000
#define LOTROUNDUP_DEF 0.5

class CMTPSymbolInfo : public CSymbolInfo
{
public:
   virtual int Type() const { return classMT4MTPSymbolInfo; }

public:
   
      //CEventHandler* event;
      //double m_lotroundup;
      double lot_extradigits;
      //double m_roundup_to_minlot;

      double lotroundup;
      bool roundup_to_minlot;
      
      double lotroundup_close;
      bool roundup_to_minlot_close;

   public:
      
      void CMTPSymbolInfo::CMTPSymbolInfo()
      {
         lotroundup = LOTROUNDUP_DEF;
         lot_extradigits = 0;
         roundup_to_minlot = true;
      }
      
      CEventHandlerInterface* event;
      virtual void Initalize()
      {
         event = ((CApplication*)AppBase()).eventhandler;
      }
      
      virtual bool Name(string name);

      double TickSizeR() { return(TickSize()==0?CMTPSymbolInfo::m_point:TickSize()); }
      int InTicks(double price) { return((int)MathRound(price/TickSizeR())); }
      double InTicksD(double price) { return(price/TickSizeR()); }
      int TickSizeInPoints() { return((int)(TickSizeR()/CMTPSymbolInfo::m_point)); }
      int StopsLevelInTicks() { return((int)MathRound(StopsLevel()/TickSizeInPoints())); }
      int MinTakeProfit() { return(StopsLevelInTicks()); }
      int MinStopLoss() { return(SpreadInTicks() + StopsLevelInTicks()); }
      int SpreadInTicks() { return(Spread()/TickSizeInPoints()); }
      double SpreadInPrice() { return(Spread()*this.Point()); }
      double LotValue() { return(TickValue()/TickSize()); }
      bool IsFractional(double treshold = FRACTIONAL_TRESHOLD);
      virtual double ConvertFractional(double pips) { return IsFractional()?pips*10:pips; }
      double PriceRound(double price) { return(InTicks(price)*TickSizeR()); }
      double LotRound(double lotreq, bool close = false);
      double LotRoundUp() { return(lotroundup); }
      void LotRoundUp(double _lotroundup, bool _roundup_to_minlot) { lotroundup = _lotroundup; roundup_to_minlot = _roundup_to_minlot; }
      void LotRoundUpClose(double _lotroundup, bool _roundup_to_minlot) { lotroundup_close = _lotroundup; roundup_to_minlot_close = _roundup_to_minlot; }
};

bool CMTPSymbolInfo::Name(string name)
{
   if (name != "" && m_name == name) {
      //event.Info("object already initalized for symbol "+name,__FUNCTION__);
      return(true);
   }
   if (event.Info ()) event.Info ("initalizing symbol "+name,__FUNCTION__);
   if (!CSymbolInfo::Name(name)) {
      if (event.Error ()) event.Error ("Invalid Symbol "+name,__FUNCTION__);
      m_name = "";
      return(false);
   } else {
      return(true);
   }
}

bool CMTPSymbolInfo::IsFractional(double treshold = FRACTIONAL_TRESHOLD)
{
   if (Bid()/TickSize() > treshold) return(true);
   else return(false);
}
double CMTPSymbolInfo::LotRound(double lotreq, bool close = false)
{
   double _lotstep = LotsStep()/MathPow(10,lot_extradigits);

   if (_lotstep <= 0) _lotstep = 0.01; // to avoid zero divide
   if (m_lots_max <= 0) m_lots_max = 100;
   if (m_lots_min <= 0) m_lots_min = 0.01;

   double lotquotient = lotreq/_lotstep;
   
   double lotwhole = MathFloor(lotquotient);
   /*if (l(lotwhole, lotquotient))
      lotwhole--;*/
   double lotdecimal = lotquotient-lotwhole;
   
   if (!close && lq(lotdecimal, lotroundup))
      lotwhole++;
   if (close && l(lotdecimal, lotroundup_close))
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