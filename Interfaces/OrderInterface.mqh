//
class COrderInterface : public CAppObject
{
   virtual bool NewOrder(const string in_symbol,const ENUM_ORDER_TYPE _ordertype,const double _volume,const double _price,
      const double _stoploss,const double _takeprofit,const string _comment="",const datetime _expiration=0) { return false; }
      
   virtual bool Execute() { return false; }
   virtual bool Close(double closevolume = 0, double closeprice = 0) { return false; }
   virtual bool Cancel() { return false; }
   virtual bool Modify() { return false; }

   virtual bool CreateAttached(ENUM_ORDER_TYPE _ordertype, double _volume, double _price, double _limit_price, string _name, string _comment) { return false; }
   virtual bool AddStopLoss(double in_price, double stopvolume = 0, string name = "") { return false; }
   virtual bool AddTakeProfit(double in_price, double stopvolume = 0, string name = "") { return false; } 

   virtual bool Closed() { return false; }
   virtual bool Deleted() { return false; }
   virtual bool ClosedOrDeleted() { return false; }   
         
   virtual long GetTicket() { return 0; }
   virtual int GetMagicNumber() { return 0; }
   virtual string GetSymbol() { return NULL; }
   virtual string GetComment() { return NULL; }
   virtual ENUM_ORDER_TYPE GetType() { return NULL; }
   virtual datetime GetOpenTime() { return 0; }
   virtual double GetOpenPrice() { return 0; }
   virtual double GetLots() { return 0; }
   virtual double GetClosePrice() { return 0; }
   virtual datetime GetCloseTime() { return 0; }
   virtual int GetStopLossTicks() { return 0; }   
   virtual double GetStopLoss() { return 0; }   
   virtual int GetTakeProfitTicks() { return 0; }
   virtual double GetTakeProfit() { return 0; }   
   virtual int GetProfitTicks() { return 0; }
   virtual datetime GetExpiration() { return 0; }

   virtual void SetOrderType(const ENUM_ORDER_TYPE value) { }
   virtual void SetMagic(const int value) { }
   virtual void SetSymbol(const string value) { }
   virtual void SetComment(const string value) { }
   virtual void SetLots(const double value) { }
   virtual void SetExpiration(const datetime value) { }
   virtual void SetPrice(const double value) { }
   virtual void SetStopLoss(const double value) { }
   virtual void SetTakeProfit(const double value) { }
   
};