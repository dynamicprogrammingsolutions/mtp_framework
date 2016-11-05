#include "..\Loader.mqh"
#include "..\TestManager\Loader.mqh"
#include "..\libraries\comments.mqh"

class CTestOrder : public CTestBase
{
public:
   TraitAppAccess
   
   POrder order;
   PMoneyManagement mm;
   COrderManagerInterface* om;
   COrderRepositoryInterface* or;
   string symbol;
   ENUM_ORDER_TYPE ordertype;
   PStopsCalc entry;
   PStopsCalc sl;
   PStopsCalc tp;
   string comment;
   datetime timeopened;
   int close_after;
   
   CTestOrder(COrderManagerInterface* _om, COrderRepositoryInterface* _or, string _symbol, ENUM_ORDER_TYPE _ordertype, PMoneyManagement &_mm, PStopsCalc &_entry, PStopsCalc &_sl, PStopsCalc &_tp, string _comment, int _close_after) :
   om(_om),
   or(_or),
   mm(_mm),
   symbol(_symbol),
   ordertype(_ordertype),
   sl(_sl),
   tp(_tp),
   comment(_comment),
   close_after(_close_after)
   {
   }
   
   virtual void OnTick()
   {
      COrderInterface* p_order = this.order.get();
      if (TimeCurrent() >= timeopened+close_after) p_order.Close();
      if (p_order.Closed()) this.Stop();
      else {
         addcommentln("Test p_order id: ",p_order.Id());
         addcommentln("State: ",EnumToString(p_order.State()));
         addcommentln("ExecuteState: ",EnumToString(p_order.ExecuteState()));
         addcommentln("GetTicket: ",p_order.GetTicket());
         addcommentln("GetMagic: ",p_order.GetMagicNumber());
         addcommentln("GetSymbol: ",p_order.GetSymbol());
         addcommentln("GetComment: ",p_order.GetComment());
         addcommentln("GetType: ",EnumToString(p_order.GetType()));
         addcommentln("GetOpenTime: ",TimeToString(p_order.GetOpenTime()));
         addcommentln("GetOpenPrice: ",p_order.GetOpenPrice());
         addcommentln("GetLots: ",p_order.GetLots());
         addcommentln("GetClosePrice: ",p_order.GetClosePrice());
         addcommentln("GetCloseTime: ",TimeToString(p_order.GetCloseTime()));
         addcommentln("GetStopLossTicks: ",p_order.GetStopLossTicks());
         addcommentln("GetStopLoss: ",p_order.GetStopLoss());
         addcommentln("GetTakeProfitTicks: ",p_order.GetTakeProfitTicks());
         addcommentln("GetTakeProfit: ",p_order.GetTakeProfit());
         addcommentln("GetExpiration: ",TimeToString(p_order.GetExpiration()));
         addcommentln("GetProfitTicks: ",p_order.GetProfitTicks());
         addcommentln("GetProfitMoney: ",p_order.GetProfitMoney());
         addcommentln("GetCommission: ",p_order.GetCommission());
         addcommentln("GetSwap: ",p_order.GetSwap());
         addcommentln("------------------------------");
         addcommentln("TotalProfitMoney: ",App().orderrepository.TotalProfitMoney(ORDERSELECT_ANY));
      }
   }
   
   virtual bool OnBeginOnTick()
   {
      Print("TestOrder Started");
      this.order.reset(om.NewOrder(symbol,ordertype,mm,entry,sl,tp,comment));
      COrderInterface* p_order = this.order.get();
      
      timeopened = TimeCurrent();
      
      p_order.OnTick();
      string filename = "TestOrderSave_"+Symbol()+".dat";
      ResetLastError(); 
      int handle = FileOpen(filename,FILE_WRITE|FILE_BIN);
      if(handle==INVALID_HANDLE) {
         Print("Operation FileOpen failed, error ",GetLastError()); 
      }
      if (!p_order.Save(handle)) {
         Print("file save failed");
      }
      FileClose(handle);
      
      POrder loadedorder = NewPOrder(App().NewObject(order.get()));
      COrderInterface* p_loadedorder = loadedorder.get();
      if (FileIsExist(filename))
      {
         ResetLastError();
         handle = FileOpen(filename,FILE_READ|FILE_BIN);
         if(handle==INVALID_HANDLE) {
            Print("Operation FileOpen failed, error ",GetLastError()); 
         }
         if (!p_loadedorder.Load(handle)) {
            Print("file load failed");
         }
         FileClose(handle);
         FileDelete(filename);
      }
      
      p_loadedorder.OnTick();
      
      AssertEqual(p_order.Id(),p_loadedorder.Id(),"Id");
      AssertEqual(p_order.State(),p_loadedorder.State(),"State");
      AssertEqual(p_order.ExecuteState(),p_loadedorder.ExecuteState(),"ExecuteState");
      AssertEqual(p_order.GetTicket(),p_loadedorder.GetTicket(),"GetTicket");
      AssertEqual(p_order.GetMagicNumber(),p_loadedorder.GetMagicNumber(),"GetMagicNumber");
      AssertEqual(p_order.GetSymbol(),p_loadedorder.GetSymbol(),"GetSymbol");
      AssertEqual(p_order.GetComment(),p_loadedorder.GetComment(),"GetComment");
      AssertEqual(p_order.GetType(),p_loadedorder.GetType(),"GetType");
      AssertEqual(p_order.GetOpenTime(),p_loadedorder.GetOpenTime(),"GetOpenTime");
      AssertEqual(p_order.GetOpenPrice(),p_loadedorder.GetOpenPrice(),"GetOpenPrice");
      AssertEqual(p_order.GetLots(),p_loadedorder.GetLots(),"GetLots");
      AssertEqual(p_order.GetClosePrice(),p_loadedorder.GetClosePrice(),"GetClosePrice");
      AssertEqual(p_order.GetCloseTime(),p_loadedorder.GetCloseTime(),"GetCloseTime");
      AssertEqual(p_order.GetStopLossTicks(),p_loadedorder.GetStopLossTicks(),"GetStopLossTicks");
      AssertEqual(p_order.GetStopLoss(),p_loadedorder.GetStopLoss(),"GetStopLoss");
      AssertEqual(p_order.GetTakeProfitTicks(),p_loadedorder.GetTakeProfitTicks(),"GetTakeProfitTicks");
      AssertEqual(p_order.GetProfitTicks(),p_loadedorder.GetProfitTicks(),"GetProfitTicks");
      AssertEqual(p_order.GetProfitMoney(),p_loadedorder.GetProfitMoney(),"GetProfitMoney");
      AssertEqual(p_order.GetExpiration(),p_loadedorder.GetExpiration(),"GetExpiration");
      AssertEqual(p_order.GetProfitTicks(),p_loadedorder.GetProfitTicks(),"GetProfitTicks");
      AssertEqual(p_order.GetProfitMoney(),p_loadedorder.GetProfitMoney(),"GetProfitMoney");
      AssertEqual(p_order.GetCommission(),p_loadedorder.GetCommission(),"GetCommission");
      AssertEqual(p_order.GetSwap(),p_loadedorder.GetSwap(),"GetSwap");
      
      int orderid = p_order.Id();
      
      filename = "TestOrderSave_"+Symbol()+".dat";
      ResetLastError(); 
      handle = FileOpen(filename,FILE_WRITE|FILE_BIN);
      if(handle==INVALID_HANDLE) {
         Print("Operation FileOpen failed, error ",GetLastError()); 
      }
      if (!App().orderrepository.Save(handle)) {
         Print("file save failed");
      }
      FileClose(handle);
      
      App().orderrepository.Clear();
      
      if (FileIsExist(filename))
      {         
         ResetLastError();
         handle = FileOpen(filename,FILE_READ|FILE_BIN);
         if(handle==INVALID_HANDLE) {
            Print("Operation FileOpen failed, error ",GetLastError()); 
         }
         if (!App().orderrepository.Load(handle)) {
            Print("file load failed");
         }
         FileClose(handle);
         FileDelete(filename);
      }
      
      App().orderrepository.OnTick();
      
      loadedorder.reset(App().orderrepository.GetById(orderid));
      
      p_order = order.get();
      p_loadedorder = loadedorder.get();
      
      if (AssertIsSet(p_loadedorder,"p_loadedorder")) {
         AssertEqual(p_order.Id(),p_loadedorder.Id(),"Id");
         AssertEqual(p_order.State(),p_loadedorder.State(),"State");
         AssertEqual(p_order.ExecuteState(),p_loadedorder.ExecuteState(),"ExecuteState");
         AssertEqual(p_order.GetTicket(),p_loadedorder.GetTicket(),"GetTicket");
         AssertEqual(p_order.GetMagicNumber(),p_loadedorder.GetMagicNumber(),"GetMagicNumber");
         AssertEqual(p_order.GetSymbol(),p_loadedorder.GetSymbol(),"GetSymbol");
         AssertEqual(p_order.GetComment(),p_loadedorder.GetComment(),"GetComment");
         AssertEqual(p_order.GetType(),p_loadedorder.GetType(),"GetType");
         AssertEqual(p_order.GetOpenTime(),p_loadedorder.GetOpenTime(),"GetOpenTime");
         AssertEqual(p_order.GetOpenPrice(),p_loadedorder.GetOpenPrice(),"GetOpenPrice");
         AssertEqual(p_order.GetLots(),p_loadedorder.GetLots(),"GetLots");
         AssertEqual(p_order.GetClosePrice(),p_loadedorder.GetClosePrice(),"GetClosePrice");
         AssertEqual(p_order.GetCloseTime(),p_loadedorder.GetCloseTime(),"GetCloseTime");
         AssertEqual(p_order.GetStopLossTicks(),p_loadedorder.GetStopLossTicks(),"GetStopLossTicks");
         AssertEqual(p_order.GetStopLoss(),p_loadedorder.GetStopLoss(),"GetStopLoss");
         AssertEqual(p_order.GetTakeProfitTicks(),p_loadedorder.GetTakeProfitTicks(),"GetTakeProfitTicks");
         AssertEqual(p_order.GetProfitTicks(),p_loadedorder.GetProfitTicks(),"GetProfitTicks");
         AssertEqual(p_order.GetProfitMoney(),p_loadedorder.GetProfitMoney(),"GetProfitMoney");
         AssertEqual(p_order.GetExpiration(),p_loadedorder.GetExpiration(),"GetExpiration");
         AssertEqual(p_order.GetProfitTicks(),p_loadedorder.GetProfitTicks(),"GetProfitTicks");
         AssertEqual(p_order.GetProfitMoney(),p_loadedorder.GetProfitMoney(),"GetProfitMoney");
         AssertEqual(p_order.GetCommission(),p_loadedorder.GetCommission(),"GetCommission");
         AssertEqual(p_order.GetSwap(),p_loadedorder.GetSwap(),"GetSwap");
      }
      
      order.assign(loadedorder);
      
      return true;
   }
   
   virtual void OnEnd()
   {
      Print("TestOrder Ended");
   }    
};
