//

class CSymbolInfoBase : public CAppObject
{
   protected:
      CEventHandlerBase* event;
      
   public:
      CSymbolInfoBase()
      {
         event = app.GetService(srvEvent);
      }
   
      virtual string Name() const { return NULL; }
      virtual bool Name(string name) { return false; }
      
      virtual double Bid() const { return(0); }
      virtual double Ask() const { return(0); }
      virtual bool RefreshRates() { return false; }

      virtual double TickSize() { return(0); }
      virtual double TickSizeR() { return(0); }
      virtual int InTicks(double price) { return(0); }
      virtual double InTicksD(double price) { return(0); }
      virtual int TickSizeInPoints() { return(0); }
      virtual int StopsLevelInTicks() { return(0); }
      virtual int MinTakeProfit() { return(0); }
      virtual int MinStopLoss() { return(0); }
      virtual int SpreadInTicks() { return(0); }
      virtual double SpreadInPrice() { return(0); }
      virtual double LotValue() { return(0); }
      virtual bool IsFractional(double treshold = 0) { return false; };
      virtual double PriceRound(double price) { return(0); }
      virtual double LotRound(double lotreq, bool close = false) { return 0; }
      virtual double LotRoundUp() { return(0); }
      virtual void LotRoundUp(double _lotroundup, bool _roundup_to_minlot) { }
      virtual void LotRoundUpClose(double _lotroundup, bool _roundup_to_minlot) { }
      
};
