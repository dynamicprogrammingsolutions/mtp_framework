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
      ref_add(order);
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
      
      delete loadedorder;
      
      int orderid = order.Id();
      
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
      
      loadedorder = App().orderrepository.GetById(orderid);
      
      if (AssertIsSet(loadedorder,"loadedorder")) {
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
      }
      
      delete order;
      order = loadedorder;
      
      return true;
   }
   
   virtual void OnEnd()
   {
      Print("TestOrder Ended");
   }    
};
