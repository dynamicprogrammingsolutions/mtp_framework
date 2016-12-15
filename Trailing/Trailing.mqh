//

#include "..\Loader.mqh"

/*
#ifdef __MQL5__
   #include "..\OrderManagerMT5\Loader.mqh"
#else
   #include "..\OrderManagerMT4\Loader.mqh"
#endif
*/

#include "..\OrderManager\StopsCalc.mqh"

class CTrailing : public CAppObject
{
public:
   TraitAppAccess
   
   virtual bool OnOrder(COrderInterface* in_order)
   {
      return false;
   }

};

class CTrailingSL : public CTrailing
{
public:
   TraitAppAccess
   
   bool checkhigher;
   
   virtual CStopsCalcInterface* Calc(COrderInterface* in_order)
   {
      return NULL;
   }
   
   virtual bool OnOrder(COrderInterface* in_order)
   {
      if (!isset(in_order)) return false;
      shared_ptr<CStopsCalcInterface> newsl = Calc(in_order);
      if (newsl.isset()) {
         if (checkhigher) {
            if (newsl.get().SetEntryPrice(in_order.GetOpenPrice()).SetSymbol(in_order.GetSymbol()).SetOrderType(in_order.GetType()).GetTicks() >= in_order.GetStopLossTicks()) {
               return false;
            }
         }
         in_order.SetStopLoss(newsl.get(),true);
         bool ret = in_order.Modify();
         return ret;
      }
      return false;
   }

};

class CTrailingSLStopsCalc : public CTrailingSL
{
public:
   shared_ptr<CStopsCalcInterface> slcalc;
   CTrailingSLStopsCalc(CStopsCalcInterface* _slcalc, bool _checkhigher) : slcalc(_slcalc) { checkhigher = _checkhigher; }
   virtual CStopsCalcInterface* Calc(COrderInterface* in_order)
   {
      return slcalc.get();
   }
};

class CTrailingSLTicks : public CTrailingSL
{
public:
   bool trailingstop_round;
   int activate;
   int stoptrailing;
   int trailingstop; 
   int step;

   CTrailingSLTicks(int in_starttrailing, int in_stoptrailing, int in_trailingdist, int in_trailingstep, bool in_round) : activate(in_starttrailing), stoptrailing(in_stoptrailing), trailingstop(in_trailingdist), step(in_trailingstep), trailingstop_round(in_round) { }

   virtual CStopsCalcInterface* Calc(COrderInterface* in_order)
   {
      double sl_price = in_order.GetStopLoss();
      double sl = sl_price==0?EMPTY_VALUE:in_order.GetStopLossTicks();
      double newsl = sl;
      double orderprofit = in_order.GetProfitTicks();

      if (trailingstop_round && trailingstop > 0) {
         double trailingstart = activate-trailingstop;
         if (orderprofit >= trailingstart) {
         	double profitfromstart = orderprofit-trailingstart;
         	orderprofit = trailingstart+(MathFloor(profitfromstart/step)*step);
         }	
      }
      
      if ((trailingstop > 0) && (orderprofit >= activate) && ((sl == EMPTY_VALUE) || (sl >= -orderprofit + trailingstop + step))
      && ((stoptrailing <= 0) || (orderprofit <= stoptrailing))) {
         newsl = -orderprofit + trailingstop;
      }
      
      if (newsl == sl) return NULL;
      return this.Prepare(new CStopLossTicks(newsl,false));

   }
};

class CTrailingSLLockin : public CTrailingSL
{
public:

   int lockin;
   int lockinprofit;
   
   CTrailingSLLockin(int in_lockinat, int in_lockinprofit) : lockin(in_lockinat), lockinprofit(in_lockinprofit) {}
   
   virtual CStopsCalcInterface* Calc(COrderInterface* in_order)
   {
      double sl_price = in_order.GetStopLoss();
      double sl = sl_price==0?EMPTY_VALUE:in_order.GetStopLossTicks();
      double newsl = sl;
      double orderprofit = in_order.GetProfitTicks();

      if ((lockin > 0) && (orderprofit >= lockin) && (sl > -lockinprofit || sl == EMPTY_VALUE)) {
         newsl = -lockinprofit;
      }
      
      if (newsl == sl) return NULL;
      return this.Prepare(new CStopLossTicks(newsl,false));
   }
   
};

