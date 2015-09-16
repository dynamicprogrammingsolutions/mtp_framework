//

class CSymbolInfoInterface : public CAppObject
{
   public:
      virtual string Name() { AbstractFunctionWarning(__FUNCTION__); return NULL; }
      virtual bool Name(string name) { AbstractFunctionWarning(__FUNCTION__); return false; }
      
      virtual double Bid() { AbstractFunctionWarning(__FUNCTION__); return(0); }
      virtual double Ask() { AbstractFunctionWarning(__FUNCTION__); return(0); }
      virtual bool RefreshRates() { AbstractFunctionWarning(__FUNCTION__); return false; }

      virtual double TickSize() { AbstractFunctionWarning(__FUNCTION__); return(0); }
      virtual double TickSizeR() { AbstractFunctionWarning(__FUNCTION__); return(0); }
      virtual int InTicks(double price) { AbstractFunctionWarning(__FUNCTION__); return(0); }
      virtual double InTicksD(double price) { AbstractFunctionWarning(__FUNCTION__); return(0); }
      virtual int TickSizeInPoints() { AbstractFunctionWarning(__FUNCTION__); return(0); }
      virtual int StopsLevelInTicks() { AbstractFunctionWarning(__FUNCTION__); return(0); }
      virtual int MinTakeProfit() { AbstractFunctionWarning(__FUNCTION__); return(0); }
      virtual int MinStopLoss() { AbstractFunctionWarning(__FUNCTION__); return(0); }
      virtual int SpreadInTicks() { AbstractFunctionWarning(__FUNCTION__); return(0); }
      virtual double SpreadInPrice() { AbstractFunctionWarning(__FUNCTION__); return(0); }
      virtual double LotValue() { AbstractFunctionWarning(__FUNCTION__); return(0); }
      virtual bool IsFractional(double treshold = 0) { AbstractFunctionWarning(__FUNCTION__); return false; };
      virtual double PriceRound(double price) { AbstractFunctionWarning(__FUNCTION__); return(0); }
      virtual double LotRound(double lotreq, bool close = false) { return 0; }
      virtual double LotRoundUp() { AbstractFunctionWarning(__FUNCTION__); return(0); }
      virtual void LotRoundUp(double _lotroundup, bool _roundup_to_minlot) { AbstractFunctionWarning(__FUNCTION__);  }
      virtual void LotRoundUpClose(double _lotroundup, bool _roundup_to_minlot) { AbstractFunctionWarning(__FUNCTION__);  }
      
};
