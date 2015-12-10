#ifdef TRAILINGSTOP
class CTrailingStopManager : public CServiceProvider
{
public:
   CTrailingStop TrailingStop;

   virtual void Initalize()
   {
      this.Prepare((CAppObject*)GetPointer(TrailingStop));
   }

   virtual void OnTick()
   {
      TrailingStop.OnAll();
   }
   
   virtual void OnInit()
   {
      TrailingStop.lockin = convertfract(breakevenat);
      TrailingStop.lockinprofit = convertfract(breakeven_profit);
      TrailingStop.activate = convertfract(trailingstop_activate);
      TrailingStop.trailingstop = convertfract(trailingstop);
      TrailingStop.step = convertfract(trailingstop_step);
   }
};
#endif