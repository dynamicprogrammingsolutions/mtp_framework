#include "..\Loader.mqh"
#include "..\TestManager\Loader.mqh"
#include "..\libraries\comments.mqh"

class CTestOrder : public CTestBase
{
public:
   TraitAppAccess
   
   COrderInterface* order;
   CMoneyManagementInterface* mm;
   COrderManagerInterface* om;
   COrderRepositoryInterface* or;
   string symbol;
   ENUM_ORDER_TYPE ordertype;
   CStopsCalcInterface* entry;
   CStopsCalcInterface* sl;
   CStopsCalcInterface* tp;
   string comment;
   datetime timeopened;
   int close_after;
   
   CTestOrder(COrderManagerInterface* _om, COrderRepositoryInterface* _or, string _symbol, ENUM_ORDER_TYPE _ordertype, CMoneyManagementInterface* _mm, CStopsCalcInterface* _entry, CStopsCalcInterface* _sl, CStopsCalcInterface* _tp, string _comment, int _close_after)
   {
      om = _om;
      or = _or;
      mm = _mm;
      symbol = _symbol;
      ordertype = _ordertype;
      sl = _sl;
      tp = _tp;
      comment = _comment;
      close_after = _close_after;
   }
   
   virtual void OnTick()
   {
      if (TimeCurrent() >= timeopened+close_after) order.Close();
      if (order.Closed()) this.Stop();
      else {
         addcommentln("Test order id: ",order.Id());
         addcommentln("State: ",EnumToString(order.State()));
         addcommentln("ExecuteState: ",EnumToString(order.ExecuteState()));
         addcommentln("GetTicket: ",order.GetTicket());
         addcommentln("GetMagic: ",order.GetMagicNumber());
         addcommentln("GetSymbol: ",order.GetSymbol());
         addcommentln("GetComment: ",order.GetComment());
         addcommentln("GetType: ",EnumToString(order.GetType()));
         addcommentln("GetOpenTime: ",TimeToString(order.GetOpenTime()));
         addcommentln("GetOpenPrice: ",order.GetOpenPrice());
         addcommentln("GetLots: ",order.GetLots());
         addcommentln("GetClosePrice: ",order.GetClosePrice());
         addcommentln("GetCloseTime: ",TimeToString(order.GetCloseTime()));
         addcommentln("GetStopLossTicks: ",order.GetStopLossTicks());
         addcommentln("GetStopLoss: ",order.GetStopLoss());
         addcommentln("GetTakeProfitTicks: ",order.GetTakeProfitTicks());
         addcommentln("GetTakeProfit: ",order.GetTakeProfit());
         addcommentln("GetExpiration: ",TimeToString(order.GetExpiration()));
         addcommentln("GetProfitTicks: ",order.GetProfitTicks());
         addcommentln("GetProfitMoney: ",order.GetProfitMoney());
         addcommentln("GetCommission: ",order.GetCommission());
         addcommentln("GetSwap: ",order.GetSwap());
         addcommentln("------------------------------");
         addcommentln("TotalProfitMoney: ",App().orderrepository.TotalProfitMoney(ORDERSELECT_ANY));
      }
   }
   
   virtual bool OnBegin()
   {
      Print("TestOrder Started");
      order = om.NewOrder(symbol,ordertype,mm,entry,sl,tp,comment);
      timeopened = TimeCurrent();
      
      order.OnTick();
      string filename = "TestOrderSave_"+Symbol()+".dat";
      ResetLastError(); 
      int handle = FileOpen(filename,FILE_WRITE|FILE_BIN);
      if(handle==INVALID_HANDLE) {
         Print("Operation FileOpen failed, error ",GetLastError()); 
      }
      if (!order.Save(handle)) {
         Print("file save failed");
      }
      FileClose(handle);
      
      COrderInterface* loadedorder = App().NewObject(order);
      if (FileIsExist(filename))
      {
         Print("loading from file");
         ResetLastError();
         handle = FileOpen(filename,FILE_READ|FILE_BIN);
         if(handle==INVALID_HANDLE) {
            Print("Operation FileOpen failed, error ",GetLastError()); 
         }
         if (!loadedorder.Load(handle)) {
            Print("file load failed");
         }
         FileClose(handle);
         FileDelete(filename);
      }
      
      loadedorder.OnTick();
      
      /*Print("Original Order:");
      Print("Test order id: ",order.Id());
      Print("State: ",EnumToString(order.State()));
      Print("ExecuteState: ",EnumToString(order.ExecuteState()));
      Print("GetTicket: ",order.GetTicket());
      Print("GetMagic: ",order.GetMagicNumber());
      Print("GetSymbol: ",order.GetSymbol());
      Print("GetComment: ",order.GetComment());
      Print("GetType: ",EnumToString(order.GetType()));
      Print("GetOpenTime: ",TimeToString(order.GetOpenTime()));
      Print("GetOpenPrice: ",order.GetOpenPrice());
      Print("GetLots: ",order.GetLots());
      Print("GetClosePrice: ",order.GetClosePrice());
      Print("GetCloseTime: ",TimeToString(order.GetCloseTime()));
      Print("GetStopLossTicks: ",order.GetStopLossTicks());
      Print("GetStopLoss: ",order.GetStopLoss());
      Print("GetTakeProfitTicks: ",order.GetTakeProfitTicks());
      Print("GetTakeProfit: ",order.GetTakeProfit());
      Print("GetExpiration: ",TimeToString(order.GetExpiration()));
      Print("GetProfitTicks: ",order.GetProfitTicks());
      Print("GetProfitMoney: ",order.GetProfitMoney());
      Print("GetCommission: ",order.GetCommission());
      Print("GetSwap: ",order.GetSwap());
      
      Print("Loaded Order:");
      Print("Test loadedorder id: ",loadedorder.Id());
      Print("State: ",EnumToString(loadedorder.State()));
      Print("ExecuteState: ",EnumToString(loadedorder.ExecuteState()));
      Print("GetTicket: ",loadedorder.GetTicket());
      Print("GetMagic: ",loadedorder.GetMagicNumber());
      Print("GetSymbol: ",loadedorder.GetSymbol());
      Print("GetComment: ",loadedorder.GetComment());
      Print("GetType: ",EnumToString(loadedorder.GetType()));
      Print("GetOpenTime: ",TimeToString(loadedorder.GetOpenTime()));
      Print("GetOpenPrice: ",loadedorder.GetOpenPrice());
      Print("GetLots: ",loadedorder.GetLots());
      Print("GetClosePrice: ",loadedorder.GetClosePrice());
      Print("GetCloseTime: ",TimeToString(loadedorder.GetCloseTime()));
      Print("GetStopLossTicks: ",loadedorder.GetStopLossTicks());
      Print("GetStopLoss: ",loadedorder.GetStopLoss());
      Print("GetTakeProfitTicks: ",loadedorder.GetTakeProfitTicks());
      Print("GetTakeProfit: ",loadedorder.GetTakeProfit());
      Print("GetExpiration: ",TimeToString(loadedorder.GetExpiration()));
      Print("GetProfitTicks: ",loadedorder.GetProfitTicks());
      Print("GetProfitMoney: ",loadedorder.GetProfitMoney());
      Print("GetCommission: ",loadedorder.GetCommission());
      Print("GetSwap: ",loadedorder.GetSwap());
      */
      
      AssertEqual(order.Id(),loadedorder.Id(),"Id");
      AssertEqual(order.State(),loadedorder.State(),"State");
      AssertEqual(order.ExecuteState(),loadedorder.ExecuteState(),"ExecuteState");
      AssertEqual(order.GetTicket(),loadedorder.GetTicket(),"GetTicket");
      AssertEqual(order.GetMagicNumber(),loadedorder.GetMagicNumber(),"GetMagicNumber");
      AssertEqual(order.GetSymbol(),loadedorder.GetSymbol(),"GetSymbol");
      AssertEqual(order.GetComment(),loadedorder.GetComment(),"GetComment");
      AssertEqual(order.GetType(),loadedorder.GetType(),"GetType");
      AssertEqual(order.GetOpenTime(),loadedorder.GetOpenTime(),"GetOpenTime");
      AssertEqual(order.GetOpenPrice(),loadedorder.GetOpenPrice(),"GetOpenPrice");
      AssertEqual(order.GetLots(),loadedorder.GetLots(),"GetLots");
      AssertEqual(order.GetClosePrice(),loadedorder.GetClosePrice(),"GetClosePrice");
      AssertEqual(order.GetCloseTime(),loadedorder.GetCloseTime(),"GetCloseTime");
      AssertEqual(order.GetStopLossTicks(),loadedorder.GetStopLossTicks(),"GetStopLossTicks");
      AssertEqual(order.GetStopLoss(),loadedorder.GetStopLoss(),"GetStopLoss");
      AssertEqual(order.GetTakeProfitTicks(),loadedorder.GetTakeProfitTicks(),"GetTakeProfitTicks");
      AssertEqual(order.GetProfitTicks(),loadedorder.GetProfitTicks(),"GetProfitTicks");
      AssertEqual(order.GetProfitMoney(),loadedorder.GetProfitMoney(),"GetProfitMoney");
      AssertEqual(order.GetExpiration(),loadedorder.GetExpiration(),"GetExpiration");
      AssertEqual(order.GetProfitTicks(),loadedorder.GetProfitTicks(),"GetProfitTicks");
      AssertEqual(order.GetProfitMoney(),loadedorder.GetProfitMoney(),"GetProfitMoney");
      AssertEqual(order.GetCommission(),loadedorder.GetCommission(),"GetCommission");
      AssertEqual(order.GetSwap(),loadedorder.GetSwap(),"GetSwap");
      
      return true;
   }
   
   virtual void OnEnd()
   {
      Print("TestOrder Ended");
   }    
};
